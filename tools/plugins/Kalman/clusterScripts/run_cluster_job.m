function result = run_cluster_job(bundle_path, result_path, profiler_on)
% --- Zeffiro documentation header ---
% run_cluster_job — Run cluster job.
%
% Purpose:
%   Run cluster job.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   bundle_path
%   result_path
%   profiler_on
%
% Outputs:
%   result
%
% Calls (project):
%   utilities.cluster.run_inverse_job
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[result] = run_cluster_job(bundle_path, result_path, profiler_on)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin < 3
    profiler_on = false;
end

warning('plugins.Kalman.clusterScripts:Deprecated', ...
    ['run_cluster_job is deprecated. Use ', ...
     'utilities.cluster.run_inverse_job instead.']);

result = utilities.cluster.run_inverse_job( ...
    string(bundle_path), ...
    string(result_path), ...
    "EnableProfiler", logical(profiler_on) ...
);

end
