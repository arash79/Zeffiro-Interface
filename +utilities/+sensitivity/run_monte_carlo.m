function results = run_monte_carlo(zef, method_id, opts)
%RUN_MONTE_CARLO  Monte Carlo sensitivity study over source probes and noise.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   results = run_monte_carlo(zef, method_id, opts)
%
%   Requires zef.L and uses method_capability to choose batching strategy.
%   Synthesizes measurements per probe, runs zef_inverse_run (local or cluster),
%   and compute_metrics on each realization. Key opts: NumberOfRuns, NoiseLevelDb,
%   DiffType, DispersionRadius, SourceAmplitude, IsolatedFramesPerProbe,
%   MaxProbesPerBatch, MethodParams, execution ("local"|"cluster").

arguments
    zef (1,1) struct
    method_id (1,1) string {mustBeNonempty}
    opts.Capability struct = struct
    opts.ProcFile struct = struct
    opts.NInterp double = []
    opts.SourceIndices (:,1) double {mustBeInteger, mustBePositive} = double.empty(0, 1)
    opts.MethodParams (1,1) struct = struct
    opts.execution (1,1) string {mustBeMember(opts.execution,["local","cluster"])} = "local"
    opts.ClusterProfile = []
    opts.NumberOfRuns (1,1) double {mustBeInteger, mustBePositive} = 1
    opts.NoiseLevelDb (1,1) double {mustBeNonpositive} = -30
    opts.DiffType (1,1) string {mustBeMember(opts.DiffType,["L2","minabs"])} = "L2"
    opts.DispersionRadius (1,1) double {mustBePositive} = 30
    opts.SourceAmplitude (1,1) double = 10
    opts.IsolatedFramesPerProbe (1,1) double {mustBeInteger, mustBePositive} = 4
    opts.MaxProbesPerBatch (1,1) double {mustBeInteger, mustBePositive} = 1000
end

if ~isfield(zef, "L") || isempty(zef.L)
    error("utilities:sensitivity:run_monte_carlo:MissingLeadField", ...
        "zef.L is missing or empty; build the lead field before running the sensitivity study.");
end

if isempty(fieldnames(opts.Capability))
    opts.Capability = utilities.sensitivity.method_capability(method_id);
end
capability = opts.Capability;

if isempty(fieldnames(opts.ProcFile))
    [~, n_interp_local, procFile] = zef_processLeadfields(zef);
else
    procFile = opts.ProcFile;
    if isempty(opts.NInterp)
        n_interp_local = procFile.n_interp;
    else
        n_interp_local = opts.NInterp;
    end
end
n_interp = n_interp_local;  %#ok<NASGU>  % carried for diagnostics

if isempty(opts.SourceIndices)
    source_indices = procFile.s_ind_0(:);
else
    source_indices = opts.SourceIndices(:);
end

source_positions = zef.source_positions;
source_direction_mode = procFile.source_direction_mode;
source_directions_full = i_full_source_directions(zef, procFile);

% Pre-build a local zef clone configured for raw measurements so each
% realisation just rewrites zef_local.measurements / number_of_frames.
zef_local = zef;
zef_local.inv_data_mode = 'raw';

n_runs = opts.NumberOfRuns;
runs        = cell(1, n_runs);
run_results = cell(1, n_runs);

inv_kwargs = { ...
    "execution",      opts.execution, ...
    "MethodParams",   opts.MethodParams, ...
    "ClusterProfile", opts.ClusterProfile ...
};

