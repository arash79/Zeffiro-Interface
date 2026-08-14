classdef ParameterSweepGenerationTest < matlab.unittest.TestCase
%PARAMETERSWEEPGENERATIONTEST  Cluster parameter sweep submits four bundles.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Skips unless parcluster has ComputingProject (CSC). Builds a small
%   sweep struct on synthetic zef and asserts the submission shape is 4
%   jobs. See +tests/README.md.
%

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
