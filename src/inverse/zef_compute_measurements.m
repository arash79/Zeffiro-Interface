function zef = zef_compute_measurements(zef, opts)
%ZEF_COMPUTE_MEASUREMENTS Build solver-agnostic synthetic EEG measurements.
%
%   zef = zef_compute_measurements(zef, name, value, ...)
%
% Populates zef.measurements (and the zef.inv_* configuration fields the
% inverse pipeline reads) from an explicit list of dipolar sources. The
% function is solver agnostic: it does not mutate zef.source_direction_mode,
% it does not call evalin / assignin, and the lead-field column layout it
% picks is correct for source_direction_mode in {1, 2, 3}.
%
% Required name-value arguments:
%   sources               1xK struct array. Each element must define:
%       .position         1x3 double, mm, in the project coordinate frame.
%       .orientation      1x3 double; will be normalized to a unit vector.
%       .amplitude        1x1 double. Combined with lead_field_unit_scale
%                         (default 1e-6) this matches the µV/nAm-style
%                         scaling used by the legacy compute_measurements
%                         script and by zef_find_source_legacy.
%       .time_series      Either a 1xT numeric row vector, a function
%                         handle f(t) returning a 1xT row vector, or one
%                         of the string presets:
%                           "blackmanharris" (legacy default; pulse at the
%                                             tail of the time vector)
%                           "gaussian"       (Gaussian pulse centered in t)
%                           "sinusoid"       (10 Hz sine, useful for tests)
%                           "impulse"        (single-sample spike at t=0)
%   sampling_frequency    Hz, > 0. Written to zef.inv_sampling_frequency.
%
% Optional name-value arguments:
%   time                  1xT double, the time vector (s). If empty (the
%                         default), a vector 0:1/fs:duration is built.
%   duration              Pulse / window length (s) used when 'time' is
%                         empty. Default 0.01.
%   snr_db                Per-channel SNR in dB (higher => less noise).
%                         inf disables noise. Default inf.
%   noise_type            "gaussian" | "none". Default "gaussian".
%   lead_field_unit_scale Scalar applied to zef.L when forming the
%                         per-source forward operator. Default 1e-6, which
%                         matches the legacy compute_measurements script
%                         (lead field stored in V/Am, measurements in µV
%                         when amplitudes are in nAm).
%   inv_data_mode         'raw' | 'filtered_temporal'. Default 'raw'. The
%                         char (not string) form is used because consumers
%                         like zef_getFilteredDataClassObj compare with
%                         isequal().
%   inv_low_cut_frequency Hz. Default 0.
%   inv_high_cut_frequency Hz. Default 0.
%   inv_time_1            Time-window start (s). Default 0.
%   inv_time_2            Time-window length (s). Default 0.
%   inv_time_3            Time-step between frames (s). Default 1/fs.
%   normalize_data        1..4, index into the inverse pipeline's
%                         normalization options ("Maximum entry",
%                         "Maximum column norm", "Average column norm",
%                         "None"). Default 1.
%   record_inv_synth_source
%                         logical. Default true. When true, writes the
%                         dipole table into zef.inv_synth_source in the
%                         10-column legacy layout so that plotting plugins
%                         such as zef_plot_synthetic_source keep working.
%   rng_seed              Optional rng seed for reproducible noise. Empty
%                         leaves the global rng untouched. When set, the
%                         previous rng state is restored on return.
%
% Output:
%   zef                   The input zef with .measurements and the inv_*
%                         fields above populated. zef.inv_snr and
%                         zef.number_of_frames are intentionally NOT
%                         touched - those are inverse-time concerns and
%                         are owned by zef_inverse_pipeline_run.

arguments
    zef (1,1) struct
    opts.sources (1,:) struct {mustBeNonempty}
    opts.sampling_frequency (1,1) double {mustBePositive}
    opts.time (1,:) double = []
    opts.duration (1,1) double {mustBePositive} = 0.01
    opts.snr_db (1,1) double = inf
    opts.noise_type (1,1) string {mustBeMember(opts.noise_type, ["gaussian","none"])} = "gaussian"
    opts.lead_field_unit_scale (1,1) double = 1e-6
    opts.inv_data_mode (1,1) string {mustBeMember(opts.inv_data_mode, ["raw","filtered_temporal"])} = "raw"
    opts.inv_low_cut_frequency (1,1) double {mustBeNonnegative} = 0
    opts.inv_high_cut_frequency (1,1) double {mustBeNonnegative} = 0
    opts.inv_time_1 (1,1) double = 0
    opts.inv_time_2 (1,1) double {mustBeNonnegative} = 0
    opts.inv_time_3 (1,1) double = NaN
    opts.normalize_data (1,1) double {mustBeInteger, mustBeInRange(opts.normalize_data, 1, 4)} = 1
    opts.record_inv_synth_source (1,1) logical = true
    opts.rng_seed = []
