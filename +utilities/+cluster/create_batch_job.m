function job = create_batch_job(cluster_profile, job_function, num_outputs, ...
    input_arguments, varargin)
%CREATE_BATCH_JOB Create and submit a batch job to the cluster.
%
% This function creates a batch job on the specified cluster profile and
% submits it for execution. The job will run the specified function with
% the given input arguments on a remote worker.
%
% Inputs:
%   cluster_profile (parallel.Cluster, required)
%       Configured cluster profile object (e.g., from configure_cluster_profile).
%
%   job_function (function_handle, required)
%       Function handle to execute on the cluster worker.
%
%   num_outputs (double, required)
%       Number of output arguments expected from the job function.
%
%   input_arguments (cell array, required)
%       Cell array of input arguments to pass to the job function.
%
% Optional Name-Value Pairs:
%   'CurrentFolder' (string, default: pwd)
%       Working directory for the job execution.
%
%   'AutoAddClientPath' (logical, default: false)
%       Whether to automatically add the client MATLAB path to workers.
%       Set to false for cluster environments to avoid path conflicts.
%
%   'Pool' (double, default: 0)
%       Number of workers in a parallel pool for the job. Set to 0 for
%       sequential execution, or a positive number for parallel execution.
%
%   'CaptureDiary' (logical, default: true)
%       Whether to capture command window output (diary) from the job.
%
% Outputs:
%   job (parallel.job.CJSIndependentJob)
%       Batch job object that can be used to monitor and retrieve results.
%
% Example:
%   % Configure cluster
%   c = configure_cluster_profile('project_2002680');
%
%   % Create a batch job
%   job = create_batch_job(c, @my_function, 1, ...
%       {'input1', 'input2'}, ...
%       'CurrentFolder', '/scratch/project_2002680/my_work/', ...
%       'AutoAddClientPath', false);
%
%   % Wait for job to complete and fetch results
%   wait(job);
%   results = fetchOutputs(job);
%
% See also:
%   batch, configure_cluster_profile, wait, fetchOutputs

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
