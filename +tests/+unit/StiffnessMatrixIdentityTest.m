classdef StiffnessMatrixIdentityTest < matlab.unittest.TestCase
%STIFFNESSMATRIXIDENTITYTEST  P1 stiffness vs analytic hats on the unit tet.

    methods (Test)
        function testIsotropicUnitTetMatchesAnalyticHats(testCase)
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            V = zef_tetra_volume(nodes, tetra, true);
            testCase.verifyEqual(V, 1/6, "AbsTol", 1e-14);
            tensor = [1; 1; 1; 0; 0; 0];
            A = zef_stiffness_matrix(nodes, tetra, V, tensor);
            A = full(A);
            % λ1=x, λ2=y, λ3=z, λ4=1-x-y-z on this tet; A_ij = ∇λi·∇λj * V.
            G = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];
            A_ref = (G * G') * (1/6);
            testCase.verifyLessThanOrEqual(max(abs(A - A_ref), [], "all"), 1e-12);
            testCase.verifyLessThanOrEqual(max(abs(A - A'), [], "all"), 1e-14);
            testCase.verifyLessThanOrEqual(norm(A * ones(4, 1)), 1e-12);
        end

        function testAnisotropicOffDiagonalBothTransposeTerms(testCase)
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            V = zef_tetra_volume(nodes, tetra, true);
            % σ_xy = 1, other entries 0: packed row 4.
            tensor = [0; 0; 0; 1; 0; 0];
            A = full(zef_stiffness_matrix(nodes, tetra, V, tensor));
            G = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];
            sigma = [0 1 0; 1 0 0; 0 0 0];
            A_ref = (G * sigma * G') * (1/6);
            testCase.verifyLessThanOrEqual(max(abs(A - A_ref), [], "all"), 1e-12);
        end

        function testOffDiagonalXzAndYz(testCase)
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            V = zef_tetra_volume(nodes, tetra, true);
            G = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];

            tensor_xz = [0; 0; 0; 0; 1; 0];
            A_xz = full(zef_stiffness_matrix(nodes, tetra, V, tensor_xz));
            sigma_xz = [0 0 1; 0 0 0; 1 0 0];
            testCase.verifyLessThanOrEqual( ...
                max(abs(A_xz - (G * sigma_xz * G') * (1/6)), [], "all"), 1e-12);

            tensor_yz = [0; 0; 0; 0; 0; 1];
            A_yz = full(zef_stiffness_matrix(nodes, tetra, V, tensor_yz));
            sigma_yz = [0 0 0; 0 0 1; 0 1 0];
            testCase.verifyLessThanOrEqual( ...
                max(abs(A_yz - (G * sigma_yz * G') * (1/6)), [], "all"), 1e-12);
        end

        function testFullSymmetricTensorMatchesDenseReference(testCase)
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            V = zef_tetra_volume(nodes, tetra, true);
            G = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];
            rng(11, "twister");
            S = randn(3);
            sigma = S * S' + 0.1 * eye(3);
            tensor = [sigma(1,1); sigma(2,2); sigma(3,3); ...
                sigma(1,2); sigma(1,3); sigma(2,3)];
            A = full(zef_stiffness_matrix(nodes, tetra, V, tensor));
            A_ref = (G * sigma * G') * (1/6);
            testCase.verifyLessThanOrEqual(max(abs(A - A_ref), [], "all"), 1e-12);
            testCase.verifyLessThanOrEqual(norm(A * ones(4, 1)), 1e-11);
        end

        function testTwoTetSharedFaceAssembly(testCase)
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 0 0 -1];
            tetra = [1 2 3 4; 1 2 3 5];
            V = zef_tetra_volume(nodes, tetra, true);
            tensor = [ones(1, 2); ones(1, 2); ones(1, 2); zeros(3, 2)];
            A = full(zef_stiffness_matrix(nodes, tetra, V, tensor));
            testCase.verifyLessThanOrEqual(max(abs(A - A'), [], "all"), 1e-14);
            testCase.verifyLessThanOrEqual(norm(A * ones(5, 1)), 1e-11);
            testCase.verifyEqual(size(A), [5 5]);
        end
    end
end
