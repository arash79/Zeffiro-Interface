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

end
