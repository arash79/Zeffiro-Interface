function [zef, run_result] = zef_inverse_run(zef, method_id, opts)
%ZEF_INVERSE_RUN Run inverse computation locally or on cluster.

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
