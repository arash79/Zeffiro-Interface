classdef IASInverterOptTest < matlab.unittest.TestCase
%IASINVERTEROPTTEST  IAS invert matches the legacy W = d.*(W'*inv(A)) kernel.

    methods (TestMethodSetup)
        function seedRngAndCloseWaitbars(~)
            rng(8, "twister");
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function testNoneMatchesLegacyKernel(testCase)
            i_assert_close_to_legacy(testCase, "None", "Inverse gamma", 6);
        end

        function testDSPMEachStepBitwiseWithLegacy(testCase)
            [z_new, z_old] = i_pair("dSPM each step", "Inverse gamma", 5);
            testCase.verifyEqual(z_new, z_old);
        end

        function testDSPMLastStepMatchesLegacy(testCase)
            i_assert_close_to_legacy(testCase, "dSPM last step", "Inverse gamma", 5);
        end

        function testSLoretaLastStepMatchesLegacy(testCase)
            i_assert_close_to_legacy(testCase, "sLORETA last step", "Inverse gamma", 5);
        end

        function testGammaHyperpriorMatchesLegacy(testCase)
            i_assert_close_to_legacy(testCase, "None", "Gamma", 6);
        end

        function testSingleIterationSLoretaMatchesLegacy(testCase)
            i_assert_close_to_legacy(testCase, "sLORETA last step", "Inverse gamma", 1);
        end

        function testOutputContractUnchanged(testCase)
            [L, F, procFile, sp] = i_synth(12, 18);
            f = F(:, 1);
            inv = i_make_inverter("None", "Inverse gamma", 4);
            inv = inv.initialize(L, F);
            d0 = inv.d_sqrt;
            [z, inv2] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
            testCase.verifySize(z, [size(L, 2), 1]);
            testCase.verifyClass(z, "double");
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyTrue(issparse(z) == false);
            testCase.verifyEqual(inv2.d_sqrt, d0);
            testCase.verifyEqual(inv2.n_map_iterations, 4);
            testCase.verifyEqual(inv2.method_type, "None");
        end

        function testFramesStartFromSameHyperprior(testCase)
            [L, F, procFile, sp] = i_synth(10, 15);
            inv = i_make_inverter("None", "Inverse gamma", 4);
            inv.number_of_frames = 2;
            inv = inv.initialize(L, F);
            [z1, inv] = inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            [z2, ~] = inv.invert(F(:,2), L, procFile, 1, sp, "use_gpu", false);
            testCase.verifySize(z1, [size(L, 2), 1]);
            testCase.verifySize(z2, [size(L, 2), 1]);
            testCase.verifyTrue(all(isfinite(z1)) && all(isfinite(z2)));
        end

        function testDsqrtIsPriorStdMatchingPlugin(testCase)
            [L, F] = i_synth(12, 18);
            inv = i_make_inverter("None", "Inverse gamma", 1);
            inv = inv.initialize(L, F);
            testCase.verifyEqual(inv.d_sqrt, sqrt(inv.theta0 ./ (inv.beta - 1)), ...
                "RelTol", 1e-14);
            inv_g = i_make_inverter("None", "Gamma", 1);
            inv_g = inv_g.initialize(L, F);
            testCase.verifyEqual(inv_g.d_sqrt, sqrt(inv_g.theta0 .* inv_g.beta), ...
                "RelTol", 1e-14);
        end

        function testClassAndPluginSkipFullFilterWhenUnused(testCase)
            ias_src = fileread(fullfile("+inverse", "@IASInverter", "invert.m"));
            plugin_src = fileread(fullfile("plugins", "IASInversion", "m", "zef_ias_iteration.m"));
            testCase.verifyTrue(contains(ias_src, "Wd' * (A \ f)"));
            testCase.verifyTrue(contains(plugin_src, "Wd' * (A \ f)"));
            testCase.verifyTrue(contains(ias_src, "need_full_W"));
            testCase.verifyTrue(contains(plugin_src, "need_full_W"));
        end
    end
end

function i_assert_close_to_legacy(testCase, method_type, hyperprior, n_iter)
[z_new, z_old] = i_pair(method_type, hyperprior, n_iter);
testCase.verifyEqual(size(z_new), size(z_old));
testCase.verifyClass(z_new, class(z_old));
testCase.verifyTrue(all(isfinite(z_new)) && all(isfinite(z_old)));
testCase.verifyEqual(isnan(z_new), isnan(z_old));
rel = norm(z_new(:) - z_old(:)) / max(norm(z_old), eps);
testCase.verifyLessThanOrEqual(rel, 1e-12);
end

function [z_new, z_old] = i_pair(method_type, hyperprior, n_iter)
[L, F, procFile, sp] = i_synth(16, 24);
f = F(:, 1);
inv = i_make_inverter(method_type, hyperprior, n_iter);
inv = inv.initialize(L, F);
[z_new, ~] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
z_old = i_ias_legacy_kernel(L, f, inv.d_sqrt, inv.theta0, inv.beta, ...
    inv.noise_cov, hyperprior, method_type, n_iter);
end

function inv = i_make_inverter(method_type, hyperprior, n_iter)
inv = inverse.IASInverter( ...
    "number_of_frames", 2, ...
    "n_map_iterations", n_iter, ...
    "method_type", method_type, ...
    "hyperprior", hyperprior, ...
    "signal_to_noise_ratio", 20);
end

function [L, f, procFile, sp] = i_synth(n_sens, n_src)
L = randn(n_sens, 3 * n_src);
f = randn(n_sens, 2);
procFile = struct("s_ind_0", (1:n_src)', "s_ind_4", zeros(0, 1));
sp = randn(n_src, 3);
end

function z_vec = i_ias_legacy_kernel(L, f, d_sqrt, theta0, beta, S_mat, hyperprior, method_type, n_iter)
for i = 1:n_iter
    W = L .* repmat(d_sqrt', size(L, 1), 1);
    W = d_sqrt .* (W' * inv(W * W' + S_mat)); %#ok<MINV>
    if strcmp(method_type, "dSPM each step")
        dspm_vec = sum(W.^2, 2);
        dspm_vec = sqrt(dspm_vec);
        W = W ./ dspm_vec;
    elseif strcmp(method_type, "dSPM last step")
        if i == n_iter
            dspm_vec = sum(W.^2, 2);
            dspm_vec = sqrt(dspm_vec);
            W = W ./ dspm_vec;
        end
    elseif strcmp(method_type, "sLORETA last step")
        if i == n_iter
            sloreta_vec = sqrt(sum(W .* L', 2));
            W = W ./ sloreta_vec(:, ones(size(W, 2), 1));
        end
    end
    z_vec = W * f;
    if strcmp(hyperprior, "Inverse gamma")
        d_sqrt = sqrt((theta0 + 0.5 * z_vec.^2) ./ (beta + 1.5));
    elseif strcmp(hyperprior, "Gamma")
        d_sqrt = sqrt(theta0 .* (beta - 1.5 + sqrt((1 ./ (2 .* theta0)) .* z_vec.^2 + (beta + 1.5).^2)));
    end
end
end
