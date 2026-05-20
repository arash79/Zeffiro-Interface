classdef ParameterSweepGenerationTest < matlab.unittest.TestCase

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
