classdef FAToConductivityOrientationTest < matlab.unittest.TestCase
%FATOCONDUCTIVITYORIENTATIONTEST  FA→σ principal axis follows v1.

    methods (Test)
        function testModel3YAxisHasLargestEigenvalueAlongV1(testCase)
            fa = 0.5 * ones(1, 1, 1);
            v1 = zeros(1, 1, 1, 3);
            v1(:,:,:,2) = 1;
            T = zef_freesurfer_fa_to_conductivity(fa, 3, ...
                'scale_factor', 0.33, ...
                'anisotropy_threshold', 0.2, ...
                'principal_direction', v1);
            T = double(squeeze(T));
            sigma = [T(1) T(4) T(5); T(4) T(2) T(6); T(5) T(6) T(3)];
            [V, D] = eig(sigma);
            [lambda_max, k] = max(diag(D));
            axis = V(:, k);
            testCase.verifyGreaterThan(T(2), T(1));
            testCase.verifyGreaterThan(T(2), T(3));
            testCase.verifyEqual(abs(dot(axis, [0; 1; 0])), 1, "AbsTol", 1e-6);
            scale = 0.33;
            cl = zef_fa_to_westin_cl(0.5);
            testCase.verifyEqual(lambda_max, scale*(1 + 2*cl), "AbsTol", 1e-6);
        end

        function testMissingV1DefaultsToPlusX(testCase)
            fa = 0.6 * ones(1, 1, 1);
            T = zef_freesurfer_fa_to_conductivity(fa, 3, ...
                'scale_factor', 0.2, ...
                'anisotropy_threshold', 0.2);
            T = double(squeeze(T));
            testCase.verifyGreaterThan(T(1), T(2));
            testCase.verifyGreaterThan(T(1), T(3));
            testCase.verifyEqual(T(4), 0, "AbsTol", 1e-12);
        end

        function testFaIsConvertedToWestinClNotUsedAsAlpha(testCase)
            fa = 0.7;
            cl = zef_fa_to_westin_cl(fa);
            testCase.verifyEqual(cl, fa / sqrt(3 - 2*fa^2), "AbsTol", 1e-12);
            testCase.verifyLessThan(cl, fa);
            T = zef_freesurfer_fa_to_conductivity(fa*ones(1,1,1), 3, ...
                "scale_factor", 1, "anisotropy_threshold", 0.2, ...
                "principal_direction", reshape([1 0 0], 1, 1, 1, 3));
            T = double(squeeze(T));
            testCase.verifyEqual(T(1), 1 + 2*cl, "AbsTol", 1e-6);
            testCase.verifyEqual(T(2), 1 - cl, "AbsTol", 1e-6);
            testCase.verifyGreaterThan(abs(T(1) - (1 + 2*fa)), 0.1);
        end
    end
end