for r = 1:n_runs
    t_run = tic;
    n_expected_probes = i_expected_probe_count(source_direction_mode, source_indices);
    fprintf(2, '    [sensitivity %s] run %d / %d, probes %d, strategy %s\n', ...
        char(method_id), r, n_runs, n_expected_probes, char(capability.strategy));

    switch capability.strategy
        case {"linear_static", "iterative_static"}
            [metrics, run_result] = i_run_static_chunked( ...
                zef_local, ...
                method_id, ...
                source_indices, ...
                source_direction_mode, ...
                source_directions_full, ...
                source_positions, ...
                opts.SourceAmplitude, ...
                opts.NoiseLevelDb, ...
                opts.DiffType, ...
                opts.DispersionRadius, ...
                opts.MaxProbesPerBatch, ...
                inv_kwargs, ...
                r);

        case "stateful_dynamic"
            % Build noise-free signals once; the isolated helper replays
            % each probe over IsolatedFramesPerProbe frames with fresh
            % noise so KalmanInverter.initialize's variance estimate stays
            % well defined and the filter has a chance to track.
            if opts.NoiseLevelDb == 0
                error("utilities:sensitivity:run_monte_carlo:NoiseRequiredForStateful", ...
                    "Method '%s' (strategy 'stateful_dynamic') requires NoiseLevelDb < 0 so the noise-variance prior is non-degenerate; got %g.", ...
                    method_id, opts.NoiseLevelDb);
            end
            F_clean = utilities.sensitivity.synthesize_measurements( ...
                zef_local.L, source_indices, opts.SourceAmplitude, 0, ...
                "SourceDirectionMode", source_direction_mode, ...
                "SourceDirections",    source_directions_full);
            [recon_cells, run_result] = i_run_isolated_stateful( ...
                zef_local, method_id, F_clean, opts.NoiseLevelDb, ...
                opts.IsolatedFramesPerProbe, inv_kwargs);
            i_assert_reconstruction_count(recon_cells, size(F_clean, 2), method_id, r);
            metrics = utilities.sensitivity.compute_metrics( ...
                recon_cells, ...
                source_positions, ...
                source_indices, ...
                opts.DiffType, ...
                opts.DispersionRadius, ...
                "SourceDirectionMode", source_direction_mode, ...
                "SourceDirections",    source_directions_full);

        otherwise
            error("utilities:sensitivity:run_monte_carlo:UnsupportedStrategy", ...
                "Method '%s' has unsupported strategy '%s'; sensitivity dispatch aborted.", ...
                method_id, capability.strategy);
    end

    run_results{r} = run_result;
    runs{r} = metrics;

    fprintf(2, '    [sensitivity %s] run %d / %d complete in %.2fs\n', ...
        char(method_id), r, n_runs, toc(t_run));
end

results = struct( ...
    "runs",           {runs}, ...
    "run_results",    {run_results}, ...
    "method_id",      method_id, ...
    "source_indices", source_indices, ...
    "n_used",         numel(source_indices), ...
    "strategy",       capability.strategy);

end

function n_probes = i_expected_probe_count(source_direction_mode, source_indices)
n_probes = i_probes_per_source(source_direction_mode) * numel(source_indices);
end

function n = i_probes_per_source(source_direction_mode)
if source_direction_mode == 3
    n = 1;
else
    n = 3;
end
end

function i_assert_reconstruction_count(recon_cells, expected_count, method_id, run_index)
if numel(recon_cells) ~= expected_count
    error("utilities:sensitivity:run_monte_carlo:BadReconstructionCount", ...
        "Method '%s' sensitivity run %d returned %d reconstructions; expected %d.", ...
        method_id, run_index, numel(recon_cells), expected_count);
end
if any(cellfun(@isempty, recon_cells))
    error("utilities:sensitivity:run_monte_carlo:EmptyReconstruction", ...
        "Method '%s' sensitivity run %d returned at least one empty reconstruction.", ...
        method_id, run_index);
end
for k = 1:numel(recon_cells)
    z_k = recon_cells{k};
    if isa(z_k, "gpuArray")
        z_k = gather(z_k);
    end
    if ~isnumeric(z_k) || any(~isfinite(z_k(:)))
        error("utilities:sensitivity:run_monte_carlo:NonFiniteReconstruction", ...
            "Method '%s' sensitivity run %d returned a non-numeric, NaN, or Inf reconstruction at probe %d.", ...
            method_id, run_index, k);
    end
end
end

% =========================================================================
% Helper: chunked static dispatch.
% =========================================================================
function [metrics, run_result] = i_run_static_chunked( ...
    zef_local, ...
    method_id, ...
    source_indices, ...
    source_direction_mode, ...
    source_directions_full, ...
    source_positions, ...
    source_amplitude, ...
    noise_level_db, ...
    diff_type, ...
    dispersion_radius, ...
    max_probes_per_batch, ...
    inv_kwargs, ...
    run_index)

