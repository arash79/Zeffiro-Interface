classdef InverseScientificIdentityTest < matlab.unittest.TestCase
%INVERSESCIENTIFICIDENTITYTEST  Known-source identities for class inverters.
%
%   These are not equivalence-to-upstream checks. They ask whether the
%   implementation satisfies the mathematical claim of the method on a
%   synthetic lead field where the correct answer is known.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(41, "twister");
        end
    end

    methods (Test)
        function testDipoleScanGoFIsOneAtTrueSource(testCase)
            n_sens = 40;
            n_src = 8;
            src = 5;
            L = randn(n_sens, 3*n_src);
            x = [1; 0; 0];
            f = L(:, 3*src - [2, 1, 0]) * x;
            [procFile, sp] = i_proc(n_src);
            inv = inverse.DipoleScanInverter( ...
                "number_of_frames", 2, "reg_type", "None");
            inv.noise_cov = eye(n_sens);
            [z, ~] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
            gof = zeros(n_src, 1);
            for i = 1:n_src
                gof(i) = norm(z(3*i - [2, 1, 0])) * sqrt(3);
            end
            testCase.verifyEqual(gof(src), 1, "AbsTol", 1e-12);
            [~, idx] = max(gof);
            testCase.verifyEqual(idx, src);
        end

        function testEloretaFixedPointMatchesInvsqrtIdentity(testCase)
            n_sens = 24;
            n_src = 8;
            L = randn(n_sens, 3*n_src);
            F = randn(n_sens, 2);
            [procFile, ~] = i_proc(n_src);
            inv = inverse.ELORETAInverter( ...
                "number_of_frames", 2, ...
                "apply_average_reference", false, ...
                "regularization_parameter", 0.1, ...
                "n_max_iterations", 80, ...
                "convergence_tolerance", 1e-10);
            inv = inv.initialize(L, F);
            inv = inv.precompute(L, procFile);
            T = inv.precomputed_inverse_operator;
            alpha = inv.regularization_parameter;
            Minv = (eye(n_sens) - L * T) / alpha;
            Minv = 0.5 * (Minv + Minv');
            testCase.verifyGreaterThan(min(real(eig(Minv))), 0);
            worst = 0;
            for i = 1:n_src
                ind = 3*i - [2, 1, 0];
                A = L(:, ind)' * Minv * L(:, ind);
                A = 0.5 * (A + A');
                [V, D] = eig(A);
                ev = max(real(diag(D)), eps);
                Winv = V * diag(1 ./ sqrt(ev)) * V';
                T_i = Winv * (L(:, ind)' * Minv);
                worst = max(worst, max(abs(T_i - T(ind, :)), [], "all"));
            end
            testCase.verifyLessThanOrEqual(worst, 1e-8);
            testCase.verifyLessThanOrEqual(inv.final_residual, 1e-8);
        end

        function testIdentityTransitionRejectsMixedDiagonal(testCase)
            testCase.verifyTrue(inverse.kf.is_identity_transition(eye(4)));
            testCase.verifyTrue(inverse.kf.is_identity_transition(speye(4)));
            testCase.verifyFalse(inverse.kf.is_identity_transition(0.9*eye(4)));
            testCase.verifyFalse(inverse.kf.is_identity_transition(diag([1, 0.5, 1])));
            testCase.verifyFalse(inverse.kf.is_identity_transition([]));
            testCase.verifyFalse(inverse.kf.is_identity_transition(ones(3)));
        end

        function testPredictAppliesMixedDiagonalA(testCase)
            inv = inverse.KalmanInverter("number_of_frames", 2);
            inv.prev_step_reconstruction = [1; 2; 3];
            inv.prev_step_posterior_cov = eye(3);
            inv.evolution_cov = 0.01*eye(3);
            inv.state_transition_model_A = diag([1, 0.5, 1]);
            [m, P] = inverse.kf.class_kf_predict(inv);
            testCase.verifyEqual(m, [1; 1; 3], "AbsTol", 1e-14);
            P_ref = inv.state_transition_model_A * eye(3) * inv.state_transition_model_A' + 0.01*eye(3);
            testCase.verifyLessThanOrEqual(max(abs(P - P_ref), [], "all"), 1e-14);
            inv.state_transition_model_A = eye(3);
            [m_i, P_i] = inverse.kf.class_kf_predict(inv);
            testCase.verifyEqual(m_i, [1; 2; 3], "AbsTol", 1e-14);
            testCase.verifyLessThanOrEqual(max(abs(P_i - 1.01*eye(3)), [], "all"), 1e-14);
        end

        function testPluginPredictMatchesClassOnMixedA(testCase)
            testCase.assumeNotEmpty(which("kf_predict"), "GUI Kalman kf_predict not on path");
            m0 = [1; 2; 3];
            P0 = eye(3);
            Q = 0.01*eye(3);
            A = diag([1, 0.5, 1]);
            [m_p, P_p] = kf_predict(m0, P0, A, Q);
            testCase.verifyEqual(m_p, [1; 1; 3], "AbsTol", 1e-14);
            P_ref = A * P0 * A' + Q;
            testCase.verifyLessThanOrEqual(max(abs(P_p - P_ref), [], "all"), 1e-14);
        end

        function testBasicKalmanTracksConstantState(testCase)
            n_sens = 8;
            n_dof = 6;
            n_frames = 40;
            L = randn(n_sens, n_dof);
            x = randn(n_dof, 1);
            F = L * x + 0.05*randn(n_sens, n_frames);
            [procFile, sp] = i_proc(n_dof);
            inv = inverse.KalmanInverter( ...
                "method_type", "Basic Kalman filter", ...
                "number_of_frames", n_frames, ...
                "use_smoothing", false, ...
                "smoother_type", "None");
            inv = inv.initialize(L, F);
            inv.noise_cov = 0.05^2 * eye(n_sens);
            inv.evolution_cov = 1e-8 * eye(n_dof);
            z = zeros(n_dof, 1);
            for t = 1:n_frames
                [z, inv] = inv.invert(F(:, t), L, procFile, 1, sp, "use_gpu", false);
            end
            rel = norm(z - x) / max(norm(x), eps);
            testCase.verifyLessThanOrEqual(rel, 0.25);
            testCase.verifyTrue(all(isfinite(z)));
        end

        function testKalmanRtsSmootherRunsWithoutUndefinedFrames(testCase)
            n_sens = 10;
            n_dof = 6;
            n_frames = 6;
            L = randn(n_sens, n_dof);
            F = randn(n_sens, n_frames);
            [procFile, sp] = i_proc(n_dof);
            inv = inverse.KalmanInverter( ...
                "method_type", "Basic Kalman filter", ...
                "number_of_frames", n_frames, ...
                "use_smoothing", true, ...
                "smoother_type", "RTS");
            inv = inv.initialize(L, F);
            inv.noise_cov = 0.1*eye(n_sens);
            inv.evolution_cov = 0.01*eye(n_dof);
            z_cell = cell(1, n_frames);
            for t = 1:n_frames
                [z_cell{t}, inv] = inv.invert(F(:, t), L, procFile, 1, sp, "use_gpu", false);
            end
            [z_s, inv] = inv.smoother(z_cell, L);
            testCase.verifyEqual(numel(z_s), n_frames);
            testCase.verifyEqual(size(z_s{1}), [n_dof, 1]);
            testCase.verifyTrue(all(isfinite(z_s{1})));
            testCase.verifyEqual(numel(inv.posterior_covs), n_frames);
        end
    end
end

function [procFile, sp] = i_proc(n_src)
procFile = struct( ...
    "s_ind_0", (1:n_src)', ...
    "s_ind_4", zeros(0, 1), ...
    "n_interp", n_src, ...
    "sizeL2", n_src, ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_src, 3));
sp = randn(n_src, 3);
end
