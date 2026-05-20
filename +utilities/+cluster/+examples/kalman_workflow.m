function [submissions, bundles] = kalman_workflow(zef_inputs, cluster_profile, opts)
%KALMAN_WORKFLOW Example migration of legacy Kalman cluster scripts.
%
% Inputs:
%   zef_inputs - struct array or cell array of zef structs.
%   cluster_profile - configured parallel.Cluster profile.

arguments
    zef_inputs
    cluster_profile (1,1) parallel.Cluster
    opts.MethodParams (1,1) struct = struct
    opts.MethodId (1,1) string = "kalman"
    opts.WorkDir (1,1) string = string(pwd)
    opts.BundleDir (1,1) string = fullfile(string(pwd), "cluster_bundles")
    opts.ResultDir (1,1) string = fullfile(string(pwd), "cluster_results")
end

if isstruct(zef_inputs)
    zef_cell = num2cell(zef_inputs);
elseif iscell(zef_inputs)
    zef_cell = zef_inputs;
else
    error("utilities.cluster.examples:InvalidInput", ...
        "zef_inputs must be a struct array or a cell array of structs.");
end

bundles = cell(1, numel(zef_cell));
for i = 1:numel(zef_cell)
    bundles{i} = zef_inverse_extract_bundle( ...
        zef_cell{i}, ...
        opts.MethodId, ...
        "MethodParams", opts.MethodParams ...
    );
end

submissions = utilities.cluster.submit_inverse_jobs( ...
    cluster_profile, ...
    bundles, ...
    "WorkDir", opts.WorkDir, ...
    "BundleDir", opts.BundleDir, ...
    "ResultDir", opts.ResultDir ...
);

end
