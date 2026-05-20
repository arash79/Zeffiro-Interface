function [zef, output] = zef_inverse_pipeline_run(zef, cfg)
%ZEF_INVERSE_PIPELINE_RUN Run a configured inverse + sensitivity pipeline.
%
%   [zef, output] = zef_inverse_pipeline_run(zef, cfg)
%
% Pure-function form of the legacy run_inverse_script.m. No base-workspace
% reads or writes: the caller passes a zef struct (with a built lead field
% and non-empty zef.measurements) plus a configuration struct, and gets
% back the (possibly slightly mutated) zef and a results struct shaped as
%
%   output.config         % the cfg actually used (after defaults merge)
%   output.timestamp      % datetime("now") at start
%   output.inverse.<key>  % .zef / .run / .seconds / .registry_id (or .err)
%   output.sensitivity.<key>
%                         % .method_id / .statistics / .L / .strategy /
%                         % .seconds (or .err)
%
% which is exactly the shape that run_inverse_script.m used to assignin
% under the variable name 'inverse_pipeline_output'.
%
% cfg fields (all optional - any missing field falls back to the same
% defaults that the legacy script used):
%
%   execution        : "local" | "cluster"          (default "local")
%   run_inverse      : logical                      (default true)
%   run_sensitivity  : logical                      (default true)
%   methods          : cell array (Nx3) of rows
%                      {key, registry_id, methodParams}; see the comment
%                      block below for the full menu of solvers and
%                      method-specific parameters.
%                      (default: sLORETA + dipolescan, the two rows that
%                       run_inverse_script.m enabled out of the box.)
%   inv_snr_db       : double                       (default 30)
%   number_of_frames : double                       (default 1)
%   sensitivity      : struct with fields
%                          n_of_runs, noise_level_db, diff_type,
%                          dispersion_radius, isolated_frames_per_probe,
%                          max_probes_per_batch, source_mask (optional).
%                      max_probes_per_batch bounds memory for static
%                      sensitivity dispatches; dispersion is still computed
%                      over the full selected source set after chunking.
%                      source_mask, if present, restricts which sources
%                      are probed by the sensitivity stage. Accepted
%                      forms:
%                        - empty (default): probe every active brain
%                          source returned by zef_processLeadfields.
%                        - logical column of length
%                          size(zef.source_positions, 1).
%                        - numeric index list (1-based) into
%                          zef.source_positions.
%                        - function handle @(zef) -> mask, evaluated on
%                          the local zef just before the sensitivity
%                          call. Useful when callers do not know
%                          n_full ahead of time (e.g. the high-level
%                          wrapper opens the project internally).
%                      Forwarded to zef_sensitivity_run as 'SourceMask'.
%                      Particularly important for stateful_dynamic
%                      methods (Kalman family) where each probe is its
%                      own isolated dispatch and probing all active
%                      sources can take hours.
%   cluster          : struct with fields
%                          project, MemPerCPU, WallTime, Partition,
%                          NumThreads. Only used when execution=="cluster".
%
% =========================================================================
% SOLVER MENU (kept here so the documentation lives next to the dispatch
% loop, exactly like the legacy script did):
% =========================================================================
% One row per solver: {key, registry_id, methodParams}
%   - key          short identifier used in the output struct
%                  (output.inverse.(key) and output.sensitivity.(key)).
%   - registry_id  the id resolved by
%                  utilities.cluster.inverse_method_registry. The same id
%                  is consumed by both zef_inverse_run and zef_sensitivity_run.
%   - methodParams struct of method-specific overrides forwarded to the
%                  inverter constructor; only the field names that match
%                  inverter properties are honoured.
%
% The solver capability for the sensitivity stage is resolved by
% utilities.sensitivity.method_capability:
%   - linear_static     : per-frame is T*f with cached operator.
%   - iterative_static  : per-frame independent but iterative.
%                         Static methods use bounded probe batches and
%                         stitch the metrics back together before
%                         aggregation, avoiding monolithic all-source
%                         reconstruction matrices.
%   - stateful_dynamic  : Kalman-family; sensitivity uses isolated dispatch
%                         (one inversion per probe, ~T_KF frames each).
%   - unsupported       : sensitivity stage will error with a clear message.
%
% Example rows (commented out - copy and edit into your cfg.methods):
%
% % ---- Default active rows (the two rows kept on by the legacy script).
% "sloreta",       "sloreta",      struct("method_type","sLORETA","theta0",1e-3)
% "dipolescan",    "dipolescan",   struct("method_type","SVD","reg_type","None","reg_parameter",1e-3)
%
% % ---- CSM family (linear_static): sLORETA / dSPM / sLORETA-3D / SBL ----
% % "csm",         "csm",          struct("method_type","sLORETA","theta0",1e-3)
% % "dspm",        "dspm",         struct("method_type","dSPM","theta0",1e-3)
% % "sloreta3d",   "sloreta3d",    struct("method_type","sLORETA 3D","theta0",1e-3)
% % "sbl",         "sbl",          struct("method_type","Sparse Bayesian learning","theta0",1e-3)
%
% % ---- MNE / wMNE (linear_static) ---------------------------------------
% % "mne",         "mne",          struct("theta",[],"noise_cov",[],"initial_prior_steering_db",0)
% % "wmne",        "wmne",         struct("theta",[],"noise_cov",[],"initial_prior_steering_db",0)
%
% % ---- eLORETA (linear_static, iterative precompute) --------------------
% % "eloreta",     "eloreta",      struct("regularization_parameter",[],"noise_cov",[],"n_max_iterations",200,"convergence_tolerance",1e-6,"apply_average_reference",true)
%
% % ---- Beamformer (iterative_static) ------------------------------------
% % "beamformer_lcmv", "beamformer", struct("method_type","Linearly constrained minimum variance (LCMV) beamformer","cov_reg_parameter",0.05,"leadfield_reg_parameter",1e-3,"leadfield_reg_type","Basic","leadfield_normalization","None","error_cov",[])
% % "beamformer_ung",  "beamformer", struct("method_type","Unit noise gain (UNG) beamformer","cov_reg_parameter",0.05,"leadfield_reg_parameter",1e-3,"leadfield_reg_type","Basic","leadfield_normalization","None","error_cov",[])
% % "beamformer_ugc",  "beamformer", struct("method_type","Unit-gain constrained beamformer","cov_reg_parameter",0.05,"leadfield_reg_parameter",1e-3,"leadfield_reg_type","Basic","leadfield_normalization","None","error_cov",[])
%
% % ---- IAS (iterative_static) -------------------------------------------
% % "ias",         "ias",          struct("method_type","None","hyperprior","Inverse gamma","hyperprior_mode","Constant","n_map_iterations",25,"amplitude_db",20,"prior_over_measurement_db",20)
%
% % ---- RAMUS (iterative_static; multiresolution + IAS per frame) --------
% % NOTE: zef_sensitivity_run auto-builds the multiresolution decomposition
% % via the "ramus_decomposition" preflight hook if multiresolution_dec is
% % empty. Outside the sensitivity pipeline call inverter.make_multires_dec()
% % yourself before zef_inverse_run.
% % "ramus",       "ramus",        struct("number_of_decompositions",20,"number_of_multiresolution_levels",3,"sparsity_factor",10,"n_map_iterations",10,"hyperprior","Inverse gamma","method_type","None")
%
% % ---- HALpR / SHALpR (iterative_static) --------------------------------
% % NOTE: when use_multiresolution=true, zef_sensitivity_run auto-builds
% % the decomposition via the "halpr_decomposition" preflight hook.
% % "halpr",       "halpr",        struct("estimation_type","IAS","q",1,"beta",3,"theta0",1e-10,"hyperprior_mode","Sensitivity weighted","n_map_iterations",25,"n_L1_iterations",5,"use_multiresolution",false)
% % "shalpr",      "halpr",        struct("estimation_type","Standardized","q",1,"beta",3,"theta0",1e-10,"hyperprior_mode","Sensitivity weighted","n_map_iterations",25,"n_L1_iterations",5,"use_multiresolution",false)
%
% % ---- Group Lasso (iterative_static) -----------------------------------
% % NOTE: when use_multiresolution=true, zef_sensitivity_run auto-builds
% % the decomposition via the "grouplasso_decomposition" preflight hook.
% % "grouplasso",  "grouplasso",   struct("estimation_type","IAS","beta",3,"theta0",1e-10,"hyperprior_mode","Sensitivity weighted","n_map_iterations",25,"n_L1_iterations",5,"use_multiresolution",false)
%
% % ---- Kalman family (stateful_dynamic) ---------------------------------
% % WARNING: Kalman is a time-series filter. The sensitivity stage runs
% % each (source, direction) probe in isolation across IsolatedFramesPerProbe
% % frames (default 4) with fresh noise per frame, then takes the final
% % reconstruction. Set cfg.sensitivity.noise_level_db < 0 (default -30 is
% % fine); a noise-free synthesis would leave the Kalman variance prior
% % degenerate.
% % "kalman_basic",     "kalman", struct("method_type","Basic Kalman filter","evolution_prior_model","Sensitivity scaling","evolution_prior_db",0,"initial_prior_steering_db",0,"number_of_noise_steps",2,"use_smoothing",false,"smoother_type","None")
% % "kalman_standard",  "kalman", struct("method_type","Standardized Kalman filter","evolution_prior_model","Sensitivity scaling","evolution_prior_db",0,"initial_prior_steering_db",0,"number_of_noise_steps",2,"use_smoothing",false,"smoother_type","None")
% % "kalman_approx",    "kalman", struct("method_type","Approximated Standardized Kalman filter","evolution_prior_model","Sensitivity scaling","evolution_prior_db",0,"initial_prior_steering_db",0,"number_of_noise_steps",2,"use_smoothing",false,"smoother_type","None")
% % "kalman_ensembled", "kalman", struct("method_type","Ensembled Kalman filter","evolution_prior_model","Reworked original","number_of_ensembles",100,"evolution_prior_db",0,"initial_prior_steering_db",0,"number_of_noise_steps",2,"use_smoothing",false,"smoother_type","None")

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
