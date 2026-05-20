classdef ClusterRunnerTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.ClusterRunnerTest — Automated test: ClusterRunnerTest.
%
% Purpose:
%   Automated test: ClusterRunnerTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Calls (project):
%   utilities.cluster.run_inverse_job
%   zef_inverse_extract_bundle
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.ClusterRunnerTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testRunInverseJobWritesResultFile(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");

            tmp_dir = fullfile(tempdir, "zi_cluster_runner_test");
            if ~isfolder(tmp_dir)
                mkdir(tmp_dir);
            end
            bundle_path = fullfile(tmp_dir, "bundle.mat");
            result_path = fullfile(tmp_dir, "result.mat");
            save(bundle_path, "bundle");

            result = utilities.cluster.run_inverse_job(bundle_path, result_path);

            testCase.verifyTrue(result.success);
            testCase.verifyTrue(isfile(result_path));
        end
    end

end
