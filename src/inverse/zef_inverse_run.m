function [zef, run_result] = zef_inverse_run(zef, method_id, opts)
%ZEF_INVERSE_RUN  Run a registered class inverter locally or on a MATLAB cluster.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Packs the current project into an inverse bundle, dispatches the method
%   named by method_id (see utilities.cluster.inverse_method_registry), and
%   writes reconstruction fields back onto zef. This is the programmatic
%   entry; most GUI inverse buttons still call legacy plugin iteration
%   functions instead.
%
%   [zef, run_result] = zef_inverse_run(zef, method_id)
%   [zef, run_result] = zef_inverse_run(zef, method_id, Name, Value, ...)
%
%   Inputs
%     zef        - session struct with lead field and measurements.
%     method_id  - nonempty string registry id (e.g. "eloreta", "mne", "kalman", "ukfnmm").
%     execution  - "local" (default) or "cluster".
%     MethodParams
%                - struct of inverter name-value fields, default struct().
%     ClusterProfile
%                - required when execution is "cluster"; profile name or object
%                  forwarded to utilities.cluster.submit_inverse_jobs.
%     WorkDir    - cluster working directory, default pwd.
%     BundleDir  - bundle output directory, default pwd/cluster_bundles.
%     ResultDir  - result directory, default pwd/cluster_results.
%     ComputeLocalizationMetrics
%                - logical, default false. When true, score the returned
%                  reconstruction against a true source (see TrueSource)
%                  and attach utilities.sensitivity.localization_metrics
%                  output to run_result.localization_metrics and
%                  zef.localization_metrics. Off by default; when off,
%                  behavior and outputs are unchanged.
%     TrueSource  - ground truth as N-by-(>=6) [x y z nx ny nz] or a
%                  struct('position', N-by-3, 'direction', N-by-3).
%                  Default [] resolves from zef.inv_synth_source; the
%                  run errors (MissingTrueSource) when neither exists.
%     DispersionRadius
%                - positive radius in mm for the dispersion metric.
%                  Default 30.
%
%   Outputs
%     zef         - input struct with reconstruction and
%                   reconstruction_information copied from run_result.
%     run_result  - dispatcher result struct. On cluster runs, field
%                   cluster_summary holds collect_inverse_results summary.
%
%   Failure
%     Errors if cluster execution is requested without ClusterProfile, or
%     if the collected cluster result is empty or unsuccessful.
%
%   See also zef_inverse_extract_bundle, utilities.cluster.dispatch_inverse,
%            utilities.cluster.inverse_method_registry.

arguments
    zef (1,1) struct
    method_id (1,1) string {mustBeNonempty}
    opts.execution (1,1) string {mustBeMember(opts.execution,["local","cluster"])} = "local"
    opts.MethodParams (1,1) struct = struct
    opts.ClusterProfile = []
    opts.WorkDir (1,1) string = string(pwd)
    opts.BundleDir (1,1) string = fullfile(string(pwd), "cluster_bundles")
    opts.ResultDir (1,1) string = fullfile(string(pwd), "cluster_results")
    opts.ComputeLocalizationMetrics (1,1) logical = false
    opts.TrueSource = []
    opts.DispersionRadius (1,1) double {mustBePositive} = 30
end

bundle = zef_inverse_extract_bundle(zef, method_id, "MethodParams", opts.MethodParams);

if opts.execution == "local"
    run_result = utilities.cluster.dispatch_inverse(bundle);
else
    if isempty(opts.ClusterProfile)
        error("zef_inverse_run:MissingClusterProfile", ...
            "opts.ClusterProfile is required for cluster execution.");
    end
    submissions = utilities.cluster.submit_inverse_jobs( ...
        opts.ClusterProfile, ...
        {bundle}, ...
        "WorkDir", opts.WorkDir, ...
        "BundleDir", opts.BundleDir, ...
        "ResultDir", opts.ResultDir ...
    );
    [results, summary] = utilities.cluster.collect_inverse_results(submissions);
    run_result = results{1};
    run_result.cluster_summary = summary;
    if isempty(run_result) || (~run_result.success)
        error("zef_inverse_run:ClusterExecutionFailed", ...
            "Cluster inverse execution failed.");
    end
end

zef.reconstruction = run_result.reconstruction;
zef.reconstruction_information = run_result.reconstruction_information;

% Optional source-localization accuracy metrics (off by default).
% Disabled runs are byte-identical to previous behavior: only the
% argument parsing above runs. Enabled runs additionally score the
% reconstruction peak against the given or session synthetic source and
% attach the result to run_result and zef as .localization_metrics.
if opts.ComputeLocalizationMetrics
    run_result.localization_metrics = local_compute_metrics( ...
        zef, run_result, opts);
    zef.localization_metrics = run_result.localization_metrics;
end

end

function metrics = local_compute_metrics(zef, run_result, opts)
%LOCAL_COMPUTE_METRICS  Resolve ground truth and score the reconstruction.

true_source = opts.TrueSource;
if isempty(true_source)
    if isfield(zef, "inv_synth_source") && ~isempty(zef.inv_synth_source)
        true_source = zef.inv_synth_source;
    else
        error("zef_inverse_run:MissingTrueSource", ...
            "Localization metrics were requested but no ground truth is " + ...
            "available. Pass TrueSource ([x y z nx ny nz]) or set " + ...
            "zef.inv_synth_source (e.g. via the Find synthetic source tool).");
    end
end
if ~isfield(zef, "source_positions") || isempty(zef.source_positions)
    error("zef_inverse_run:MissingSourcePositions", ...
        "Localization metrics need zef.source_positions (the interpolation source space).");
end
reconstruction = run_result.reconstruction;
if isempty(reconstruction)
    error("zef_inverse_run:EmptyReconstruction", ...
        "The %s run returned no reconstruction to score.", string(run_result.method_id));
end
metrics = utilities.sensitivity.localization_metrics( ...
    reconstruction, zef.source_positions, true_source, ...
    "DispersionRadius", opts.DispersionRadius);
metrics.method_id = string(run_result.method_id);
metrics.true_source = true_source;

end
