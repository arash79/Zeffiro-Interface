classdef ELORETAInverterOptTest < matlab.unittest.TestCase
%ELORETAINVERTEROPTTEST  Block-page eLORETA precompute matches the dense W^{-1} loop.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(27, "twister");
        end
    end

    methods (Test)
        function testTripletOperatorMatchesLegacy(testCase)
            [L, F, procFile, sp] = i_synth(32, 24, 3);
            [new_out, old_out] = i_pair(L, F, procFile, sp, true, 80, 1e-8);
            i_assert_close(testCase, new_out, old_out);
        end

        function testNoAverageReferenceMatchesLegacy(testCase)
            [L, F, procFile, sp] = i_synth(28, 18, 2);
            [new_out, old_out] = i_pair(L, F, procFile, sp, false, 80, 1e-8);
            i_assert_close(testCase, new_out, old_out);
        end

        function testMixedFixedOrientationMatchesLegacy(testCase)
            [L, F, procFile, sp] = i_synth(36, 20, 2);
            procFile.s_ind_4 = (1:6)';
            [new_out, old_out] = i_pair(L, F, procFile, sp, true, 80, 1e-8);
            i_assert_close(testCase, new_out, old_out);
            testCase.verifyTrue(all(isfinite(new_out.z)));
        end

        function testAllFixedOrientationMatchesLegacy(testCase)
            [L, F, procFile, sp] = i_synth(24, 8, 1);
            procFile.s_ind_4 = (1:8)';
            [new_out, old_out] = i_pair(L, F, procFile, sp, true, 40, 1e-8);
            i_assert_close(testCase, new_out, old_out);
        end

        function testDiagonalLeadFieldMatchesLegacy(testCase)
            n_sens = 20;
            n_cols = 25;
            L = randn(n_sens, n_cols);
            F = randn(n_sens, 2);
            procFile = struct("s_ind_4", zeros(0,1), "s_ind_0", (1:n_cols)');
            sp = randn(n_cols, 3);
            [new_out, old_out] = i_pair(L, F, procFile, sp, true, 60, 1e-8);
            i_assert_close(testCase, new_out, old_out);
        end

        function testMultiFrameOperatorReuse(testCase)
            [L, F, procFile, sp] = i_synth(24, 12, 4);
            inv_new = inverse.ELORETAInverter("number_of_frames", 4);
            inv_new = inv_new.initialize(L, F);
            inv_new = inv_new.precompute(L, procFile);
            T = inv_new.precomputed_inverse_operator;
            for k = 1:4
                [z_k, inv_new] = inv_new.invert(F(:,k), L, procFile, 1, sp, "use_gpu", false);
                testCase.verifyEqual(inv_new.precomputed_inverse_operator, T);
                testCase.verifyEqual(z_k, T * F(:,k), "AbsTol", 1e-12);
            end
        end

        function testTerminateClearsCacheKeepsUserAlpha(testCase)
            [L, F, procFile] = i_synth(16, 8, 2);
            alpha_user = 0.042;
            inv = inverse.ELORETAInverter("number_of_frames", 2);
            inv.regularization_parameter = alpha_user;
            inv = inv.initialize(L, F);
            inv = inv.precompute(L, procFile);
            testCase.verifyFalse(isempty(inv.precomputed_inverse_operator));
            inv = inv.terminateComputation();
            testCase.verifyTrue(isempty(inv.precomputed_inverse_operator));
            testCase.verifyTrue(isempty(inv.precomputed_W_inv_diag));
            testCase.verifyEqual(inv.regularization_parameter, alpha_user, "AbsTol", 1e-12);
        end

        function testDispatchEloretaAndDspm(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_e, r_e] = zef_inverse_run(zef, "eloreta", "execution", "local");
            testCase.verifyTrue(~isempty(zef_e.reconstruction));
            testCase.verifyTrue(~isempty(r_e.reconstruction));
            recon = r_e.reconstruction;
            if iscell(recon)
                testCase.verifyEqual(numel(recon), zef.number_of_frames);
                testCase.verifyTrue(all(isfinite(recon{1})));
            else
                testCase.verifyTrue(all(isfinite(recon(:))));
            end
            [zef_d, r_d] = zef_inverse_run(zef, "dspm", "execution", "local");
            testCase.verifyTrue(~isempty(zef_d.reconstruction));
            testCase.verifyTrue(~isempty(r_d.reconstruction));
        end

        function testNoiseCovDoesNotChangeOperator(testCase)
            % Intentional: class eLORETA stores noise_cov but does not whiten.
            [L, F, procFile] = i_synth(20, 12, 2);
            inv1 = inverse.ELORETAInverter("number_of_frames", 2, ...
                "n_max_iterations", 40, "convergence_tolerance", 1e-8);
            inv1 = inv1.initialize(L, F);
            inv1 = inv1.precompute(L, procFile);
            T1 = inv1.precomputed_inverse_operator;

            inv2 = inverse.ELORETAInverter("number_of_frames", 2, ...
                "n_max_iterations", 40, "convergence_tolerance", 1e-8);
            inv2.noise_cov = 7 * eye(size(L, 1));
            inv2.regularization_parameter = inv1.regularization_parameter;
            inv2 = inv2.initialize(L, F);
            inv2 = inv2.precompute(L, procFile);
            testCase.verifyEqual(inv2.precomputed_inverse_operator, T1, "AbsTol", 1e-12);
        end

        function testReconstructionInformationStillPopulated(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, ~] = zef_inverse_run(zef, "eloreta", "execution", "local");
            info = zef_out.reconstruction_information;
            testCase.verifyTrue(isstruct(info));
            testCase.verifyTrue(isfield(info, "tag"));
            recon = zef_out.reconstruction;
            testCase.verifyTrue(~isempty(recon));
            if iscell(recon)
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
    "s_ind_4", zeros(0,1), ...
    "n_interp", n_src, ...
    "sizeL2", 3*n_src, ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_src, 3));
