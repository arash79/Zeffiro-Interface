function [zef, output] = zef_inverse_pipeline_run(zef, cfg)
% --- Zeffiro documentation header ---
% zef_inverse_pipeline_run — Zef inverse pipeline run.
%
% Purpose:
%   Zef inverse pipeline run.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   zef
%   cfg
%
% Outputs:
%   zef
%   output
%
% Zef fields (observed):
%   zef.inv_snr (read, write)
%   zef.measurements (read)
%   zef.number_of_frames (read, write)
%   zef.source_positions (read)
%
% Calls (project):
%   utilities.cluster.configure_cluster_profile
%   zef_inverse_pipeline_run
%   zef_inverse_run
%   zef_sensitivity_run
%
% Side effects:
%   - GPU
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[zef, output]] = zef_inverse_pipeline_run(zef, cfg)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    zef (1,1) struct
    cfg (1,1) struct = struct
end

cfg = i_apply_defaults(cfg);

if ~isfield(zef, "measurements") || isempty(zef.measurements)
    error("zef_inverse_pipeline_run:NoMeasurements", ...
        "zef.measurements is empty. Call zef_compute_measurements first.");
end

zef.inv_snr          = cfg.inv_snr_db;
zef.number_of_frames = min(cfg.number_of_frames, size(zef.measurements, 2));

cluster_profile = [];
if (cfg.run_inverse || cfg.run_sensitivity) && cfg.execution == "cluster"
    cluster_profile = utilities.cluster.configure_cluster_profile( ...
        cfg.cluster.project, ...
        "MemPerCPU",  cfg.cluster.MemPerCPU, ...
        "WallTime",   cfg.cluster.WallTime, ...
        "Partition",  cfg.cluster.Partition, ...
        "NumThreads", cfg.cluster.NumThreads);
end

output             = struct;
output.config      = cfg;
output.timestamp   = datetime("now");
output.inverse     = struct;
output.sensitivity = struct;

methods_table = cfg.methods;
n_methods     = size(methods_table, 1);

% ---------- Inverse stage ----------
if cfg.run_inverse
    for r = 1:n_methods
        key      = char(methods_table{r, 1});
        reg_id   = string(methods_table{r, 2});
        m_params = methods_table{r, 3};
        fprintf("[inverse] %s (%s) ...\n", key, reg_id);
        t0 = tic;
        try
            [zef_out, run_out] = zef_inverse_run( ...
                zef, reg_id, ...
                "execution",      cfg.execution, ...
                "MethodParams",   m_params, ...
                "ClusterProfile", cluster_profile);
            i_validate_inverse_run(run_out, zef.number_of_frames, key);
            output.inverse.(key) = struct( ...
                "zef",         zef_out, ...
                "run",         run_out, ...
                "seconds",     toc(t0), ...
                "registry_id", reg_id);
            fprintf("  ok in %.2fs\n", toc(t0));
        catch ME
            output.inverse.(key) = struct( ...
                "err",         ME.message, ...
                "seconds",     toc(t0), ...
                "registry_id", reg_id);
            fprintf("  FAILED: %s\n", ME.message);
        end
    end
end

