%EXAMPLE_WORKFLOW  End-to-end cluster inverse: configure, submit, collect.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script outline: configure_cluster_profile → zef_inverse_extract_bundle →
%   submit_inverse_jobs → collect_inverse_results. Requires base-workspace zef
%   and a configured parallel cluster (e.g. CSC Puhti).

cluster = utilities.cluster.configure_cluster_profile( ...
    "project_2002680", ...
    "MemPerCPU", "8g", ...
    "WallTime", "24:00:00", ...
    "Partition", "small", ...
    "NumThreads", 1 ...
);

% Step 2: build one or more bundles
bundle = zef_inverse_extract_bundle(zef, "dspm");

% Step 3: submit jobs
submissions = utilities.cluster.submit_inverse_jobs(cluster, {bundle});

% Step 4: collect results
[results, summary] = utilities.cluster.collect_inverse_results(submissions);

disp(summary);
disp(results{1}.reconstruction_information);
