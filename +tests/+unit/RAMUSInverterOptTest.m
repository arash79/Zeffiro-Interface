classdef RAMUSInverterOptTest < matlab.unittest.TestCase
%RAMUSINVERTEROPTTEST  RAMUS invert matches the legacy W = d.*(W'*inv(A)) kernel.

    methods (TestMethodSetup)
        function seedRngAndCloseWaitbars(~)
            rng(11, "twister");
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

        function testSLoretaEachStepBitwiseWithLegacy(testCase)
            [z_new, z_old] = i_pair("sLORETA each step", "Inverse gamma", 4);
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

        function testMultiLevelMultiDecMatchesLegacy(testCase)
            [L, F, procFile, sp, n_src] = i_synth(20, 24);
            [dec, ind, cnt] = i_synth_dec(n_src, sp, 3, 3, 2);
            f = F(:, 1);
            inv = i_make_inverter("None", "Inverse gamma", 4, 3, 3, 2, dec, ind, cnt);
            inv = inv.initialize(L, F);
            [z_new, ~] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
            z_old = i_ramus_legacy_kernel(inv, f, L);
            testCase.verifyEqual(size(z_new), size(z_old));
            testCase.verifyTrue(all(isfinite(z_new)) && all(isfinite(z_old)));
            rel = norm(z_new(:) - z_old(:)) / max(norm(z_old), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testOutputContractUnchanged(testCase)
            [L, F, procFile, sp, n_src] = i_synth(12, 10);
            [dec, ind, cnt] = i_synth_dec(n_src, sp, 1, 1, 1);
            f = F(:, 1);
            inv = i_make_inverter("None", "Inverse gamma", 4, 1, 1, 1, dec, ind, cnt);
            inv = inv.initialize(L, F);
            n_iter0 = inv.n_map_iterations;
            [z, inv2] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
            testCase.verifySize(z, [size(L, 2), 1]);
            testCase.verifyClass(z, "double");
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyTrue(issparse(z) == false);
            testCase.verifyEqual(inv2.n_map_iterations, n_iter0);
            testCase.verifyEqual(inv2.method_type, "None");
            testCase.verifyEqual(inv2.number_of_decompositions, int32(1));
        end

        function testEmptyDecStillErrors(testCase)
            [L, F, procFile, sp] = i_synth(8, 6);
            inv = inverse.RAMUSInverter( ...
                "number_of_frames", 2, ...
                "n_map_iterations", 2, ...
                "number_of_decompositions", 1, ...
                "number_of_multiresolution_levels", 1, ...
                "sparsity_factor", 1, ...
                "signal_to_noise_ratio", 20);
            inv = inv.initialize(L, F);
            testCase.verifyError( ...
                @() inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false), ...
                "inverse:RAMUSInverter:NoMultiresDec");
        end

        function testSkipFullFilterWhenUnused(testCase)
            ramus_src = fileread(fullfile("+inverse", "@RAMUSInverter", "invert.m"));
            testCase.verifyTrue(contains(ramus_src, "Wd' * (A \ f)"));
            testCase.verifyTrue(contains(ramus_src, "need_full_W"));
        end

        function testDispatchRamusLocal(testCase)
            zef = tests.support.createSyntheticInverseZef();
            n_src = size(zef.source_positions, 1);
            mp = struct( ...
                "number_of_decompositions", 1, ...
                "number_of_multiresolution_levels", 1, ...
                "sparsity_factor", 1, ...
                "n_map_iterations", 2);
            mp.multiresolution_dec = { {(1:n_src)'} };
            mp.multiresolution_ind = { {(1:n_src)'} };
            mp.multiresolution_count = { {ones(n_src, 1)} };
            [zef_out, r] = zef_inverse_run(zef, "ramus", ...
                "execution", "local", "MethodParams", mp);
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(~isempty(r.reconstruction));
            recon = r.reconstruction;
            if iscell(recon)
                testCase.verifyEqual(numel(recon), zef.number_of_frames);
                testCase.verifyTrue(all(isfinite(recon{1})));
            else
                testCase.verifyTrue(all(isfinite(recon(:))));
            end
            info = zef_out.reconstruction_information;
            testCase.verifyTrue(isstruct(info));
            testCase.verifyTrue(isfield(info, "tag"));
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
[L, F, procFile, sp, n_src] = i_synth(16, 18);
[dec, ind, cnt] = i_synth_dec(n_src, sp, 2, 2, 2);
f = F(:, 1);
inv = i_make_inverter(method_type, hyperprior, n_iter, 2, 2, 2, dec, ind, cnt);
inv = inv.initialize(L, F);
[z_new, ~] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
z_old = i_ramus_legacy_kernel(inv, f, L);
end

function inv = i_make_inverter(method_type, hyperprior, n_iter, n_dec, n_lev, sparsity, dec, ind, cnt)
inv = inverse.RAMUSInverter( ...
    "number_of_frames", 2, ...
    "n_map_iterations", n_iter, ...
    "method_type", method_type, ...
    "hyperprior", hyperprior, ...
    "number_of_decompositions", n_dec, ...
    "number_of_multiresolution_levels", n_lev, ...
    "sparsity_factor", sparsity, ...
    "multiresolution_dec", dec, ...
    "multiresolution_ind", ind, ...
    "multiresolution_count", cnt, ...
    "signal_to_noise_ratio", 20);
end

function [L, f, procFile, sp, n_src] = i_synth(n_sens, n_src)
L = randn(n_sens, 3 * n_src);
f = randn(n_sens, 2);
procFile = struct("s_ind_0", (1:n_src)', "s_ind_4", zeros(0, 1));
sp = randn(n_src, 3);
end

function [dec, ind, cnt] = i_synth_dec(n_src, positions, n_dec, n_lev, sparsity)
dec = cell(n_dec, 1);
ind = cell(n_dec, 1);
cnt = cell(n_dec, 1);
for d = 1:n_dec
    dec{d} = cell(1, n_lev);
    ind{d} = cell(1, n_lev);
    cnt{d} = cell(1, n_lev);
    for lv = 1:n_lev-1
        n_coarse = max(1, floor(n_src / double(sparsity)^(n_lev - lv)));
        n_coarse = min(n_coarse, n_src);
        idx = randperm(n_src, n_coarse)';
        dec{d}{lv} = idx;
        nn = knnsearch(positions(idx, :), positions);
        ind{d}{lv} = nn;
        cnt{d}{lv} = accumarray(nn, 1, [n_coarse, 1]);
    end
    dec{d}{n_lev} = (1:n_src)';
    ind{d}{n_lev} = (1:n_src)';
    cnt{d}{n_lev} = ones(n_src, 1);
end
end

function z_vec = i_ramus_legacy_kernel(self, f, L)
% Exact pre-optimization invert: always form W via repmat + inv, then W*f.
S_mat = self.noise_cov;
method_type = self.method_type;
n_lev = self.number_of_multiresolution_levels;
n_iter = self.n_map_iterations;
if length(n_iter) < n_lev
    n_iter = [n_iter, repmat(n_iter(end), 1, n_lev-length(n_iter))];
end
scaling_vec = (self.sparsity_factor.^[0:n_lev-1]');
if strcmp(self.hyperprior_mode, "Balanced")
    balance_spatially = 1;
else
    balance_spatially = 0;
end
if strcmp(self.data_normalization_method, "Maximum entry")
    normalize_data = 'maximum entry';
else
    normalize_data = 'something else';
end
modified_SNR = self.signal_to_noise_ratio-self.prior_over_measurement_db + self.amplitude_db;
hyperprior = self.hyperprior;
z_vec = zeros(size(L, 2), 1);
for dec_ind = 1:self.number_of_decompositions
    for mr_ind = 1:n_lev
        multires_dec = 3*self.multiresolution_dec{dec_ind}{mr_ind};
        multires_dec = [multires_dec-2,multires_dec-1,multires_dec]';
        multires_dec = multires_dec(:);
        multires_ind = 3*self.multiresolution_ind{dec_ind}{mr_ind};
        multires_ind = [multires_ind-2,multires_ind-1,multires_ind]';
        multires_ind = multires_ind(:);
        L_sub = L(:,multires_dec);
            if strcmp(hyperprior, "Inverse gamma")
                [beta, theta0] = zef_find_ig_hyperprior(modified_SNR, ...
                    self.hyperprior_tail_length_db, L_sub, size(L_sub,2), normalize_data, balance_spatially, self.hyperprior_weight);
                d_sqrt = sqrt(theta0./(beta-1));
            elseif strcmp(hyperprior, "Gamma")
                [beta, theta0] = zef_find_g_hyperprior(modified_SNR, ...
                    self.hyperprior_tail_length_db, L_sub, size(L_sub,2), normalize_data, balance_spatially, self.hyperprior_weight);
                d_sqrt = sqrt(theta0.*beta);
            end
        for i = 1:n_iter(mr_ind)
            W = L_sub .* repmat(d_sqrt', size(L_sub,1), 1);
            W = d_sqrt.*(W' * inv(W * W' + S_mat)); %#ok<MINV>
            if strcmp(method_type, "dSPM each step")
                dspm_vec = sum(W.^2, 2);
                dspm_vec = sqrt(dspm_vec);
                W = W./dspm_vec;
            elseif strcmp(method_type, "dSPM last step")
                if i == n_iter(mr_ind)
                    dspm_vec = sum(W.^2, 2);
                    dspm_vec = sqrt(dspm_vec);
                    W = W./dspm_vec;
                end
            elseif strcmp(method_type, "sLORETA each step")
                sloreta_vec = sqrt(sum(W.*L_sub', 2));
                W = W./sloreta_vec(:,ones(size(W,2),1));
            elseif strcmp(method_type, "sLORETA last step")
                if i == n_iter(mr_ind)
                    sloreta_vec = sqrt(sum(W.*L_sub', 2));
                    W = W./sloreta_vec(:,ones(size(W,2),1));
                end
            end
            z_vec_sub = W*f;
            if strcmp(hyperprior, "Inverse gamma")
                d_sqrt = sqrt((theta0+0.5*z_vec_sub.^2)./(beta + 1.5));
            elseif strcmp(hyperprior, "Gamma")
                d_sqrt = sqrt(theta0.*(beta-1.5 + sqrt((1./(2.*theta0)).*z_vec_sub.^2 + (beta+1.5).^2)));
            end
        end
        d_sqrt = d_sqrt(multires_ind);
        z_vec = z_vec + z_vec_sub(multires_ind);
    end
end
z_vec = z_vec/(double(self.number_of_decompositions*n_lev)*sum(scaling_vec));
end