probes_per_source = i_probes_per_source(source_direction_mode);
sources_per_batch = max(1, floor(max_probes_per_batch / probes_per_source));
n_sources = numel(source_indices);
n_chunks = ceil(n_sources / sources_per_batch);

F_initialize = utilities.sensitivity.synthesize_measurements( ...
    zef_local.L, source_indices, source_amplitude, noise_level_db, ...
    "SourceDirectionMode", source_direction_mode, ...
    "SourceDirections",    source_directions_full);
expected_full_probes = i_expected_probe_count(source_direction_mode, source_indices);
if size(F_initialize, 2) ~= expected_full_probes
    error("utilities:sensitivity:run_monte_carlo:BadSyntheticProbeCount", ...
        "Synthetic sensitivity matrix has %d probe(s); expected %d.", ...
        size(F_initialize, 2), expected_full_probes);
end

metric_chunks = cell(1, n_chunks);
chunk_summaries = repmat(i_empty_chunk_summary(), n_chunks, 1);

for c = 1:n_chunks
    first_source = (c - 1) * sources_per_batch + 1;
    last_source = min(c * sources_per_batch, n_sources);
    chunk_source_indices = source_indices(first_source:last_source);
    first_probe = (first_source - 1) * probes_per_source + 1;
    last_probe = last_source * probes_per_source;
    n_chunk_probes = i_expected_probe_count(source_direction_mode, chunk_source_indices);

    if n_chunks > 1
        fprintf(2, '      [sensitivity %s] run %d chunk %d / %d, sources %d-%d, probes %d\n', ...
            char(method_id), run_index, c, n_chunks, first_source, last_source, n_chunk_probes);
    end

    t_chunk = tic;
    F = F_initialize(:, first_probe:last_probe);

    [recon_cells, chunk_result] = i_run_batched(zef_local, method_id, F, inv_kwargs, F_initialize);
    i_assert_reconstruction_count(recon_cells, size(F, 2), method_id, run_index);

    metric_chunks{c} = utilities.sensitivity.compute_metrics( ...
        recon_cells, ...
        source_positions, ...
        chunk_source_indices, ...
        diff_type, ...
        dispersion_radius, ...
        "SourceDirectionMode", source_direction_mode, ...
        "SourceDirections",    source_directions_full);

    chunk_summaries(c) = i_chunk_summary( ...
        chunk_result, ...
        first_source, ...
        last_source, ...
        numel(chunk_source_indices), ...
        size(F, 2), ...
        toc(t_chunk));

    if n_chunks > 1
        fprintf(2, '      [sensitivity %s] run %d chunk %d / %d complete in %.2fs\n', ...
            char(method_id), run_index, c, n_chunks, chunk_summaries(c).seconds);
    end

    clear F recon_cells chunk_result
end

metrics = i_merge_metric_chunks( ...
    metric_chunks, ...
    source_positions, ...
    source_indices, ...
    source_direction_mode, ...
    dispersion_radius);

run_result = struct( ...
    "method_id",             method_id, ...
    "chunked_dispatch",      true, ...
    "n_chunks",              n_chunks, ...
    "max_probes_per_batch",  max_probes_per_batch, ...
    "initialization_probes",  size(F_initialize, 2), ...
    "probes_per_source",     probes_per_source, ...
    "chunk_summaries",       chunk_summaries);

end

function summary = i_empty_chunk_summary()
summary = struct( ...
    "method_id",                  "", ...
    "first_source_ordinal",       0, ...
    "last_source_ordinal",        0, ...
    "n_sources",                  0, ...
    "n_probes",                   0, ...
    "seconds",                    0, ...
    "reconstruction_information", struct);
end

function summary = i_chunk_summary(chunk_result, first_source, last_source, n_sources, n_probes, seconds)
summary = i_empty_chunk_summary();
if isfield(chunk_result, "method_id")
    summary.method_id = chunk_result.method_id;
