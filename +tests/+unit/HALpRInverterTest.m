classdef HALpRInverterTest < matlab.unittest.TestCase
%HALPRINVERTERTEST  HALpR invert smoke + L1_optimization vs sparse-D reference.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(27, "twister");
        end
    end

    methods (Test)
        function testL1MatchesSparseDiagReference(testCase)
            sizes = [8, 9; 16, 24; 32, 60];
            for k = 1:size(sizes, 1)
                for et = [1, 3]
                    [A, y, gamma, x0, sigma] = i_l1_synth(sizes(k, 1), sizes(k, 2));
                    x_ref = i_l1_sparse_d(A, sigma, y, gamma, x0, 4, et);
                    x_new = L1_optimization(A, sigma, y, gamma, x0, 4, et);
                    rel = max(abs(x_new(:) - x_ref(:))) / max(max(abs(x_ref)), eps);
                    testCase.verifyLessThanOrEqual(rel, 1e-12);
                    testCase.verifyTrue(all(isfinite(x_new)));
                end
            end
        end

        function testL1SigmaOneMatchesPrescaledCall(testCase)
            [A, y, gamma, x0, sigma] = i_l1_synth(20, 18);
            x_a = L1_optimization(A, sigma, y, gamma, x0, 5, 1);
            x_b = L1_optimization((1/sigma)*A, 1, (1/sigma)*y, gamma, x0, 5, 1);
            rel = max(abs(x_a(:) - x_b(:))) / max(max(abs(x_a)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
            x_c = L1_optimization(A, sigma, y, gamma, x0, 5, 3);
            x_d = L1_optimization((1/sigma)*A, 1, (1/sigma)*y, gamma, x0, 5, 3);
            rel = max(abs(x_c(:) - x_d(:))) / max(max(abs(x_c)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testInvertQ1SizeAndFinite(testCase)
            [L, F, procFile, sp] = i_synth(12, 8, 2);
            inv = inverse.HALpRInverter( ...
                "q", 1, "estimation_type", "IAS", ...
                "n_map_iterations", 4, "n_L1_iterations", 3, ...
                "number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            [z, ~] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
            testCase.verifyEqual(size(z), [size(L, 2), 1]);
            testCase.verifyTrue(all(isfinite(z)));
        end

        function testInvertQ2AndStandardizedDifferFromIAS(testCase)
            [L, F, procFile, sp] = i_synth(16, 10, 2);
            z_q1 = i_invert(L, F, procFile, sp, 1, "IAS");
            z_q2 = i_invert(L, F, procFile, sp, 2, "IAS");
            z_std = i_invert(L, F, procFile, sp, 1, "Standardized");
            testCase.verifyEqual(size(z_q2), size(z_q1));
            testCase.verifyTrue(all(isfinite(z_q2)) && all(isfinite(z_std)));
            testCase.verifyGreaterThan(max(abs(z_q1 - z_q2)), 1e-12);
            testCase.verifyGreaterThan(max(abs(z_q1 - z_std)), 1e-12);
        end

        function testInvertManualHyperpriorFinite(testCase)
            [L, F, procFile, sp] = i_synth(10, 6, 1);
            inv = inverse.HALpRInverter( ...
                "q", 1, "estimation_type", "EM", ...
                "hyperprior_mode", "Manually selected", ...
                "beta", 3, "theta0", 1e-8, ...
                "n_map_iterations", 3, "n_L1_iterations", 2, ...
                "number_of_frames", 2, "signal_to_noise_ratio", 25);
            inv = inv.initialize(L, F);
            [z, ~] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyEqual(numel(z), size(L, 2));
        end

        function testQ2ZeroFrameIsZero(testCase)
            [L, F, procFile, sp] = i_synth(12, 8, 2);
            inv = inverse.HALpRInverter( ...
                "q", 2, "estimation_type", "IAS", ...
                "n_map_iterations", 4, "n_L1_iterations", 3, ...
                "number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            [z, ~] = inv.invert(zeros(size(L, 1), 1), L, procFile, 1, sp, "use_gpu", false);
            testCase.verifyEqual(z, zeros(size(L, 2), 1));
        end

        function testQ2PolarityFlipNegatesReconstruction(testCase)
            [L, F, procFile, sp] = i_synth(16, 10, 2);
            f = F(:, 1);
            z_p = i_invert_q2(L, f, F, procFile, sp);
            z_n = i_invert_q2(L, -f, F, procFile, sp);
            rel = max(abs(z_p + z_n)) / max(max(abs(z_p)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
            testCase.verifyGreaterThan(max(abs(z_p)), 0);
        end

        function testSensitivityWeightedRejectsNonTriplets(testCase)
            L = randn(10, 10);
            F = randn(10, 2);
            procFile = struct("s_ind_0", (1:10)', "s_ind_4", zeros(0, 1));
            sp = randn(10, 3);
            inv = inverse.HALpRInverter( ...
                "q", 1, "hyperprior_mode", "Sensitivity weighted", ...
                "n_map_iterations", 2, "number_of_frames", 2);
            inv = inv.initialize(L, F);
            testCase.verifyError( ...
                @() inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false), ...
                "zef:LeadFieldNotTriplets");
        end

        function testDispatchHalprPopulatesReconstruction(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "halpr", ...
                "execution", "local", ...
                "MethodParams", struct( ...
                    "q", 1, ...
                    "n_map_iterations", 3, ...
                    "n_L1_iterations", 2));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(~isempty(run_result.reconstruction));
            recon = run_result.reconstruction;
            if iscell(recon)
                testCase.verifyEqual(numel(recon), zef.number_of_frames);
                testCase.verifyTrue(all(isfinite(recon{1})));
            else
                testCase.verifyTrue(all(isfinite(recon(:))));
            end
        end
    end
end

function [L, F, procFile, sp] = i_synth(n_sens, n_src, n_frames)
L = randn(n_sens, 3*n_src);
F = randn(n_sens, n_frames);
procFile = struct( ...
    "s_ind_0", (1:n_src)', ...
    "s_ind_4", zeros(0, 1), ...
    "n_interp", n_src, ...
    "sizeL2", n_src, ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_src, 3));
sp = randn(n_src, 3);
end

function [A, y, gamma, x0, sigma] = i_l1_synth(m, n_src)
n = 3 * n_src;
A = randn(m, n);
y = randn(m, 1);
gamma = 0.05 + abs(randn(n, 1));
x0 = ones(n, 1);
sigma = 10^(-30/20);
end

function z = i_invert_q2(L, f, F, procFile, sp)
inv = inverse.HALpRInverter( ...
    "q", 2, "estimation_type", "IAS", ...
    "n_map_iterations", 4, "n_L1_iterations", 3, ...
    "number_of_frames", 2, "signal_to_noise_ratio", 30);
inv = inv.initialize(L, F);
[z, ~] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
end

function z = i_invert(L, F, procFile, sp, q, est)
inv = inverse.HALpRInverter( ...
    "q", q, "estimation_type", est, ...
    "n_map_iterations", 4, "n_L1_iterations", 3, ...
    "number_of_frames", 2, "signal_to_noise_ratio", 30);
inv = inv.initialize(L, F);
[z, ~] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
end

function x = i_l1_sparse_d(A, sigma, y, gamma, x, maxiter, estimation_type)
% Pre-optimization L1_optimization: sparse diagonal D and separate type-3 Gram.
[m, ~] = size(A);
A = 1/sigma*A;
b = 1/sigma*y;
reg = sqrt(0.5*pi/m)*norm(A, 'fro');
for iter = 1:maxiter
    if estimation_type == 3
        P_sqrt = abs(x)./gamma;
        L_aux = A.*P_sqrt';
        R = L_aux'/(L_aux*A'+eye(m));
        R = abs(sum(R.'.*L_aux, 1));
        T_scale = 1./sqrt(R)';
        D = spdiags(abs(x)./gamma, 0, size(A, 2), size(A, 2));
        ADA_T = A*(D*A');
        x = T_scale.*(D*(A'*((ADA_T + reg*trace(D)*eye(size(ADA_T)))\b)));
    else
        D = spdiags(abs(x)./gamma, 0, size(A, 2), size(A, 2));
        ADA_T = A*(D*A');
        x = D*(A'*((ADA_T + reg*trace(D)*eye(size(ADA_T)))\b));
    end
end
end
