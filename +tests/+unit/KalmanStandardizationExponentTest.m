classdef KalmanStandardizationExponentTest < matlab.unittest.TestCase
%KALMANSTANDARDIZATIONEXPONENTTEST  sLORETA exponent parity, class vs legacy.
%
%   The class Kalman path hard-coded the sLORETA weight exponent at 1/2 while
%   the legacy plugin exposes zef.standardization_exponent, a dropdown of
%   1/2, 1, 5/4, 3/2, 7/4, 2 that defaults to 1. Two code paths advertised as
%   the "Standardized Kalman filter" therefore returned different
%   reconstructions, and the class API could not reproduce a legacy run at
%   all. The exponent is now a parameter with default 1/2.
%
%   These tests pin both halves of that: the default still reproduces the
%   old hard-coded behaviour bitwise, and passing the legacy exponent makes
%   the class path agree with the legacy function bitwise.
%
%   See also inverse.kf.kf_sL_update, inverse.kf.kf_sL_update_approx.

    methods (Static, Access = private)
        function [m, P, y, H, R] = fixture()
            % Small, well-conditioned, symmetric-positive-definite P so that
            % sqrtm and the inverse below are meaningful.
            rng(4242);
            n = 8;      % states
            k = 5;      % sensors
            A = randn(n, n);
            P = A*A' + n*eye(n);
            P = (P + P')/2;
            m = randn(n, 1);
            H = randn(k, n);
            B = randn(k, k);
            R = B*B' + k*eye(k);
            R = (R + R')/2;
            y = randn(k, 1);
        end
    end

    methods (Test)
        function defaultReproducesFormerHardCodedSqrt(testCase)
            % The old body computed 1./sqrt(s)'; the new one computes
            % 1./(s').^e with e = 1/2. MATLAB maps x.^0.5 onto sqrt(x)
            % exactly, so this must hold bitwise, not just to a tolerance.
            [m, P, y, H, R] = tests.unit.KalmanStandardizationExponentTest.fixture();

            [m1, P1, K1, D1] = inverse.kf.kf_sL_update(m, P, y, H, R);

            P_sqrtm = sqrtm(P);
            B = H * P_sqrtm;
            G = B' / (B * B' + R);
            w_expected = 1 ./ sqrt(sum(G.' .* B, 1))';
            D_expected = w_expected .* inv(P_sqrtm); %#ok<MINV>

            testCase.verifyEqual(D1, D_expected, ...
                'default exponent must reproduce the former hard-coded sqrt bitwise');
            % The mean/covariance update never depended on the exponent.
            testCase.verifyEqual(m1, m + (P*H')/((H*(P*H') + R + (H*(P*H') + R)')/2)*(y - H*m), ...
                'RelTol', 1e-12);
            testCase.verifyTrue(all(isfinite(P1(:))));
            testCase.verifyTrue(all(isfinite(K1(:))));
        end

        function explicitHalfMatchesOmittedArgument(testCase)
            [m, P, y, H, R] = tests.unit.KalmanStandardizationExponentTest.fixture();
            [ma, Pa, Ka, Da] = inverse.kf.kf_sL_update(m, P, y, H, R);
            [mb, Pb, Kb, Db] = inverse.kf.kf_sL_update(m, P, y, H, R, 0.5);
            testCase.verifyEqual(mb, ma);
            testCase.verifyEqual(Pb, Pa);
            testCase.verifyEqual(Kb, Ka);
            testCase.verifyEqual(Db, Da);
        end

        function exponentChangesTheStandardizationNotTheUpdate(testCase)
            % Guard against the exponent being accepted but ignored, and
            % against it leaking into the Kalman update itself.
            [m, P, y, H, R] = tests.unit.KalmanStandardizationExponentTest.fixture();
            [m1, P1, K1, D1] = inverse.kf.kf_sL_update(m, P, y, H, R, 0.5);
            [m2, P2, K2, D2] = inverse.kf.kf_sL_update(m, P, y, H, R, 1.5);

            testCase.verifyEqual(m2, m1, 'the state update must not depend on the exponent');
            testCase.verifyEqual(P2, P1, 'the covariance update must not depend on the exponent');
            testCase.verifyEqual(K2, K1, 'the gain must not depend on the exponent');
            testCase.verifyThat(norm(D2 - D1) > 1e-8, matlab.unittest.constraints.IsTrue(), ...
                'the exponent must actually reach the standardization matrix');
        end

        function classPathMatchesLegacyPluginAtTheSameExponent(testCase)
            % plugins/Kalman/m/kf_sL_update.m is reachable unqualified while
            % the class version needs inverse.kf., so they do not shadow one
            % another. With the same exponent their bodies are identical and
            % must agree bitwise; this is what lets a legacy sLORETA run be
            % reproduced through KalmanInverter.
            legacy = which('kf_sL_update');
            testCase.assumeNotEmpty(legacy, 'legacy Kalman plugin is not on the path');
            testCase.assertTrue(contains(legacy, fullfile('plugins', 'Kalman')), ...
                sprintf('unqualified kf_sL_update should be the legacy plugin, got %s', legacy));

            [m, P, y, H, R] = tests.unit.KalmanStandardizationExponentTest.fixture();
            for e = [0.5 1 1.25 1.5 1.75 2]
                [mL, PL, KL, DL] = kf_sL_update(m, P, y, H, R, e);
                [mC, PC, KC, DC] = inverse.kf.kf_sL_update(m, P, y, H, R, e);
                testCase.verifyEqual(mC, mL, sprintf('mean diverged at exponent %g', e));
                testCase.verifyEqual(PC, PL, sprintf('covariance diverged at exponent %g', e));
                testCase.verifyEqual(KC, KL, sprintf('gain diverged at exponent %g', e));
                testCase.verifyEqual(DC, DL, sprintf('standardization diverged at exponent %g', e));
            end
        end

        function approxVariantTakesTheExponentToo(testCase)
            [m, P, y, H, R] = tests.unit.KalmanStandardizationExponentTest.fixture();
            [~, ~, ~, Da] = inverse.kf.kf_sL_update_approx(m, P, y, H, R);
            [~, ~, ~, Db] = inverse.kf.kf_sL_update_approx(m, P, y, H, R, 0.5);
            [~, ~, ~, Dc] = inverse.kf.kf_sL_update_approx(m, P, y, H, R, 1.5);
            testCase.verifyEqual(Db, Da, 'default must equal an explicit 1/2');
            testCase.verifyThat(norm(Dc - Da) > 1e-8, matlab.unittest.constraints.IsTrue(), ...
                'the exponent must reach the approximate standardization matrix');
        end

        function inverterExposesTheExponentWithTheHistoricalDefault(testCase)
            % Changing this default silently would change every existing
            % class-path sLORETA reconstruction, so pin it.
            inverter = inverse.KalmanInverter();
            testCase.verifyEqual(inverter.standardization_exponent, 0.5);

            inverter.standardization_exponent = 1;
            testCase.verifyEqual(inverter.standardization_exponent, 1);

            testCase.verifyError(@() setExponent(inverter, 0), ...
                'MATLAB:validators:mustBePositive');
            testCase.verifyError(@() setExponent(inverter, -1), ...
                'MATLAB:validators:mustBePositive');

            function setExponent(obj, v)
                obj.standardization_exponent = v;
            end
        end
    end
end