sp = randn(n_src, 3);
end

function [new_out, old_out] = i_pair(L, F, procFile, sp, apply_avg_ref, n_iter, tol)
inv_new = inverse.ELORETAInverter( ...
    "number_of_frames", size(F, 2), ...
    "n_max_iterations", n_iter, ...
    "convergence_tolerance", tol, ...
    "apply_average_reference", apply_avg_ref);
inv_new = inv_new.initialize(L, F);
inv_new = inv_new.precompute(L, procFile);
[z_new, inv_new] = inv_new.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);

inv_old = inverse.ELORETAInverter( ...
    "number_of_frames", size(F, 2), ...
    "n_max_iterations", n_iter, ...
    "convergence_tolerance", tol, ...
    "apply_average_reference", apply_avg_ref);
inv_old.regularization_parameter = inv_new.regularization_parameter;
inv_old.noise_cov = inv_new.noise_cov;
inv_old = i_legacy_precompute(inv_old, L, procFile);
z_old = inv_old.precomputed_inverse_operator * F(:,1);

new_out = i_pack(inv_new, z_new);
old_out = i_pack(inv_old, z_old);
end

function out = i_pack(inv, z)
out = struct( ...
    "z", z, ...
    "T", inv.precomputed_inverse_operator, ...
    "w_diag", inv.precomputed_W_inv_diag, ...
    "n_iter", inv.n_iterations_used, ...
    "residual", inv.final_residual);
end

function i_assert_close(testCase, new_out, old_out)
testCase.verifyEqual(size(new_out.z), size(old_out.z));
testCase.verifyEqual(size(new_out.T), size(old_out.T));
testCase.verifyEqual(size(new_out.w_diag), size(old_out.w_diag));
testCase.verifyEqual(new_out.n_iter, old_out.n_iter);
rel_z = max(abs(new_out.z(:) - old_out.z(:))) / max(max(abs(old_out.z(:))), eps);
rel_T = max(abs(new_out.T(:) - old_out.T(:))) / max(max(abs(old_out.T(:))), eps);
rel_w = max(abs(new_out.w_diag(:) - old_out.w_diag(:))) / max(max(abs(old_out.w_diag(:))), eps);
testCase.verifyLessThanOrEqual(rel_z, 1e-11);
testCase.verifyLessThanOrEqual(rel_T, 1e-11);
testCase.verifyLessThanOrEqual(rel_w, 1e-11);
testCase.verifyLessThanOrEqual(abs(new_out.residual - old_out.residual), 1e-10);
testCase.verifyTrue(all(isfinite(new_out.z)));
end

