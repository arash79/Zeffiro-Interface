function result = run_cluster_job_example(bundle_path, result_path, varargin)
%RUN_CLUSTER_JOB_EXAMPLE  Deprecated alias for run_inverse_job.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   result = run_cluster_job_example(bundle_path, result_path, varargin{:})
%
%   Emits a deprecation warning and forwards to run_inverse_job.

warning('utilities.cluster:Deprecated', ...
    ['run_cluster_job_example is deprecated. Use ', ...
    'utilities.cluster.run_inverse_job instead.']);

result = utilities.cluster.run_inverse_job(bundle_path, result_path, varargin{:});

end
