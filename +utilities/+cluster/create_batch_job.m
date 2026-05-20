function job = create_batch_job(cluster_profile, job_function, num_outputs, ...
% --- Zeffiro documentation header ---
% utilities.cluster.job — Job.
%
% Purpose:
%   Job.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   cluster_profile
%   job_function
%   num_outputs
%   input_arguments
%
% Calls (project):
%   utilities.cluster.create_batch_job
%
% Side effects:
%   - parallel/cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.cluster.job(cluster_profile, job_function, num_outputs, input_arguments)` with project root and `src` on the path.
% --- End Zeffiro documentation header
    input_arguments, varargin)

arguments
    cluster_profile (1,1) parallel.Cluster
    job_function (1,1) function_handle
    num_outputs (1,1) double {mustBeInteger, mustBeNonnegative}
    input_arguments (1,:) cell
end

arguments (Repeating)
    varargin
end

% Parse optional parameters
p = inputParser;
addParameter(p, 'CurrentFolder', pwd, @(x) isstring(x) || ischar(x));
addParameter(p, 'AutoAddClientPath', false, @islogical);
addParameter(p, 'Pool', 0, @(x) isnumeric(x) && isscalar(x) && x >= 0);
addParameter(p, 'CaptureDiary', true, @islogical);
parse(p, varargin{:});

% Convert CurrentFolder to char if it's a string
current_folder = p.Results.CurrentFolder;
if isstring(current_folder)
    current_folder = char(current_folder);
end

% Create and submit the batch job
job = batch(cluster_profile, job_function, num_outputs, ...
    input_arguments, ...
    'CurrentFolder', current_folder, ...
    'AutoAddClientPath', p.Results.AutoAddClientPath, ...
    'Pool', p.Results.Pool, ...
    'CaptureDiary', p.Results.CaptureDiary);

fprintf('Batch job created and submitted.\n');
fprintf('  Job ID: %d\n', job.ID);
fprintf('  Status: %s\n', job.State);
fprintf('  Function: %s\n', func2str(job_function));

end