end

% ----- Lead field / source-grid validation --------------------------------
if ~isfield(zef, "L") || isempty(zef.L)
    error("zef_compute_measurements:NoLeadField", ...
        "zef.L is missing or empty. Build the EEG lead field before calling this function.");
end
if ~isfield(zef, "source_positions") || isempty(zef.source_positions)
    error("zef_compute_measurements:NoSourcePositions", ...
        "zef.source_positions is missing or empty.");
end

% ----- Time vector --------------------------------------------------------
fs = opts.sampling_frequency;
if isempty(opts.time)
    t = 0:(1/fs):opts.duration;
else
    t = opts.time(:)';
end
n_samples = numel(t);
if n_samples < 1
    error("zef_compute_measurements:EmptyTime", "Time vector is empty.");
end

% ----- Reproducible RNG (optional) ----------------------------------------
if ~isempty(opts.rng_seed)
    prev_rng = rng;                            %#ok<NASGU>
    cleanup_rng = onCleanup(@() rng(prev_rng)); %#ok<NASGU>
    rng(opts.rng_seed);
end

% ----- Solver-agnostic Cartesian column map -------------------------------
% zef_processLeadfields returns indices into the *raw* zef.L organised in
% Cartesian (x,y,z) blocks. Which field of procFile carries that 3*n_interp
% layout depends on the active source_direction_mode:
%   modes 1, 2 : procFile.s_ind_1 (length 3*n_interp)
%   mode 3     : procFile.s_ind_2 (length 3*n_interp; s_ind_1 is the
%                normal-direction-only layout used by the inverter).
[~, n_interp, procFile] = zef_processLeadfields(zef);
switch procFile.source_direction_mode
    case {1, 2}
        cart_index_map = procFile.s_ind_1;
    case 3
        if isempty(procFile.s_ind_2)
            error("zef_compute_measurements:MissingCartesianMap", ...
                "procFile.s_ind_2 is empty under source_direction_mode 3.");
        end
        cart_index_map = procFile.s_ind_2;
    otherwise
        error("zef_compute_measurements:UnsupportedDirectionMode", ...
            "Unsupported zef.source_direction_mode = %d.", procFile.source_direction_mode);
end
cart_index_map = cart_index_map(:);
expected_len = 3 * n_interp;
if numel(cart_index_map) ~= expected_len
    error("zef_compute_measurements:BadCartesianMap", ...
        "Internal: Cartesian index map length %d ~= 3 * n_interp = %d.", ...
        numel(cart_index_map), expected_len);
end

mesh_points = zef.source_positions(procFile.s_ind_0, :);

% ----- Per-source forward synthesis ---------------------------------------
n_channels = size(zef.L, 1);
Y = zeros(n_channels, n_samples);
n_sources = numel(opts.sources);
synth_table = zeros(n_sources, 10);

for k = 1:n_sources
    s = i_validate_source(opts.sources(k), k);

    % Find the nearest brain mesh node.
    d2 = sum((mesh_points - s.position).^2, 2);
    [~, i_k] = min(d2);

    % Cartesian (x,y,z) column triplet for this source in raw zef.L.
    triplet = cart_index_map([i_k, i_k + n_interp, i_k + 2*n_interp]);
    L_k = opts.lead_field_unit_scale * zef.L(:, triplet);

    % Unit-orientation moment, scaled by amplitude and the time series.
    ori = s.orientation(:);
    ori = ori / norm(ori);
    ts = i_resolve_time_series(s.time_series, t, k);

    Y = Y + (L_k * ori) * (s.amplitude * ts);

    synth_table(k, 1:3) = s.position(:)';
    synth_table(k, 4:6) = ori';
    synth_table(k, 7)   = s.amplitude;
    synth_table(k, 8)   = 0;                       % legacy noise-level slot
    synth_table(k, 9)   = abs(s.amplitude);        % plot scale
    synth_table(k, 10)  = mod(k - 1, 7) + 1;       % color index
end

% ----- Noise --------------------------------------------------------------
if opts.noise_type ~= "none" && isfinite(opts.snr_db)
    Y = i_add_noise(Y, opts.snr_db);
end

% ----- Write back into zef ------------------------------------------------
zef.measurements = Y;
zef.inv_sampling_frequency  = fs;
zef.inv_data_mode           = char(opts.inv_data_mode);
zef.inv_low_cut_frequency   = opts.inv_low_cut_frequency;
zef.inv_high_cut_frequency  = opts.inv_high_cut_frequency;
zef.inv_time_1              = opts.inv_time_1;
zef.inv_time_2              = opts.inv_time_2;
if isnan(opts.inv_time_3)
    zef.inv_time_3 = 1 / fs;