% ---------- Sensitivity stage ----------
if cfg.run_sensitivity
    if cfg.sensitivity.n_of_runs < 2
        warning("zef_inverse_pipeline_run:LowRuns", ...
            "n_of_runs=%d: dispersion std uses (n-1); use >=2.", cfg.sensitivity.n_of_runs);
    end
    for r = 1:n_methods
        key      = char(methods_table{r, 1});
        reg_id   = string(methods_table{r, 2});
        m_params = methods_table{r, 3};
        fprintf("[sensitivity] %s (%s) ...\n", key, reg_id);
        t0 = tic;
        try
            sens_kwargs = { ...
                "execution",              cfg.execution, ...
                "MethodParams",           m_params, ...
                "ClusterProfile",         cluster_profile, ...
                "NumberOfRuns",           cfg.sensitivity.n_of_runs, ...
                "NoiseLevelDb",           cfg.sensitivity.noise_level_db, ...
                "DiffType",               cfg.sensitivity.diff_type, ...
                "DispersionRadius",       cfg.sensitivity.dispersion_radius, ...
                "IsolatedFramesPerProbe", cfg.sensitivity.isolated_frames_per_probe, ...
                "MaxProbesPerBatch",      cfg.sensitivity.max_probes_per_batch};
            mask = i_resolve_source_mask(zef, cfg.sensitivity);
            if ~isempty(mask)
                sens_kwargs = [sens_kwargs, {"SourceMask", mask}];
            end
            [stats, sens_run] = zef_sensitivity_run(zef, reg_id, sens_kwargs{:});
            i_validate_sensitivity_stats(stats, key);
            output.sensitivity.(key) = struct( ...
                "method_id",  reg_id, ...
                "statistics", stats, ...
                "L",          sens_run.L, ...
                "strategy",   sens_run.strategy, ...
                "seconds",    toc(t0));
            fprintf("  ok in %.2fs (strategy: %s, fields: %s)\n", ...
                toc(t0), sens_run.strategy, strjoin(fieldnames(stats), ", "));
        catch ME
            output.sensitivity.(key) = struct( ...
                "method_id", reg_id, ...
                "err",       ME.message, ...
                "seconds",   toc(t0));
            fprintf("  FAILED: %s\n", ME.message);
        end
    end
end

fprintf("\nDone.\n");
fprintf("  inverse keys:     {%s}\n", strjoin(fieldnames(output.inverse), ", "));
fprintf("  sensitivity keys: {%s}\n", strjoin(fieldnames(output.sensitivity), ", "));

end

% =========================================================================
% Helpers
% =========================================================================

function i_validate_inverse_run(run_out, expected_frames, key)
if ~isfield(run_out, "reconstruction") || isempty(run_out.reconstruction)
    error("zef_inverse_pipeline_run:EmptyInverseReconstruction", ...
        "Inverse method '%s' returned an empty reconstruction.", key);
end

recon = run_out.reconstruction;
if iscell(recon)
    if numel(recon) ~= expected_frames
        error("zef_inverse_pipeline_run:BadInverseFrameCount", ...
            "Inverse method '%s' returned %d reconstruction frame(s); expected %d.", ...
            key, numel(recon), expected_frames);
    end
    for k = 1:numel(recon)
        i_validate_numeric_output(recon{k}, ...
            sprintf('inverse.%s.reconstruction{%d}', key, k));
    end
else
    i_validate_numeric_output(recon, sprintf('inverse.%s.reconstruction', key));
end
end

function i_validate_sensitivity_stats(stats, key)
required_fields = ["dist_vec_avg", "angle_vec_avg", "mag_vec_avg", "dispersion_avg"];
for f = required_fields
    field_name = char(f);
    if ~isfield(stats, field_name)
        error("zef_inverse_pipeline_run:MissingSensitivityField", ...
            "Sensitivity method '%s' did not return stats.%s.", key, field_name);
    end
    i_validate_numeric_output(stats.(field_name), sprintf('sensitivity.%s.%s', key, field_name));
end
end

function i_validate_numeric_output(v, label)
if isempty(v) || ~isnumeric(v)
    error("zef_inverse_pipeline_run:InvalidNumericOutput", ...
        "%s is empty or non-numeric.", char(label));
end
if isa(v, "gpuArray")
    v = gather(v);
end
if any(~isfinite(v(:)))
    error("zef_inverse_pipeline_run:NonFiniteOutput", ...
        "%s contains NaN or Inf values.", char(label));
end
end

function cfg = i_apply_defaults(cfg)
%I_APPLY_DEFAULTS Fill in missing cfg fields with the legacy defaults.

defaults = i_default_cfg();
cfg = i_merge_struct_defaults(cfg, defaults);

