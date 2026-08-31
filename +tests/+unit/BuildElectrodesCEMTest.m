classdef BuildElectrodesCEMTest < matlab.unittest.TestCase
%BUILDELECTRODESCEMTEST  P1 CEM triangle integrals vs hand calculation.

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            zef_delete_waitbar();
        end
    end

    methods (Test)
        function testSingleTriangleMatchesAnalyticMass(testCase)
            % Equilateral triangle in the xy-plane, Z = 2 ohm.
            side = 2;
            nodes = [0 0 0; side 0 0; side/2, (sqrt(3)/2)*side, 0; 0 0 1];
            area = sqrt(3)/4 * side^2;
            Z = 2;
            A0 = sparse(4, 4);
            ele_ind = [1, 1, 2, 3];
            [A, B, C] = zef_build_electrodes(nodes, 'CEM', Z, 0, ele_ind, A0);

            Zs = Z * area;
            testCase.verifyEqual(full(C(1,1)), 1/Z, "AbsTol", 1e-12);
            testCase.verifyEqual(full(B(1,1)), area/(3*Zs), "AbsTol", 1e-12);
            testCase.verifyEqual(full(B(2,1)), area/(3*Zs), "AbsTol", 1e-12);
            testCase.verifyEqual(full(B(3,1)), area/(3*Zs), "AbsTol", 1e-12);
            testCase.verifyEqual(full(B(4,1)), 0, "AbsTol", 1e-14);
            testCase.verifyEqual(full(A(1,1)), area/(6*Zs), "AbsTol", 1e-12);
            testCase.verifyEqual(full(A(1,2)), area/(12*Zs), "AbsTol", 1e-12);
            testCase.verifyEqual(full(A(2,3)), area/(12*Zs), "AbsTol", 1e-12);
            testCase.verifyEqual(full(A(4,4)), 0, "AbsTol", 1e-14);
            testCase.verifyLessThanOrEqual(max(abs(full(A - A')), [], "all"), 1e-14);
        end

        function testTwoTrianglePatchSumIdentity(testCase)
            % Two right triangles sharing an edge; C_ee must still be 1/Z.
            nodes = [0 0 0; 1 0 0; 1 1 0; 0 1 0];
            ele_ind = [1, 1, 2, 3; 1, 1, 3, 4];
            Z = 5;
            A0 = sparse(4, 4);
            [A, B, C] = zef_build_electrodes(nodes, 'CEM', Z, 0, ele_ind, A0);
            testCase.verifyEqual(full(C(1,1)), 1/Z, "AbsTol", 1e-12);
            testCase.verifyEqual(sum(full(B(:,1))), 1/Z, "AbsTol", 1e-12);
            testCase.verifyLessThanOrEqual(max(abs(full(A - A')), [], "all"), 1e-14);
        end

        function testInfiniteImpedanceCemLeavesCIncomplete(testCase)
            % Inherited: impedance_inf==1 returns before triangle C assembly.
            nodes = [0 0 0; 1 0 0; 0 1 0];
            ele_ind = [1, 1, 2, 3];
            A0 = sparse(3, 3);
            [A, B, C] = zef_build_electrodes(nodes, 'CEM', 1, 1, ele_ind, A0);
            testCase.verifyEqual(nnz(C), 0);
            testCase.verifyGreaterThan(nnz(B), 0);
            testCase.verifyEqual(nnz(A), 0);
        end

        function testPointFallbackUsesWeightOverZ(testCase)
            nodes = [0 0 0; 1 0 0; 0 1 0];
            % Column 4 == 0 → point contact at node 2 with weight 1.
            ele_ind = [1, 2, 1, 0];
            Z = 4;
            A0 = sparse(3, 3);
            [A, B, C] = zef_build_electrodes(nodes, 'CEM', Z, 0, ele_ind, A0);
            testCase.verifyEqual(full(B(2,1)), 1/Z, "AbsTol", 1e-14);
            testCase.verifyEqual(full(A(2,2)), 1/Z, "AbsTol", 1e-14);
            testCase.verifyEqual(full(C(1,1)), 1/Z, "AbsTol", 1e-14);
        end
    end
end
