function result = run_cluster_job_example(bundle_path, result_path, varargin)
% --- Zeffiro documentation header ---
% utilities.cluster.run_cluster_job_example — Example or study script demonstrating run_cluster_job_example.
%
% Purpose:
%   Example or study script demonstrating run_cluster_job_example.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   bundle_path
%   result_path
%   varargin
%
% Outputs:
%   result
%
% Calls (project):
%   utilities.cluster.run_cluster_job_example
%   utilities.cluster.run_inverse_job
%
% Side effects:
%   - parallel/cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[result] = utilities.cluster.run_cluster_job_example(bundle_path, result_path, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

warning('utilities.cluster:Deprecated', ...
    ['run_cluster_job_example is deprecated. Use ', ...
    'utilities.cluster.run_inverse_job instead.']);

result = utilities.cluster.run_inverse_job(bundle_path, result_path, varargin{:});

end
