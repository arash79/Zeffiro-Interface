function [stats, run_result] = zef_sensitivity_run(zef, method_id, opts)
%ZEF_SENSITIVITY_RUN Monte-Carlo sensitivity study for an inverse method.
%
%   [stats, run_result] = zef_sensitivity_run(zef, method_id, opts)
%
% Public top-level entry that mirrors the shape of m/inverse/zef_inverse_run.m.
% It builds synthetic dipole-scan measurements in bounded batches, dispatches
% them through zef_inverse_run, stitches each realisation's metric vectors in
% source/probe order, then aggregates per-realisation metrics into the same
% struct shape as the legacy +examples/+studies/+santtus_peeling_article/main.m.
%
% This function does not depend on, and is not depended on by, any code
% under +examples/. It is the in-codebase replacement for the example-based
% sensitivity workflow that run_inverse_script.m previously called.
%
% Solver compatibility:
%   The pipeline routes each method through utilities.sensitivity.method_capability:
%     - linear_static / iterative_static -> bounded batched dispatches per
%       realisation; metrics are stitched in the same source/probe order and
%       the full-run dispersion metric is recomputed after chunking.
%     - stateful_dynamic (Kalman family) -> one isolated dispatch per probe
%       with IsolatedFramesPerProbe frames and a fresh inverter (slower, but
%       each (source, direction) starts from a clean state).
%     - unsupported -> rejected up front with a clear error message.
%
% Inputs:
%   zef                     Project struct containing a built lead field
%                           (zef.L), source positions, source interpolation
%                           data, and the inv_* fields zef_inverse_run reads.
%   method_id               Inverse method id from
%                           utilities.cluster.inverse_method_registry (for
%                           example "sloreta" or "dipolescan").
%   opts.MethodParams       Method-specific parameter struct (forwarded).
%   opts.execution          "local" | "cluster".
%   opts.ClusterProfile     parallel.Cluster or [].
%   opts.NumberOfRuns       Monte-Carlo realisations (default 1).
%   opts.NoiseLevelDb       Additive noise level for synthetic measurements
%                           in dB, <= 0 (default -30, matching the legacy
%                           examples.studies.santtus_peeling_article path).
%   opts.DiffType           "L2" | "minabs" position-error metric.
%   opts.DispersionRadius   Radius (mm) for the dispersion ROI.
%   opts.SourceAmplitude    Synthetic source amplitude in nAm-equivalent
%                           units (default 10, matching
%                           zef_rec_diff's inv_synth_source(7)).
%   opts.SourceMask         Logical mask of length size(zef.source_positions, 1).
%                           Default: probe every active brain source returned
%                           by zef_processLeadfields(zef) (procFile.s_ind_0).
%                           User-supplied masks are intersected with the
%                           active set.
%   opts.MaxProbesPerBatch  Upper bound for probes in one static-method
%                           dispatch (default 1000).
%
% Outputs:
%   stats        Struct with the per-realisation cells (dist_vec, angle_vec,
%                mag_vec, dispersion_vec) and the aggregated mean / std
%                (dist_vec_avg, dist_vec_std, ...). Field names match the
%                legacy add_statistics_to_struct output so any downstream
%                code that consumed examples.studies.santtus_peeling_article.main
%                continues to work.
%   run_result   Struct with the lead field used (.L), the resolved method
%                id, the source-index list, the per-realisation metric
%                structs, and lightweight per-realisation execution
%                summaries.

arguments
    zef (1,1) struct
    method_id (1,1) string {mustBeNonempty}
    opts.MethodParams (1,1) struct = struct
    opts.execution (1,1) string {mustBeMember(opts.execution,["local","cluster"])} = "local"
    opts.ClusterProfile = []
    opts.NumberOfRuns (1,1) double {mustBeInteger, mustBePositive} = 1
    opts.NoiseLevelDb (1,1) double {mustBeNonpositive} = -30
    opts.DiffType (1,1) string {mustBeMember(opts.DiffType,["L2","minabs"])} = "L2"
    opts.DispersionRadius (1,1) double {mustBePositive} = 30
    opts.SourceAmplitude (1,1) double = 10
    opts.SourceMask (:,1) logical = logical.empty(0, 1)
    opts.IsolatedFramesPerProbe (1,1) double {mustBeInteger, mustBePositive} = 4
    opts.MaxProbesPerBatch (1,1) double {mustBeInteger, mustBePositive} = 1000
end

if ~isfield(zef, "L") || isempty(zef.L)
    error("zef_sensitivity_run:NoLeadField", ...
        "zef.L is missing or empty. Build the EEG lead field before running the sensitivity study.");
end

if ~isfield(zef, "source_positions") || isempty(zef.source_positions)
    error("zef_sensitivity_run:NoSourcePositions", ...
        "zef.source_positions is missing or empty.");
end

% ----- Solver capability gate ---------------------------------------------
capability = utilities.sensitivity.method_capability(method_id);
if capability.strategy == "unsupported"
    error("zef_sensitivity_run:UnsupportedMethod", ...
        "Method '%s' is not supported by the sensitivity pipeline. %s", ...
        method_id, capability.notes);
end

% ----- Resolve active source set via the standard inverse pre-processing.
% zef_processLeadfields applies the same visibility / source-mode rules the
% inverse stage uses, so we always probe the same set of sources the inverter
% can actually reconstruct into.
[~, n_interp, procFile] = zef_processLeadfields(zef);
active_source_inds = procFile.s_ind_0(:);
n_full = size(zef.source_positions, 1);

if isempty(opts.SourceMask)
    source_indices = active_source_inds;
else
    if numel(opts.SourceMask) ~= n_full
        error("zef_sensitivity_run:BadMask", ...
            "SourceMask length %d must equal size(zef.source_positions, 1) = %d.", ...
            numel(opts.SourceMask), n_full);
    end
    source_indices = intersect(find(opts.SourceMask), active_source_inds);
end

if isempty(source_indices)
    error("zef_sensitivity_run:EmptyMask", ...
        "SourceMask intersected with the active source set is empty; nothing to probe.");
end

if procFile.source_direction_mode == 3
    n_probes = numel(source_indices);
else
    n_probes = 3 * numel(source_indices);
end
fprintf(2, '    [sensitivity %s] selected %d active source(s), %d probe(s), %d Monte-Carlo run(s), max %d probe(s)/batch\n', ...
    char(method_id), numel(source_indices), n_probes, opts.NumberOfRuns, opts.MaxProbesPerBatch);

% ----- Run any registered preflight hooks (RAMUS / HALpR / GroupLasso). ---
% Hooks may mutate opts.MethodParams (for example to inject a freshly built
% multiresolution decomposition) so the dispatcher receives a fully prepared
% inverter configuration.
opts.MethodParams = i_run_prep_hooks(zef, capability, opts.MethodParams, n_interp);

% ----- Monte-Carlo loop ---------------------------------------------------
mc = utilities.sensitivity.run_monte_carlo( ...
    zef, method_id, ...
    "Capability",       capability, ...
    "ProcFile",         procFile, ...
    "NInterp",          n_interp, ...
    "SourceIndices",    source_indices, ...
    "MethodParams",     opts.MethodParams, ...
    "execution",        opts.execution, ...
    "ClusterProfile",   opts.ClusterProfile, ...
    "NumberOfRuns",     opts.NumberOfRuns, ...
    "NoiseLevelDb",     opts.NoiseLevelDb, ...
    "DiffType",         opts.DiffType, ...
    "DispersionRadius", opts.DispersionRadius, ...
    "SourceAmplitude",  opts.SourceAmplitude, ...
    "IsolatedFramesPerProbe", opts.IsolatedFramesPerProbe, ...
    "MaxProbesPerBatch", opts.MaxProbesPerBatch);

stats = utilities.sensitivity.aggregate_statistics(mc.runs);
stats.method_id = method_id;
stats.source_indices = source_indices;
stats.strategy = capability.strategy;

run_result = struct( ...
    "L",              zef.L, ...
    "method_id",      method_id, ...
    "strategy",       capability.strategy, ...
    "source_indices", source_indices, ...
    "procFile",       procFile, ...
    "runs",           {mc.runs}, ...
    "run_results",    {mc.run_results});

end

% =========================================================================
% Helper: dispatch any preflight hooks declared in method_capability.
% =========================================================================
function method_params = i_run_prep_hooks(zef, capability, method_params, n_interp)

for h = 1:numel(capability.prep_hooks)
    hook = capability.prep_hooks(h);
    switch hook
        case "ramus_decomposition"
            method_params = i_ramus_preflight(zef, method_params, n_interp);

        case "halpr_decomposition"
            if i_field_or_default(method_params, "use_multiresolution", false)
                method_params = i_multires_preflight(zef, method_params, n_interp, "HALpR");
            end

        case "grouplasso_decomposition"
            if i_field_or_default(method_params, "use_multiresolution", false)
                method_params = i_multires_preflight(zef, method_params, n_interp, "GroupLasso");
            end

        otherwise
            warning("zef_sensitivity_run:UnknownPrepHook", ...
                "Capability hook '%s' is not implemented; skipping.", hook);
    end
end

end

function method_params = i_ramus_preflight(zef, method_params, n_interp)
%I_RAMUS_PREFLIGHT Auto-build the multiresolution decomposition for RAMUS.

if i_field_nonempty(method_params, "multiresolution_dec")
    return
end

n_dec = double(i_field_or_default(method_params, "number_of_decompositions", 20));
n_lev = double(i_field_or_default(method_params, "number_of_multiresolution_levels", 3));
sparsity = double(i_field_or_default(method_params, "sparsity_factor", 10));

method_params = i_invoke_make_multires(zef, method_params, n_dec, n_lev, sparsity, ...
    "RAMUS", n_interp);

end

function method_params = i_multires_preflight(zef, method_params, n_interp, label)
%I_MULTIRES_PREFLIGHT Auto-build the multiresolution decomposition for HALpR / GroupLasso.

if i_field_nonempty(method_params, "multiresolution_dec")
    return
end

n_dec = double(i_field_or_default(method_params, "multiresolution_decomposition_number", 10));
n_lev = double(i_field_or_default(method_params, "multiresolution_levels_number", 10));
sparsity = double(i_field_or_default(method_params, "multiresolution_sparsity_factor", 10));

method_params = i_invoke_make_multires(zef, method_params, n_dec, n_lev, sparsity, ...
    label, n_interp);

end

function method_params = i_invoke_make_multires(zef, method_params, n_dec, n_lev, sparsity, label, n_interp)
%I_INVOKE_MAKE_MULTIRES Wrap zef_make_multires_dec inside with_zef_in_base.

% zef_make_multires_dec reads zef.source_interpolation_ind and
% zef.source_positions out of the base workspace (legacy convention).
% with_zef_in_base temporarily binds our local zef there, then restores the
% previous binding.
fprintf("[sensitivity] %s: auto-building multiresolution decomposition (n_dec=%d, n_levels=%d, sparsity=%g, n_active=%d) ...\n", ...
    label, n_dec, n_lev, sparsity, n_interp);

[mr_dec, mr_ind, mr_count] = utilities.cluster.with_zef_in_base(zef, ...
    @() zef_make_multires_dec(n_dec, n_lev, sparsity));

method_params.multiresolution_dec   = mr_dec;
method_params.multiresolution_ind   = mr_ind;
method_params.multiresolution_count = mr_count;

end

function val = i_field_or_default(s, name, default_val)
if isfield(s, name)
    val = s.(name);
else
    val = default_val;
end
end

function tf = i_field_nonempty(s, name)
tf = isfield(s, name) && ~isempty(s.(name));
end
