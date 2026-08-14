function job = create_batch_job(cluster_profile, job_function, num_outputs, ...
    input_arguments, varargin)
%CREATE_BATCH_JOB  Submit a generic parallel.batch job with common options.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   job = create_batch_job(cluster_profile, job_function, num_outputs, ...
%       input_arguments, Name, Value, ...)
%
%   Wraps parallel.batch with optional CurrentFolder (default pwd),
%   AutoAddClientPath (false), Pool (0), and CaptureDiary (true). Prints job
%   ID, state, and function name to the command window.
%
%   Inputs
%     cluster_profile  - parallel.Cluster from configure_cluster_profile
%     job_function     - function handle run on the worker
%     num_outputs      - nargout requested from job_function
%     input_arguments  - cell of positional args forwarded to job_function
%     Name-Value       - CurrentFolder, AutoAddClientPath, Pool, CaptureDiary
%
%   See also utilities.cluster.dispatch_inverse, parallel.batch.

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
