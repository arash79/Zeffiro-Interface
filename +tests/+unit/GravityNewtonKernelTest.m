classdef GravityNewtonKernelTest < matlab.unittest.TestCase
%GRAVITYNEWTONKERNELTEST  Newtonian 1/r and r/r^3 kernels, not component powers.

    methods (Test)
        function type3IsInverseDistanceNotInverseSquare(testCase)
            r = [1, 1, 0];
            V = 2;
            K = zef_gravity_newton_kernel(r, V, 3);
            testCase.verifyEqual(K, V / norm(r), "AbsTol", 1e-14);
            inherited = V / sum(r.^2, 2);
            testCase.verifyGreaterThan(abs(K - inherited), 0.2);
        end

        function type4IsROverRCubedNotComponentCubes(testCase)
            r = [1, 1, 0];
            V = 2;
            K = zef_gravity_newton_kernel(r, V, 4);
            testCase.verifyEqual(K, V * r / (norm(r)^3), "AbsTol", 1e-14);
            inherited = r * (V / sum(r.^3, 2));
            testCase.verifyGreaterThan(norm(K - inherited), 0.2);
        end

        function type1IsDirectionalFieldNotInverseFourth(testCase)
            r = [0.3, -0.4, 0.5];
            n = [0, 0, 1];
            V = 1.5;
            K = zef_gravity_newton_kernel(r, V, 1, n);
            testCase.verifyEqual(K, V * dot(n, r) / (norm(r)^3), "AbsTol", 1e-14);
            inherited = V * dot(n, r) / (norm(r)^4);
            testCase.verifyGreaterThan(abs(K - inherited), 0.5);
        end

        function type2MatchesDirectionalDerivativeOfType4(testCase)
            r = [0.2, 0.1, -0.4];
            n = [1, 0, 0];
            n = n / norm(n);
            V = 3;
            K = zef_gravity_newton_kernel(r, V, 2, n);
            R = norm(r);
            analytic = V * (-n / R^3 + 3 * dot(n, r) * r / R^5);
            testCase.verifyEqual(K, analytic, "AbsTol", 1e-12);
            eps_n = 1e-7;
            g_plus = zef_gravity_newton_kernel(r - eps_n * n, V, 4);
            g_minus = zef_gravity_newton_kernel(r + eps_n * n, V, 4);
            numeric = (g_plus - g_minus) / (2 * eps_n);
            testCase.verifyEqual(K, numeric, "RelTol", 1e-5);
        end

        function millimetreNodesScaledToMetresInLeadField(testCase)
            src = fileread(fullfile("src", "forward", "lead_field", ...
                "zef_lead_field_gravity.m"));
            testCase.verifyTrue(contains(src, "nodes / 1000"));
            testCase.verifyTrue(contains(src, "zef_gravity_newton_kernel"));
            testCase.verifyFalse(contains(src, "sum((repmat(c_tet"));
        end
    end
end
