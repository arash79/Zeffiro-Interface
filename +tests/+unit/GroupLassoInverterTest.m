classdef GroupLassoInverterTest < matlab.unittest.TestCase
%GROUPLASSOINVERTERTEST  LG_optimization vs reference kernel + invert smoke.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(19, "twister");
        end
    end

    methods (Test)
        function testLGMatchesSparseDiagReferenceIAS(testCase)
            sizes = [8, 9; 16, 24; 32, 60; 64, 200];
            for k = 1:size(sizes, 1)
                [A, y, gamma, x0, sigma] = i_lg_synth(sizes(k, 1), sizes(k, 2));
                x_ref = i_lg_sparse_d(A, sigma, y, gamma, x0, 5, 1);
                x_new = LG_optimization(A, sigma, y, gamma, x0, 5, 1);
                rel = max(abs(x_new(:) - x_ref(:))) / max(max(abs(x_ref)), eps);
                testCase.verifyLessThanOrEqual(rel, 1e-12);
                testCase.verifyTrue(all(isfinite(x_new)));
                testCase.verifyEqual(size(x_new), size(x_ref));
            end
        end

        function testLGMatchesSparseDiagReferenceEM(testCase)
            [A, y, gamma, x0, sigma] = i_lg_synth(20, 18);
            x_ref = i_lg_sparse_d(A, sigma, y, gamma, x0, 5, 2);
            x_new = LG_optimization(A, sigma, y, gamma, x0, 5, 2);
            rel = max(abs(x_new(:) - x_ref(:))) / max(max(abs(x_ref)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testLGMatchesSparseDiagReferenceStandardized(testCase)
            sizes = [8, 9; 16, 24; 32, 60];
            for k = 1:size(sizes, 1)
                [A, y, gamma, x0, sigma] = i_lg_synth(sizes(k, 1), sizes(k, 2));
                x_ref = i_lg_sparse_d(A, sigma, y, gamma, x0, 4, 3);
                x_new = LG_optimization(A, sigma, y, gamma, x0, 4, 3);
                rel = max(abs(x_new(:) - x_ref(:))) / max(max(abs(x_ref)), eps);
                testCase.verifyLessThanOrEqual(rel, 1e-12);
                testCase.verifyTrue(all(isfinite(x_new)));
            end
        end

        function testLGSigmaOneMatchesPrescaledCall(testCase)
            [A, y, gamma, x0, sigma] = i_lg_synth(20, 18);
            x_a = LG_optimization(A, sigma, y, gamma, x0, 5, 1);
            x_b = LG_optimization((1/sigma)*A, 1, (1/sigma)*y, gamma, x0, 5, 1);
            rel = max(abs(x_a(:) - x_b(:))) / max(max(abs(x_a)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
            x_c = LG_optimization(A, sigma, y, gamma, x0, 4, 3);
            x_d = LG_optimization((1/sigma)*A, 1, (1/sigma)*y, gamma, x0, 4, 3);
            rel = max(abs(x_c(:) - x_d(:))) / max(max(abs(x_c)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testInvertIASMatchesReferenceLoop(testCase)
            [L, F, procFile, sp] = i_synth(24, 16, 2);
            inv = inverse.GroupLassoInverter( ...
                "estimation_type", "IAS", ...
                "n_map_iterations", 6, "n_L1_iterations", 4, ...
                "number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            [z, inv] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
            z_ref = i_invert_ref(inv, L, F(:, 1), 6, 4, 1);
            rel = max(abs(z(:) - z_ref(:))) / max(max(abs(z_ref)), eps);
            testCase.verifyEqual(size(z), [size(L, 2), 1]);
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyClass(z, "double");
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testInvertStandardizedMatchesReferenceLoop(testCase)
            [L, F, procFile, sp] = i_synth(20, 12, 2);
            inv = inverse.GroupLassoInverter( ...
                "estimation_type", "Standardized", ...
                "n_map_iterations", 4, "n_L1_iterations", 3, ...
                "number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            [z, inv] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
            z_ref = i_invert_ref(inv, L, F(:, 1), 4, 3, 3);
            rel = max(abs(z(:) - z_ref(:))) / max(max(abs(z_ref)), eps);
            testCase.verifyEqual(size(z), size(z_ref));
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testInvertStandardizedDiffersFromIAS(testCase)
            % Sensitivity-weighted IAS and EM share the same LG branch, so
            % they match; Standardized (type 3) applies FOCUSS T_scale.
            [L, F, procFile, sp] = i_synth(16, 10, 2);
            z_ias = i_invert(L, F, procFile, sp, "IAS");
            z_em = i_invert(L, F, procFile, sp, "EM");
            z_std = i_invert(L, F, procFile, sp, "Standardized");
            testCase.verifyEqual(size(z_em), size(z_ias));
            testCase.verifyEqual(size(z_std), size(z_ias));
            testCase.verifyTrue(all(isfinite(z_em)) && all(isfinite(z_std)));
            testCase.verifyLessThanOrEqual( ...
                max(abs(z_ias - z_em)) / max(max(abs(z_ias)), eps), 1e-12);
            testCase.verifyGreaterThan(max(abs(z_ias - z_std)), 1e-12);
        end

        function testInvertManualHyperpriorFinite(testCase)
            [L, F, procFile, sp] = i_synth(10, 6, 1);
            inv = inverse.GroupLassoInverter( ...
                "estimation_type", "EM", ...
                "hyperprior_mode", "Manually selected", ...
                "beta", 3, "theta0", 1e-8, ...
                "n_map_iterations", 3, "n_L1_iterations", 2, ...
                "number_of_frames", 2, "signal_to_noise_ratio", 25);
            inv = inv.initialize(L, F);
            [z, ~] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyEqual(numel(z), size(L, 2));
        end

        function testRejectsNonTripletLeadField(testCase)
            L = randn(12, 10);
            F = randn(12, 2);
            procFile = struct("s_ind_0", (1:10)', "s_ind_4", zeros(0, 1));
            sp = randn(10, 3);
            inv = inverse.GroupLassoInverter( ...
                "n_map_iterations", 2, "number_of_frames", 2);
            inv = inv.initialize(L, F);
            testCase.verifyError( ...
                @() inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false), ...
                "GroupLassoInverter:LeadFieldNotTriplets");
        end

        function testDispatchGroupLassoPopulatesReconstruction(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "grouplasso", ...
                "execution", "local", ...
                "MethodParams", struct( ...
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

function [A, y, gamma, x0, sigma] = i_lg_synth(m, n_src)
n = 3 * n_src;
A = randn(m, n);
y = randn(m, 1);
gamma = 0.05 + abs(randn(n, 1));
x0 = ones(n, 1);
sigma = 10^(-30/20);
end

function z = i_invert(L, F, procFile, sp, est)
inv = inverse.GroupLassoInverter( ...
    "estimation_type", est, ...
    "n_map_iterations", 4, "n_L1_iterations", 3, ...
    "number_of_frames", 2, "signal_to_noise_ratio", 30);
inv = inv.initialize(L, F);
[z, ~] = inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false);
end

function z = i_invert_ref(self, L, f, n_map, n_l1, estimation_type)
% Invert MAP loop calling the same LG kernel as invert.m.
std_lhood = 10^(-self.signal_to_noise_ratio/20);
L_sq = sum(L.^2, 1);
c = L_sq * 0.6366;
sens = 2*repelem(sum(reshape(sum(L.^2), 3, [])), 3) ./ self.SNR_variable;
root = sqrt(c + 8*sens);
sqrtc = sqrt(c);
ind = 3*sqrtc - root > 0;
n_ind = not(ind);
beta = zeros(size(c));
beta(ind) = 4*sqrtc(ind) ./ (3*sqrtc(ind) - root(ind));
beta(n_ind) = 4*sqrtc(n_ind) ./ (root(n_ind) + 3*sqrtc(n_ind));
theta0 = (beta ./ sqrtc)';
theta0(beta < 2) = sqrt(3.75 ./ sens)';
beta(beta < 2) = 3.5;
beta = beta';
n = size(L, 2);
gamma = zeros(n, 1) + beta ./ theta0;
x_old = ones(n, 1);
z = x_old;
for i = 1:n_map
    z = i_lg_sparse_d(L, std_lhood, f, gamma, x_old, n_l1, estimation_type);
    zL2 = repelem(sqrt(sum(reshape(z.^2, 3, []))), 3)';
    gamma = beta ./ (theta0 + zL2);
    x_old = z;
end
end

function x = i_lg_sparse_d(A, sigma, y, gamma, x, maxiter, estimation_type)
% Reference LG kernel matching plugins/EXP/common/LG_optimization.m.
dualObj = -Inf;
reltol = 1e-4;
[m, ~] = size(A);
if sigma ~= 1
    A = 1/sigma*A;
    b = 1/sigma*y;
else
    b = y;
end
I = eye(m);
if estimation_type == 3
    reg = sqrt(0.5*pi/m)*norm(A, 'fro');
    for iter = 1:maxiter
        xL2 = repelem(sqrt(sum(reshape(x.^2, 3, []))), 3)' + 1e-12;
        d = xL2 ./ gamma;
        Ad = A .* d';
        AD2A_T = Ad * Ad';
        R = Ad' / (AD2A_T + I);
        R = abs(sum(R' .* Ad, 1));
        T_scale = 1 ./ sqrt(R)';
        ADA_T = A * (d .* A');
        x = T_scale .* (d .* (A' * ((ADA_T + (reg*sum(d))*I) \ b)));
    end
else
    for iter = 1:maxiter
        xL2 = repelem(sqrt(sum(reshape(x.^2, 3, []))), 3)' + 1e-10;
        D = spdiags(xL2 ./ gamma, 0, size(A, 2), size(A, 2));
        ADA_T = A * (D * A');
        x = D * (A' * ((ADA_T + I) \ b));
        z = (A * x) - b;
        max_nu = sqrt(max(sum(reshape((A' * z).^2 ./ gamma, 3, []), 2)));
        if max_nu > 1
            nu = z / max_nu;
        else
            nu = z;
        end
        primaryObj = 0.5*(z' * z) + sum(gamma .* x);
        dualObj = max(-0.5*(nu' * nu) - nu' * b, dualObj);
        gap = primaryObj - dualObj;
        if gap / dualObj < reltol
            break;
        end
    end
end
end
