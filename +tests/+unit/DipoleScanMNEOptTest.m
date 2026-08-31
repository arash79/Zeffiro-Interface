classdef DipoleScanMNEOptTest < matlab.unittest.TestCase
%DIPOLESCANMNEOPTTEST  Equivalence of Dipole Scan / MNE implementation opts.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(19, "twister");
        end
    end

    methods (Test)
        function testDipoleScanPagesvdMatchesSvdLoop(testCase)
            [L, F, procFile, sp] = i_synth(48, 60, 2);
            f = F(:,1);
            for reg = ["None", "Basic"]
                inv_new = inverse.DipoleScanInverter( ...
                    "number_of_frames", 2, "reg_type", reg, "reg_parameter", 1e-3);
                inv_new = inv_new.initialize(L, F);
                inv_new = inv_new.precompute(L);
                [z_new, ~] = inv_new.invert(f, L, procFile, 1, sp, "use_gpu", false);

                inv_old = inverse.DipoleScanInverter( ...
                    "number_of_frames", 2, "reg_type", reg, "reg_parameter", 1e-3);
                inv_old = inv_old.initialize(L, F);
                inv_old.noise_cov = inv_new.noise_cov;
                inv_old = i_precompute_svd_loop(inv_old, L);
                [z_old, ~] = inv_old.invert(f, L, procFile, 1, sp, "use_gpu", false);

                testCase.verifyEqual(size(z_new), size(z_old));
                testCase.verifyEqual(z_new, z_old);
            end
        end

        function testDipoleScanMixedFixedOrientation(testCase)
            [L, F, procFile, sp] = i_synth(32, 40, 1);
            procFile.s_ind_4 = (1:7)';
            inv_new = inverse.DipoleScanInverter("number_of_frames", 2);
            inv_new = inv_new.initialize(L, F);
            inv_new = inv_new.precompute(L);
            [z_new, ~] = inv_new.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);

            inv_old = inverse.DipoleScanInverter("number_of_frames", 2);
            inv_old = inv_old.initialize(L, F);
            inv_old.noise_cov = inv_new.noise_cov;
            inv_old = i_precompute_svd_loop(inv_old, L);
            [z_old, ~] = inv_old.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            testCase.verifyEqual(z_new, z_old);
            testCase.verifyTrue(all(isfinite(z_new)));
        end

        function testDipoleScanCachedMatchesLegacyInvert(testCase)
            [L, F, procFile, sp] = i_synth(24, 18, 1);
            inv = inverse.DipoleScanInverter("number_of_frames", 2);
            inv = inv.initialize(L, F);
            inv = inv.precompute(L);
            [z_cached, ~] = inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);

            inv2 = inverse.DipoleScanInverter("number_of_frames", 2);
            inv2.noise_cov = inv.noise_cov;
            inv2.method_type = inv.method_type;
            inv2.reg_type = inv.reg_type;
            inv2.reg_parameter = inv.reg_parameter;
            [z_legacy, ~] = inv2.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            rel = max(abs(z_cached(:) - z_legacy(:))) / max(max(abs(z_legacy)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testMNEPrecomputeWfUnchanged(testCase)
            [L, F, procFile, sp] = i_synth(40, 25, 3);
            inv = inverse.MNEInverter("number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            theta = inv.theta;
            C = inv.noise_cov;
            L_modified = L .* theta;
            W_ref = L_modified' / (L_modified * L' + C);
            inv = inv.precompute(L);
            testCase.verifyEqual(size(inv.precomputed_inverse_operator), size(W_ref));
            testCase.verifyLessThanOrEqual( ...
                max(abs(inv.precomputed_inverse_operator(:) - W_ref(:))), 1e-12);
            [z, ~] = inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            z_ref = W_ref * F(:,1);
            testCase.verifyEqual(z, z_ref);
        end

        function testMNEFallbackWithoutCacheDefinesC(testCase)
            [L, F, procFile, sp] = i_synth(12, 6, 2);
            inv = inverse.MNEInverter("number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            [z, ~] = inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            L_modified = L .* inv.theta;
            z_ref = L_modified' * ((L_modified * L' + inv.noise_cov) \ F(:,1));
            testCase.verifyLessThanOrEqual(max(abs(z(:) - z_ref(:))), 1e-12);
        end

        function testLegacyMneOperatorHoistMatchesPerFrame(testCase)
            n_ch = 32; n_src = 40; n_fr = 5;
            L = randn(n_ch, 3*n_src);
            F = randn(n_ch, n_fr);
            S_mat = (10^(-30/20))^2 * eye(n_ch);
            theta0 = 1e-10;
            n_interp = n_src;
            for mne_type = [1, 2, 3, 4]
                L_inv = i_legacy_mne_build(L, theta0, S_mat, mne_type, n_interp);
                for i = 1:n_fr
                    z_hoist = L_inv * F(:,i);
                    z_inside = i_legacy_mne_inside(L, F(:,i), theta0, S_mat, mne_type, n_interp);
                    testCase.verifyLessThanOrEqual(max(abs(z_hoist(:) - z_inside(:))), 1e-12);
                end
            end
        end

        function testLegacyDipoleKernelMatchesSourceLoop(testCase)
            n_ch = 24; n_src = 30;
            L = randn(n_ch, 3*n_src);
            f = randn(n_ch, 1);
            normal = (1:4)';
            notNormal = setdiff(1:n_src, normal)';
            z_old = i_legacy_dipole_loop(L, f, n_src, normal, notNormal, false, 3);
            z_new = i_legacy_dipole_new(L, f, n_src, normal, notNormal, false, 3);
            rel = max(abs(z_old(:) - z_new(:))) / max(max(abs(z_old)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);

            z_old_r = i_legacy_dipole_loop(L, f, n_src, normal, notNormal, true, 2);
            z_new_r = i_legacy_dipole_new(L, f, n_src, normal, notNormal, true, 2);
            rel_r = max(abs(z_old_r(:) - z_new_r(:))) / max(max(abs(z_old_r)), eps);
            testCase.verifyLessThanOrEqual(rel_r, 1e-12);
        end

        function testDispatchMneAndDipolescan(testCase)
            zef = tests.support.createSyntheticInverseZef();
            zef.inv_hyperprior = 1;
            [zef_m, r_m] = zef_inverse_run(zef, "mne", "execution", "local");
            testCase.verifyTrue(~isempty(zef_m.reconstruction));
            testCase.verifyTrue(~isempty(r_m.reconstruction));
            [zef_d, r_d] = zef_inverse_run(zef, "dipolescan", "execution", "local");
            testCase.verifyTrue(~isempty(zef_d.reconstruction));
            testCase.verifyTrue(~isempty(r_d.reconstruction));
        end

        function testLegacyDipoleScanPluginSmoke(testCase)
            zef = tests.support.createSyntheticInverseZef();
            zef.inv_hyperprior = 1;
            zef.dipole_app.InversionmethodDropDown.Value = "SVD";
            zef.dipole_app.regType.Value = "None";
            zef.dipole_app.inv_leadfield_lambda.Value = "3";
            [z, info] = zef_dipoleScan(zef);
            testCase.verifyTrue(iscell(z));
            testCase.verifyEqual(numel(z), zef.number_of_frames);
            testCase.verifyTrue(all(isfinite(z{1})));
            testCase.verifyTrue(isfield(info, "tag"));
        end
    end
end

function [L, F, procFile, sp] = i_synth(n_sens, n_src, n_frames)
L = randn(n_sens, 3*n_src);
F = randn(n_sens, n_frames);
procFile = struct( ...
    "s_ind_0", (1:n_src)', ...
    "s_ind_4", zeros(0,1), ...
    "n_interp", n_src, ...
    "sizeL2", n_src, ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_src, 3));
sp = randn(n_src, 3);
end

function self = i_precompute_svd_loop(self, L)
%I_PRECOMPUTE_SVD_LOOP  Historical per-source svd(...,'econ') precompute.
n_ch = size(L, 1);
n_cols = size(L, 2);
n_sources = n_cols / 3;
Chalf = sqrtm(self.noise_cov);
self.precomputed_whitening = Chalf \ eye(n_ch);
self.precomputed_L_w = self.precomputed_whitening * L;
reg_on = ~strcmp(self.reg_type, "None");
U_pages = zeros(n_ch, 3, n_sources);
S_diag  = zeros(3, n_sources);
V_pages = zeros(3, 3, n_sources);
for i = 1:n_sources
    ind3 = 3*i - [2, 1, 0];
    LF = self.precomputed_L_w(:, ind3);
    [U, S, V] = svd(LF, 'econ');
    s = diag(S);
    if reg_on
        s = s + self.reg_parameter;
    end
    U_pages(:, :, i) = U;
    S_diag(:, i)     = s;
    V_pages(:, :, i) = V;
end
self.precomputed_U_pages = U_pages;
self.precomputed_S_diag  = S_diag;
self.precomputed_V_pages = V_pages;
% This helper stands in for precompute, so it must stamp the same cache key.
% Without it invert treats the hand-populated caches as stale and silently
% falls back to the per-call path, which is not what these tests compare.
self.precomputed_cache_key = self.cacheKey(L);
end

function L_inv = i_legacy_mne_build(L, theta0, S_mat, mne_type, n_interp)
d_sqrt = sqrt(theta0)*ones(size(L,2),1);
if isequal(mne_type,4)
    aux_vec = repelem(sum(reshape(sum(L.^2,1),n_interp,[]),2),3);
    d_sqrt = d_sqrt./(aux_vec.^(0.5*0.6));
end
L_inv = L.*repmat(d_sqrt',size(L,1),1);
L_inv = d_sqrt.*(L_inv'*(inv(L_inv*L_inv' + S_mat)));
if isequal(mne_type,2)
    aux_vec = sqrt(sum(L_inv.^2, 2));
    L_inv = L_inv./aux_vec;
