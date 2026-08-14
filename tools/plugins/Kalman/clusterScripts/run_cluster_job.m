function result = run_cluster_job(bundle_path, result_path, profiler_on)
%RUN_CLUSTER_JOB  Deprecated wrapper around utilities.cluster.run_inverse_job.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Forwards bundle_path, result_path, EnableProfiler. Not the GUI
%   StartButton.
%

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
