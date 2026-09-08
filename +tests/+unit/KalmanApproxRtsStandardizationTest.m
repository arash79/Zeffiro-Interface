classdef KalmanApproxRtsStandardizationTest < matlab.unittest.TestCase
%KALMANAPPROXRTSSTANDARDIZATIONTEST  Approx RTS uses Z*m, matching D = w .* Z.

    methods (Test)
        function testScaledInvsqrtMatchesTrueOnLargeEigs(testCase)
            % Inherited Schulz-from-I diverged on this spectrum; eig invsqrt must not.
            P = diag([4, 9, 16]);
            Z = inverse.kf.spd_invsqrt_denman_beavers(P);
            target = diag(1 ./ sqrt(diag(P)));
            testCase.verifyLessThan(norm(Z - target, "fro") / norm(target, "fro"), 1e-10);
            testCase.verifyLessThan(max(abs(Z(:))), 10);
        end

        function testDenmanBeaversZTimesMCloserToInvSqrtThanBackslash(testCase)
            P = diag([0.7, 1.0, 1.3]);
            m = [2; 3; 4];
            Z = inverse.kf.spd_invsqrt_denman_beavers(P);
            target = diag(1 ./ sqrt(diag(P))) * m;
            err_times = norm(Z * m - target);
            err_div = norm(Z \ m - target);
            testCase.verifyLessThan(err_times, err_div);
            testCase.verifyLessThan(err_times / max(norm(target), eps), 1e-10);
        end

        function testSmootherAppliesZTimesMMatchingFilterD(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            src = fileread(fullfile(root, "+inverse", "@KalmanInverter", "smoother.m"));
            testCase.verifyTrue(contains(src, "P_invsqrt * m_s"));
            testCase.verifyFalse(contains(src, "P_sqrtm_right\m_s"));
            testCase.verifyFalse(contains(src, "P_sqrtm_right \ m_s"));
            filt = fileread(fullfile(root, "+inverse", "+kf", "kf_sL_update_approx.m"));
            testCase.verifyTrue(contains(filt, "D = w_t .* P_invsqrt"));
            testCase.verifyTrue(contains(filt, "spd_invsqrt_denman_beavers"));
        end
    end
end