elseif isequal(mne_type, 3)
    aux_vec = sqrt(sum(L_inv.*L', 2));
    L_inv = L_inv./aux_vec;
end
end

function z = i_legacy_mne_inside(L, f, theta0, S_mat, mne_type, n_interp)
L_inv = i_legacy_mne_build(L, theta0, S_mat, mne_type, n_interp);
z = L_inv * f;
end

function z_vec = i_legacy_dipole_loop(L, f, n_src, normal, notNormal, rank_reduce, k)
z_vec = nan(size(L,2),1);
fn2 = sum(f.^2);
for j = 1:length(normal)
    i = normal(j);
    lf = L(:,i);
    [U,S,V] = svd(lf, 'econ');
    mom = V*(S\(U'))*f;
    pot = lf*mom;
    z_vec(i) = 1 - sum((f-pot).^2) ./ fn2;
    z_vec(i+n_src) = z_vec(i);
    z_vec(i+2*n_src) = z_vec(i);
end
for j = 1:length(notNormal)
    i = notNormal(j);
    lf = [L(:,i), L(:,i+n_src), L(:,i+2*n_src)];
    if rank_reduce
        [~,~,V_reg] = svd(lf, 'econ');
        lf = lf*V_reg(:, 1:k);
    end
    [U,S,V] = svd(lf, 'econ');
    mom = V*(S\(U'))*f;
    pot = lf*mom;
    if rank_reduce
        momReg = [0 0 0];
        for kreg = 1:k
            momReg(1) = momReg(1)+mom(kreg)*V_reg(1, kreg);
            momReg(2) = momReg(2)+mom(kreg)*V_reg(2, kreg);
            momReg(3) = momReg(3)+mom(kreg)*V_reg(3, kreg);
        end
        mom = momReg;
    end
    mom = mom/norm(mom);
    gof = 1 - sum((f-pot).^2) ./ fn2;
    z_vec(i) = gof*mom(1);
    z_vec(i+n_src) = gof*mom(2);
    z_vec(i+2*n_src) = gof*mom(3);
end
end

function z_vec = i_legacy_dipole_new(L, f, n_src, normal, notNormal, rank_reduce, k)
scan.normal = normal;
scan.notNormal = notNormal;
scan.n_interp = n_src;
scan.rank_reduce = rank_reduce;
scan.k = k;
scan = i_precompute_scan_test(scan, L);
z_vec = nan(size(L,2),1);
z_vec = i_apply_scan_test(z_vec, f, scan);
end

function scan = i_precompute_scan_test(scan, L)
n_ch = size(L, 1);
n_interp = scan.n_interp;
normal = scan.normal(:);
notNormal = scan.notNormal(:);
n_free = numel(notNormal);
if isempty(normal)
    scan.L_fixed = [];
else
    scan.L_fixed = L(:, normal);
end
scan.U = []; scan.S = []; scan.V = []; scan.V_reg = [];
if n_free == 0
    return
end
L_pages = zeros(n_ch, 3, n_free);
L_pages(:, 1, :) = L(:, notNormal);
L_pages(:, 2, :) = L(:, notNormal + n_interp);
L_pages(:, 3, :) = L(:, notNormal + 2*n_interp);
if scan.rank_reduce && isfinite(scan.k) && scan.k >= 1 && scan.k <= 3
    [~, ~, V_all] = pagesvd(L_pages, "econ");
    kk = scan.k;
    scan.V_reg = V_all(:, 1:kk, :);
    L_red = pagemtimes(L_pages, scan.V_reg);
    [U, S_vec, V] = pagesvd(L_red, "econ", "vector");
    scan.U = U;
    scan.S = reshape(S_vec, kk, n_free);
    scan.V = V;
else
    [U, S_vec, V] = pagesvd(L_pages, "econ", "vector");
    scan.U = U;
    scan.S = reshape(S_vec, 3, n_free);
    scan.V = V;
    scan.V_reg = [];
    scan.rank_reduce = false;
end
end

function z_vec = i_apply_scan_test(z_vec, f, scan)
fn2 = sum(f.^2);
if fn2 <= 0
    return
end
n_interp = scan.n_interp;
normal = scan.normal(:);
notNormal = scan.notNormal(:);
if ~isempty(normal) && ~isempty(scan.L_fixed)
    Lfix = scan.L_fixed;
    coln2 = sum(Lfix.^2, 1).';
    proj = Lfix.' * f;
    safe = coln2; safe(safe==0)=1;
    gof_fixed = (proj.^2 ./ safe) / fn2;
    gof_fixed(coln2==0)=0;
    z_vec(normal) = gof_fixed;
    z_vec(normal + n_interp) = gof_fixed;
    z_vec(normal + 2*n_interp) = gof_fixed;
end
n_free = numel(notNormal);
if n_free == 0 || isempty(scan.U)
    return
end
k = size(scan.S, 1);
alpha = reshape(pagemtimes(scan.U, "transpose", f, "none"), k, n_free);
gof = (sum(alpha.^2, 1) / fn2).';
safe_S = scan.S; safe_S(safe_S==0)=1;
scaled = alpha ./ safe_S; scaled(scan.S==0)=0;
mom = reshape(pagemtimes(scan.V, reshape(scaled, k, 1, n_free)), k, n_free);
if scan.rank_reduce && ~isempty(scan.V_reg)
    mom3 = reshape(pagemtimes(scan.V_reg, reshape(mom, k, 1, n_free)), 3, n_free);
else
    mom3 = mom;
end
mn = sqrt(sum(mom3.^2, 1)); mn(mn==0)=1;
mom3 = mom3 ./ mn;
z_vec(notNormal) = gof .* mom3(1, :).';
z_vec(notNormal + n_interp) = gof .* mom3(2, :).';
z_vec(notNormal + 2*n_interp) = gof .* mom3(3, :).';
end