else
    zef.inv_time_3 = opts.inv_time_3;
end
zef.normalize_data          = opts.normalize_data;

if opts.record_inv_synth_source
    zef.inv_synth_source = synth_table;
end

end

% =========================================================================
% Helpers
% =========================================================================

function s = i_validate_source(s, k)
%I_VALIDATE_SOURCE Confirm a single sources(k) struct is well-formed.

required = ["position", "orientation", "amplitude", "time_series"];
for f = required
    if ~isfield(s, f)
        error("zef_compute_measurements:MissingSourceField", ...
            "sources(%d) is missing required field '%s'.", k, f);
    end
end

if ~(isnumeric(s.position) && numel(s.position) == 3)
    error("zef_compute_measurements:BadPosition", ...
        "sources(%d).position must be a 1x3 numeric vector.", k);
end
if ~(isnumeric(s.orientation) && numel(s.orientation) == 3)
    error("zef_compute_measurements:BadOrientation", ...
        "sources(%d).orientation must be a 1x3 numeric vector.", k);
end
if norm(s.orientation) == 0
    error("zef_compute_measurements:ZeroOrientation", ...
        "sources(%d).orientation must be non-zero.", k);
end
if ~(isnumeric(s.amplitude) && isscalar(s.amplitude))
    error("zef_compute_measurements:BadAmplitude", ...
        "sources(%d).amplitude must be a numeric scalar.", k);
end

s.position    = double(s.position(:)');
s.orientation = double(s.orientation(:)');
s.amplitude   = double(s.amplitude);
end

function ts = i_resolve_time_series(ts_in, t, k)
%I_RESOLVE_TIME_SERIES Return a 1xT row-vector time series for source k.

n = numel(t);

if isnumeric(ts_in)
    ts = ts_in(:)';
    if numel(ts) ~= n
        error("zef_compute_measurements:BadTimeSeriesLength", ...
            "sources(%d).time_series has length %d but the time vector has length %d.", ...
            k, numel(ts), n);
    end
    return
end

if isa(ts_in, "function_handle")
    ts = ts_in(t);
    ts = ts(:)';
    if numel(ts) ~= n
        error("zef_compute_measurements:BadTimeSeriesHandle", ...
            "sources(%d).time_series handle returned %d samples but the time vector has length %d.", ...
            k, numel(ts), n);
    end
    return
end

if isstring(ts_in) || ischar(ts_in)
    preset = string(ts_in);
    switch lower(preset)
        case "blackmanharris"
            % Match the legacy compute_measurements pulse: an 8 ms
            % Blackman-Harris window placed at the tail of the time vector.
            sz = max(1, find(t > 0.008, 1));
            if isempty(sz), sz = n; end
            pulse = blackmanharris(sz)';
            ts = [zeros(1, n - numel(pulse)), pulse];
        case "gaussian"
            mu = (t(1) + t(end)) / 2;
            sigma = (t(end) - t(1)) / 8 + eps;
            ts = exp(-((t - mu).^2) / (2 * sigma^2));
        case "sinusoid"
            ts = sin(2 * pi * 10 * t);              % 10 Hz default
        case "impulse"
            ts = zeros(1, n);
            ts(1) = 1;
        otherwise
            error("zef_compute_measurements:UnknownPreset", ...
                "sources(%d).time_series preset '%s' is not recognised.", k, preset);
    end
    return
end

error("zef_compute_measurements:BadTimeSeriesType", ...
    "sources(%d).time_series must be numeric, a function handle, or a string preset.", k);
end

function Y = i_add_noise(Y, snr_db)
%I_ADD_NOISE Per-channel white-Gaussian noise at the requested SNR (dB).
%
% Reproduces the scaling used by the legacy compute_measurements.m:
%   y_noisy = y + (10^(-snr_db/20) * sqrt(sum(y.^2, 2) ./ sum(n.^2, 2))) .* n
% so that, per channel, the post-mix signal-to-noise power ratio equals
% 10^(snr_db/10).

n = randn(size(Y));
sig_energy = sum(Y.^2, 2);
noise_energy = sum(n.^2, 2);
% Avoid 0/0 on perfectly silent channels: leave them silent.
scale = zeros(size(sig_energy));
mask = noise_energy > 0 & sig_energy > 0;
scale(mask) = 10^(-snr_db/20) .* sqrt(sig_energy(mask) ./ noise_energy(mask));
Y = Y + scale .* n;
end