end
summary.first_source_ordinal = first_source;
summary.last_source_ordinal = last_source;
summary.n_sources = n_sources;
summary.n_probes = n_probes;
summary.seconds = seconds;
if isfield(chunk_result, "reconstruction_information")
    summary.reconstruction_information = chunk_result.reconstruction_information;
end
end

function metrics = i_merge_metric_chunks(metric_chunks, source_positions, source_indices, source_direction_mode, dispersion_radius)
dist_vec = i_concat_metric(metric_chunks, "dist_vec");
angle_vec = i_concat_metric(metric_chunks, "angle_vec");
mag_vec = i_concat_metric(metric_chunks, "mag_vec");
max_ind_vec = i_concat_metric(metric_chunks, "max_ind_vec");

dispersion_vec = i_compute_global_dispersion( ...
    source_positions, ...
    source_indices, ...
    max_ind_vec, ...
    mag_vec, ...
    i_probes_per_source(source_direction_mode), ...
    dispersion_radius);

metrics = struct( ...
    "dist_vec",       dist_vec, ...
    "angle_vec",      angle_vec, ...
    "mag_vec",        mag_vec, ...
    "dispersion_vec", dispersion_vec, ...
    "max_ind_vec",    max_ind_vec);
end

function v = i_concat_metric(metric_chunks, field_name)
field_name = char(field_name);
parts = cell(size(metric_chunks));
for k = 1:numel(metric_chunks)
    metric_value = metric_chunks{k}.(field_name);
    parts{k} = metric_value(:);
end
v = vertcat(parts{:});
end

function dispersion_vec = i_compute_global_dispersion(source_positions, source_indices, max_ind_vec, mag_vec, probes_per_source, dispersion_radius)
% Match utilities.sensitivity.compute_metrics' dispersion semantics after
% chunking: the ROI search pool is the full probed source list repeated by
% the probe layout, not the smaller per-chunk source list.
probed_positions = source_positions(source_indices, :);
repeated_positions = repelem(probed_positions, probes_per_source, 1);
query_positions = source_positions(max_ind_vec, :);
within_inds_cells = rangesearch(repeated_positions, query_positions, dispersion_radius);

n_rec = numel(max_ind_vec);
dispersion_vec = zeros(n_rec, 1);
mag_sqr = mag_vec(:).^2;

for k = 1:n_rec
    inds = within_inds_cells{k};
    if isempty(inds)
        dispersion_vec(k) = 0;
        continue
    end
    inds = inds(:);
    diffs = repeated_positions(inds, :) - query_positions(k, :);
    sq_dist = sum(diffs.^2, 2);
    sq_mag = mag_sqr(inds);
    dispersion_vec(k) = sqrt(sum(sq_dist .* sq_mag) / max(sum(sq_mag), eps));
end
end

% =========================================================================
% Helper: batched dispatch (one zef_inverse_run per static probe batch).
% =========================================================================
function [recon_cells, run_result] = i_run_batched(zef_local, method_id, F, inv_kwargs, F_initialize)

zef_local.measurements     = F;
zef_local.number_of_frames = size(F, 2);
if nargin >= 5 && ~isempty(F_initialize)
    zef_local.inverse_initialization_measurements = F_initialize;
end

[~, run_result] = zef_inverse_run(zef_local, method_id, inv_kwargs{:});

recon = run_result.reconstruction;
if iscell(recon)
    recon_cells = recon;
else
    recon_cells = {recon};
end

end

% =========================================================================
% Helper: isolated dispatch for stateful inverters (Kalman family).
% Each probe gets a brand-new inverter via zef_inverse_run (which rebuilds
% the class object from scratch in extract_bundle), and is replayed over
% T_KF frames so:
%   1. Initialize's var(f_data(:, 1:number_of_noise_steps), 0, 2) is
%      well-defined (otherwise theta0 is zero and the prior is degenerate).
%   2. The filter has a few steps to track the constant signal before we
%      take the final reconstruction.
% Fresh noise is drawn per frame so the noise-variance estimate captures
% the actual measurement noise scale.
% =========================================================================
function [recon_cells, run_result] = i_run_isolated_stateful(zef_local, method_id, F_clean, noise_db, n_kf_frames, inv_kwargs)