% Nested structs (sensitivity, cluster) need recursive merging.
cfg.sensitivity = i_merge_struct_defaults( ...
    i_get_field(cfg, "sensitivity", struct()), defaults.sensitivity);
cfg.cluster = i_merge_struct_defaults( ...
    i_get_field(cfg, "cluster", struct()), defaults.cluster);

% Validate.
cfg.execution = string(cfg.execution);
if ~ismember(cfg.execution, ["local", "cluster"])
    error("zef_inverse_pipeline_run:BadExecution", ...
        "cfg.execution must be 'local' or 'cluster' (got '%s').", cfg.execution);
end

if isempty(cfg.methods)
    error("zef_inverse_pipeline_run:NoMethods", ...
        "cfg.methods is empty - nothing to run.");
end
if size(cfg.methods, 2) ~= 3
    error("zef_inverse_pipeline_run:BadMethodsShape", ...
        "cfg.methods must be an Nx3 cell array with rows {key, registry_id, methodParams}.");
end
end

function defaults = i_default_cfg()
%I_DEFAULT_CFG Defaults that match the legacy run_inverse_script.m.

defaults = struct;
defaults.execution        = "local";
defaults.run_inverse      = true;
defaults.run_sensitivity  = true;

defaults.methods = {
    "sloreta",    "sloreta",    struct("method_type","sLORETA","theta0",1e-3)
    "dipolescan", "dipolescan", struct("method_type","SVD","reg_type","None","reg_parameter",1e-3)
};

defaults.inv_snr_db        = 30;
defaults.number_of_frames  = 1;

defaults.sensitivity = struct( ...
    "n_of_runs",                1, ...
    "noise_level_db",           -30, ...
    "diff_type",                "L2", ...
    "dispersion_radius",        30, ...
    "isolated_frames_per_probe", 4, ...
    "max_probes_per_batch",     1000 ...
);

defaults.cluster = struct( ...
    "project",    "project_2002680", ...
    "MemPerCPU",  "8g", ...
    "WallTime",   "24:00:00", ...
    "Partition",  "small", ...
    "NumThreads", 1 ...
);
end

function out = i_merge_struct_defaults(in, defaults)
%I_MERGE_STRUCT_DEFAULTS Shallow merge: fields in `in` win, missing ones
% are filled from `defaults`.

if ~isstruct(in)
    in = struct();
end
out = defaults;
fns = fieldnames(in);
for i = 1:numel(fns)
    out.(fns{i}) = in.(fns{i});
end
end

function val = i_get_field(s, field_name, default_val)
if isfield(s, field_name)
    val = s.(field_name);
else
    val = default_val;
end
end

function mask = i_resolve_source_mask(zef, sens_cfg)
%I_RESOLVE_SOURCE_MASK Normalize cfg.sensitivity.source_mask to a logical
% column vector of length size(zef.source_positions, 1), or return [] when
% no mask was provided.

if ~isfield(sens_cfg, "source_mask") || isempty(sens_cfg.source_mask)
    mask = logical.empty(0, 1);
    return
end

sm = sens_cfg.source_mask;
n_full = size(zef.source_positions, 1);

if isa(sm, "function_handle")
    sm = sm(zef);
end

if islogical(sm)
    mask = sm(:);
    if numel(mask) ~= n_full
        error("zef_inverse_pipeline_run:BadSourceMaskLength", ...
            "source_mask length %d does not match size(zef.source_positions, 1) = %d.", ...
            numel(mask), n_full);
    end
elseif isnumeric(sm)
    sm = sm(:);
    if any(sm < 1) || any(sm > n_full) || any(sm ~= round(sm))
        error("zef_inverse_pipeline_run:BadSourceMaskIndex", ...
            "source_mask numeric indices must be positive integers in [1, %d].", n_full);
    end
    mask = false(n_full, 1);
    mask(sm) = true;
else
    error("zef_inverse_pipeline_run:BadSourceMaskType", ...
        "source_mask must be a function handle, logical vector, or numeric index list (got %s).", ...
        class(sm));
end
end
