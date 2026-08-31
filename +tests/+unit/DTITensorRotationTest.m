classdef DTITensorRotationTest < matlab.unittest.TestCase
%DTITENSORROTATIONTEST  Packed σ is rotated into the mesh frame.

    methods (Test)
        function testRowAffineConvertedToColumn(testCase)
            T_row = eye(4);
            T_row(4, 1:3) = [10, 20, 30];
            T_col = zef_dti_as_column_affine(T_row);
            testCase.verifyEqual(T_col(1:3, 4)', [10, 20, 30], "AbsTol", 1e-15);
            testCase.verifyEqual(T_col(4, 1:3), [0 0 0], "AbsTol", 1e-15);
            T_already = zef_dti_as_column_affine(T_col);
            testCase.verifyEqual(T_already, T_col);
        end

        function testPackedRotation90DegAboutZ(testCase)
            sigma_vox = [2, 0.1, 0.1, 0, 0, 0];
            R = [0 -1 0; 1 0 0; 0 0 1];
            out = zef_dti_rotate_packed_sigma(sigma_vox, R);
            S = [out(1) out(4) out(5); out(4) out(2) out(6); out(5) out(6) out(3)];
            [V, D] = eig(S);
            [~, k] = max(diag(D));
            axis = V(:, k);
            testCase.verifyEqual(abs(dot(axis, [0; 1; 0])), 1, "AbsTol", 1e-10);
            testCase.verifyEqual(max(diag(D)), 2, "AbsTol", 1e-12);
        end

        function testInterpolatorRotatesPrincipalAxis(testCase)
            fa_tensor = zeros(3, 3, 3, 6);
            fa_tensor(:, :, :, 1) = 2;
            fa_tensor(:, :, :, 2) = 0.1;
            fa_tensor(:, :, :, 3) = 0.1;
            T_nifti = eye(4);
            T_nifti(1:3, 1:3) = [0 -1 0; 1 0 0; 0 0 1];
            info = struct("Transform", struct("T", T_nifti));
            centroids = [2 2 2];
            out = zef_dti_tensor_interpolate_mesh_space( ...
                centroids, fa_tensor, info, eye(4), 0.14, 1, "nearest", []);
            S = [out(1) out(4) out(5); out(4) out(2) out(6); out(5) out(6) out(3)];
            [V, D] = eig(double(S));
            [~, k] = max(diag(D));
            axis = V(:, k);
            testCase.verifyEqual(abs(dot(axis, [0; 1; 0])), 1, "AbsTol", 1e-8);
        end

        function testMesh2VoxelZeroBasedPlusOneHitsVoxelOne(testCase)
            fa_tensor = zeros(3, 3, 3, 6);
            fa_tensor(1, 1, 1, 1) = 5;
            fa_tensor(1, 1, 1, 2) = 5;
            fa_tensor(1, 1, 1, 3) = 5;
            fa_tensor(2, 2, 2, 1) = 9;
            info = struct("Transform", struct("T", eye(4)));
            T_mesh2voxel = eye(4);
            out = zef_dti_tensor_interpolate_mesh_space( ...
                [0 0 0], fa_tensor, info, eye(4), 0.14, 1, "nearest", [], T_mesh2voxel);
            testCase.verifyEqual(double(out(1)), 5, "AbsTol", 1e-6);
            testCase.verifyEqual(double(out(2)), 5, "AbsTol", 1e-6);
        end

        function testExpandCovarianceUsesBlockedKronecker(testCase)
            Qs = [1 0.5; 0.5 1];
            Q = zef_dti_expand_source_covariance(Qs, 1);
            testCase.verifyEqual(size(Q), [6 6]);
            testCase.verifyEqual(full(Q(1, 2)), 0.5, "AbsTol", 1e-15);
            testCase.verifyEqual(full(Q(1, 3)), 0, "AbsTol", 1e-15);
            testCase.verifyEqual(full(Q(1, 4)), 0, "AbsTol", 1e-15);
            Q_interleaved = kron(Qs, speye(3));
            testCase.verifyGreaterThan(max(abs(full(Q - Q_interleaved)), [], "all"), 0.4);
        end
    end
end
