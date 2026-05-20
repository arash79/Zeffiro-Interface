% --- Zeffiro documentation header ---
% utilities.cluster.cluster = utilities.cluster.configure_cluster_profile( ... — Example or study script demonstrating cluster = utilities.cluster.configure_cluster_profile( .
%
% Purpose:
%   Example or study script demonstrating cluster = utilities.cluster.configure_cluster_profile( ....
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Calls (project):
%   utilities.cluster.collect_inverse_results
%   utilities.cluster.submit_inverse_jobs
%   zef_inverse_extract_bundle
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `utilities.cluster.cluster = utilities.cluster.configure_cluster_profile( ...` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
