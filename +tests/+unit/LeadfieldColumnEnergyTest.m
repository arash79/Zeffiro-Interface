classdef LeadfieldColumnEnergyTest < matlab.unittest.TestCase
%LEADFIELDCOLUMNENERGYTEST  Triplet vs per-column energy; mode 3 is not reshape-as-3.

    methods (Test)
        function interleavedTripletsMatchManual(testCase)
            rng(4);
            L = randn(11, 12);
            e = zef_leadfield_column_energy(L, 1);
            col = sum(L.^2, 1);
            ref = repelem(sum(reshape(col, 3, []), 1), 3);
            testCase.verifyEqual(e, max(ref, eps), 'RelTol', 1e-14);
            testCase.verifyEqual(numel(e), 12);
        end

        function mode3DoesNotGroupUnrelatedSources(testCase)
            rng(5);
            L = randn(10, 9);
            e3 = zef_leadfield_column_energy(L, 3);
            col = sum(L.^2, 1);
            wrong = repelem(sum(reshape(col, 3, []), 1), 3);
            testCase.verifyEqual(e3, max(col, eps), 'RelTol', 1e-14);
            testCase.verifyGreaterThan(max(abs(e3 - wrong)), 1e-8);
        end

        function mode1RejectsNonTripleCount(testCase)
            L = randn(8, 10);
            testCase.verifyError(@() zef_leadfield_column_energy(L, 1), ...
                'zef:LeadFieldNotTriplets');
        end

        function kalmanInitializeAcceptsSingleFrame(testCase)
            rng(6);
            L = randn(12, 12);
            f = randn(12, 1);
            inv = inverse.KalmanInverter("number_of_frames", 1, ...
                "number_of_noise_steps", 4);
            inv = inv.initialize(L, f, 1);
            testCase.verifyEqual(numel(inv.theta0), 12);
            testCase.verifyTrue(all(isfinite(inv.theta0)));
            testCase.verifyGreaterThan(min(inv.theta0), 0);
        end

        function kalmanMode3UsesPerColumnEnergy(testCase)
            rng(7);
            L = randn(9, 9);
            f = randn(9, 5);
            inv = inverse.KalmanInverter("number_of_frames", 3, ...
                "number_of_noise_steps", 3);
            inv = inv.initialize(L, f, 3);
            e = zef_leadfield_column_energy(L, 3);
            scale = inv.theta0(:).' .* e;
            testCase.verifyEqual(max(scale) / min(scale), 1, "RelTol", 1e-12);
            grouped = repelem(sum(reshape(sum(L.^2, 1), 3, []), 1), 3);
            testCase.verifyGreaterThan(max(abs(e - grouped)), 1e-8);
        end
    end
end
