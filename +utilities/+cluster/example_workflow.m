%EXAMPLE_WORKFLOW Bundle-based cluster inverse workflow.
%
% Prerequisites:
% 1) Run CSC `configCluster` once.
% 2) Load or build a `zef` struct in MATLAB workspace.
%
% This script demonstrates the new workflow:
%   configure profile -> extract bundle -> submit -> collect.

% Step 1: configure CSC profile
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
