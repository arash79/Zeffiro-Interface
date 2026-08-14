function zef = zef_compute_measurements(zef, opts)
%ZEF_COMPUTE_MEASUREMENTS  Synthesize zef.measurements from dipolar sources and zef.L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each source in opts.sources, finds the nearest active brain mesh node,
%   extracts the corresponding (x,y,z) lead-field triplet from raw zef.L via
%   zef_processLeadfields index maps, and accumulates L_k * orientation *
%   amplitude * time_series. Optional white Gaussian noise is added per channel
%   at opts.snr_db. Writes measurements and inversion metadata back onto zef.
%
%   zef = zef_compute_measurements(zef, opts)
%
%   Required opts fields
%     sources              - struct array with position (1x3), orientation (1x3),
%                            amplitude (scalar), time_series (numeric 1xT,
%                            function_handle(t), or preset string).
%     sampling_frequency   - Hz (positive).
%
%   Optional opts (defaults in arguments block)
%     time, duration, snr_db, noise_type ("gaussian"|"none"), lead_field_unit_scale
%     (default 1e-6), inv_data_mode, band-pass fields, normalize_data (1–4),
%     record_inv_synth_source, rng_seed.
%
%   Output zef fields: measurements, inv_sampling_frequency, inv_data_mode,
%   inv_low/high_cut_frequency, inv_time_1/2/3, normalize_data, and optionally
%   inv_synth_source (n_sources x 10 table for plotting).
%
%   Requires nonempty zef.L and zef.source_positions. Errors if lead field or
%   Cartesian column map length is inconsistent with source_direction_mode.
%
%   See also zef_processLeadfields, zef_getFilteredData, zef_inverse_pipeline_run.

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
