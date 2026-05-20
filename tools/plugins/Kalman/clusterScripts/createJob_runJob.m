%CREATEJOB_RUNJOB Deprecated legacy entry point.
%
% This script has been migrated to utilities.cluster.examples.kalman_workflow.
% Example:
%
%   c = utilities.cluster.configure_cluster_profile("project_2002680");
%   zef_inputs = {zef}; % or multiple structs
%   submissions = utilities.cluster.examples.kalman_workflow(zef_inputs, c);
%
% See also:
%   utilities.cluster.examples.kalman_workflow
%   utilities.cluster.submit_inverse_jobs
%   utilities.cluster.collect_inverse_results

warning('plugins.Kalman.clusterScripts:Deprecated', ...
    ['createJob_runJob is deprecated. Use ', ...
     'utilities.cluster.examples.kalman_workflow instead.']);
