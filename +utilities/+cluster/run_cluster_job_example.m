function result = run_cluster_job_example(bundle_path, result_path, varargin)
%RUN_CLUSTER_JOB_EXAMPLE Backward-compatible wrapper for run_inverse_job.
%
% Deprecated. Use utilities.cluster.run_inverse_job directly.

warning('utilities.cluster:Deprecated', ...
    ['run_cluster_job_example is deprecated. Use ', ...
    'utilities.cluster.run_inverse_job instead.']);

result = utilities.cluster.run_inverse_job(bundle_path, result_path, varargin{:});

end
