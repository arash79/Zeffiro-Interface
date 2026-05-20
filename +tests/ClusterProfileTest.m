classdef ClusterProfileTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.ClusterProfileTest — Automated test: ClusterProfileTest.
%
% Purpose:
%   Automated test: ClusterProfileTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Calls (project):
%   utilities.cluster.configure_cluster_profile
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.ClusterProfileTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testConfigureClusterProfileSetsCscFields(testCase)
            c = parcluster;
            testCase.assumeTrue(isprop(c.AdditionalProperties, 'ComputingProject'), ...
                'CSC Generic profile is not active in this environment.');

            c = utilities.cluster.configure_cluster_profile( ...
                "project_test", ...
                "MemPerCPU", "8g", ...
                "WallTime", "00:10:00", ...
                "Partition", "test", ...
                "NumThreads", 1 ...
            );

            testCase.verifyEqual(string(c.AdditionalProperties.ComputingProject), "project_test");
            testCase.verifyEqual(string(c.AdditionalProperties.MemPerCPU), "8g");
            testCase.verifyEqual(string(c.AdditionalProperties.WallTime), "00:10:00");
        end
    end

end
