function [submissions, bundles] = eloreta_workflow(zef_inputs, cluster_profile, opts)
%ELORETA_WORKFLOW  Build eLORETA bundles and submit cluster inverse jobs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [submissions, bundles] = eloreta_workflow(zef_inputs, cluster_profile, opts)
%
%   zef_inputs is a struct array or cell of zef structs. Each entry is passed
%   to zef_inverse_extract_bundle with opts.MethodId (default "eloreta") and
%   opts.MethodParams, then batch-submitted via submit_inverse_jobs.

arguments
    zef_inputs
    cluster_profile (1,1) parallel.Cluster
    opts.MethodParams (1,1) struct = struct
    opts.MethodId (1,1) string = "eloreta"
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