[n_ch, n_probes] = size(F_clean);
recon_cells = cell(1, n_probes);
sub_results = cell(1, n_probes);

zef_local.number_of_frames = n_kf_frames;
sigma = 10^(noise_db / 20);

% Per-probe progress: each iteration is its own zef_inverse_run dispatch,
% which for the Kalman family means a full inverter rebuild + state-cov
% allocation + n_kf_frames forward steps. The dispatcher prints one
% verbose-mode Task ID line per dispatch but nothing in between, so
% without this it can look like a stuck loop. We print to stderr (fid 2)
% so the progress text appears even when stdout is being captured.
probe_start_time = tic;
for k = 1:n_probes
    fprintf(2, '    [stateful sensitivity %s] probe %d / %d (%.1fs so far)\n', ...
        char(method_id), k, n_probes, toc(probe_start_time));

    F_probe = F_clean(:, k) * ones(1, n_kf_frames) + sigma * randn(n_ch, n_kf_frames);
    zef_local.measurements = F_probe;

    [~, sub_result] = zef_inverse_run(zef_local, method_id, inv_kwargs{:});
    sub_results{k} = sub_result;

    recon = sub_result.reconstruction;
    if iscell(recon) && ~isempty(recon)
        % Final frame: most informed by data after KF tracking.
        recon_cells{k} = recon{end};
    elseif ~isempty(recon)
        recon_cells{k} = recon;
    else
        recon_cells{k} = [];
    end
end

run_result = struct( ...
    "method_id",                 method_id, ...
    "isolated_dispatch",         true, ...
    "frames_per_probe",          n_kf_frames, ...
    "reconstruction",            {recon_cells}, ...
    "reconstruction_information", struct, ...
    "sub_results",               {sub_results});

end

% =========================================================================
% Helper: build a full-source-direction matrix in the layout
% size(zef.source_positions, 1) x 3, falling back to standard basis when the
% project does not provide one. Mode 3 needs this; modes 1 and 2 ignore it.
% =========================================================================
function dirs = i_full_source_directions(zef, procFile)
%I_FULL_SOURCE_DIRECTIONS Best-effort source_directions in n_full x 3 layout.
%
% Modes 1 / 2 ignore this matrix; only mode 3 uses it. We therefore tolerate
% any shape mismatch silently (return a default unit-z column) so a mode-2
% project that exposes an oddly shaped procFile.source_directions does not
% crash the static-method path.

n_full = size(zef.source_positions, 1);
default_dirs = repmat([0 0 1], n_full, 1);

if procFile.source_direction_mode ~= 3
    % Static / Cartesian probes never read these; return default to avoid
    % shape-mismatch warnings in mode-2 projects.
    dirs = default_dirs;
    return
end

if isfield(procFile, "source_directions") && ~isempty(procFile.source_directions)
    raw = procFile.source_directions;
elseif isfield(zef, "source_directions") && ~isempty(zef.source_directions)
    raw = zef.source_directions;
else
    dirs = default_dirs;
    return
end

if size(raw, 2) ~= 3
    warning("utilities:sensitivity:run_monte_carlo:BadSourceDirectionsShape", ...
        "Expected a (:, 3) source-directions matrix; got %d columns. Falling back to default unit-z.", size(raw, 2));
    dirs = default_dirs;
    return
end

if size(raw, 1) == n_full
    dirs = raw;
elseif size(raw, 1) == numel(procFile.s_ind_0)
    % procFile.source_directions is restricted to active sources after
    % mode-3 processing; expand back to the full source space.
    dirs = default_dirs;
    dirs(procFile.s_ind_0, :) = raw;
else
    warning("utilities:sensitivity:run_monte_carlo:SourceDirectionsRowMismatch", ...
        "Could not align source_directions (%d rows) to source_positions (%d rows); falling back to default unit-z.", ...
        size(raw, 1), n_full);
    dirs = default_dirs;
end

end
