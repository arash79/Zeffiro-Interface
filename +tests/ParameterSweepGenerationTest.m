classdef ParameterSweepGenerationTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.ParameterSweepGenerationTest — Automated test: ParameterSweepGenerationTest.
%
% Purpose:
%   Automated test: ParameterSweepGenerationTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Calls (project):
%   utilities.cluster.examples.parameter_sweep
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.ParameterSweepGenerationTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testParameterSweepSubmissionShape(testCase)
            c = parcluster;
            testCase.assumeTrue(isprop(c.AdditionalProperties, 'ComputingProject'), ...
                'Skipping: requires CSC generic cluster profile.');

            zef = tests.createSyntheticInverseZef();
            sweep = struct( ...
                "noise_level_vec", [20 30], ...
                "evolution_prior_vec", [10 20], ...
                "pm_snr_vec", [0] ...
            );

            [submissions, bundles] = utilities.cluster.examples.parameter_sweep( ...
                zef, c, sweep, "MethodId", "dspm");

            testCase.verifyEqual(numel(bundles), 4);
            testCase.verifyEqual(numel(submissions), 4);
        end
    end

end