function self = i_legacy_precompute(self, L, procFile)
% Exact pre-optimization precompute: dense W_inv and per-source eig.
n_sensors = size(L,1);
n_cols = size(L,2);
alpha = self.regularization_parameter;

if self.apply_average_reference
    H = eye(n_sensors, "like", L) - ones(n_sensors, "like", L)/n_sensors;
else
    H = eye(n_sensors, "like", L);
end

W_inv = eye(n_cols, "like", L);
n_iterations = 0;
residual = Inf;

has_triplets = mod(n_cols, 3) == 0;
if has_triplets
    n_sources = n_cols/3;
else
    n_sources = n_cols;
end

fixed_source_inds = [];
if isstruct(procFile) && isfield(procFile, "s_ind_4")
    fixed_source_inds = procFile.s_ind_4(:);
end
free_source_inds = setdiff((1:n_sources)', fixed_source_inds);

for k = 1:self.n_max_iterations
    n_iterations = k;

    M = L * W_inv * L' + alpha * H;
    Minv = i_legacy_stable_inverse(M);

    W_inv_new = zeros(n_cols, n_cols, "like", L);

    if has_triplets
        for i = free_source_inds'
            ind = 3*i - [2,1,0];
            A_i = L(:,ind)' * Minv * L(:,ind);
            A_i = (A_i + A_i')/2;
            [V_i, D_i] = eig(A_i);
            eig_vals = real(diag(D_i));
            eig_floor = eps(i_legacy_underlying_class(A_i)) * max(1, max(abs(eig_vals)));
            eig_vals = max(eig_vals, eig_floor);
            block_inv = V_i * diag(1./sqrt(eig_vals)) * V_i';
            W_inv_new(ind,ind) = (block_inv + block_inv')/2;
        end

        for i = fixed_source_inds'
            ind = 3*i - [2,1,0];
            scalar_val = real(L(:,ind(1))' * Minv * L(:,ind(1)));
            scalar_floor = eps(i_legacy_underlying_class(M)) * max(1, abs(scalar_val));
            scalar_val = max(scalar_val, scalar_floor);
            W_inv_new(ind,ind) = eye(3, "like", L) / sqrt(scalar_val);
        end
    else
        diag_terms = real(sum(L .* (Minv * L), 1))';
        diag_floor = eps(i_legacy_underlying_class(M)) * max(1, max(abs(diag_terms)));
        diag_terms = max(diag_terms, diag_floor);
        W_inv_new = diag(1./sqrt(diag_terms));
    end

    residual = norm(W_inv_new - W_inv, "fro") / max(norm(W_inv, "fro"), eps(i_legacy_underlying_class(W_inv)));
    W_inv = W_inv_new;

    if residual < self.convergence_tolerance
        break;
    end
end

M_final = L * W_inv * L' + alpha * H;
Minv_final = i_legacy_stable_inverse(M_final);

self.precomputed_inverse_operator = W_inv * (L' * Minv_final);
self.precomputed_W_inv_diag = diag(W_inv);
self.n_iterations_used = n_iterations;
if isa(residual, "gpuArray")
    self.final_residual = gather(residual);
else
    self.final_residual = residual;
end
end

function Minv = i_legacy_stable_inverse(M)
I = eye(size(M,1), "like", M);
try
    M_decomp = decomposition(M, "chol");
    Minv = M_decomp \ I;
catch
    Minv = pinv(M);
end
end

function underlying = i_legacy_underlying_class(A)
if isa(A, "gpuArray")
    underlying = classUnderlying(A);
else
    underlying = class(A);
end
end
