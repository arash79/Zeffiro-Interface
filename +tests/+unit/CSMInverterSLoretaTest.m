classdef CSMInverterSLoretaTest < matlab.unittest.TestCase
%CSMINVERTERSLORETATEST  sLORETA / sLORETA 3D numerics and dispatch smoke.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(11, "twister");
        end
    end

    methods (Test)
        function testSLoretaMatchesReferenceFormula(testCase)
            [L, F, procFile, sp] = i_synth(12, 8, 3);
            inv = inverse.CSMInverter("method_type", "sLORETA", ...
                "number_of_frames", 3, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            inv = inv.precompute(L);
            [z, inv] = inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            P = inv.precomputed_P;
            d = inv.precomputed_d;
            z_ref = (d .* (P * F(:,1))) / sqrt(inv.theta0);
            z_old_assoc = d .* P * F(:,1) / sqrt(inv.theta0);
            testCase.verifyEqual(size(z), [size(L,2), 1]);
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyLessThanOrEqual(max(abs(z - z_ref)), 1e-12);
            testCase.verifyLessThanOrEqual(max(abs(z - z_old_assoc)), 1e-12);
        end

        function testSLoreta3DMatchesSqrtmLoop(testCase)
            [L, F, procFile, sp] = i_synth(16, 12, 2);
            n = 12;
            inv = inverse.CSMInverter("method_type", "sLORETA 3D", ...
                "number_of_frames", 2, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            inv = inv.precompute(L);
            testCase.verifyFalse(isempty(inv.precomputed_P));
            testCase.verifyEqual(size(inv.precomputed_Minv), [3, 3, n]);
            [z, inv] = inv.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
            z_ref = i_sqrtm_loop(inv.precomputed_P, L, F(:,1), n, inv.theta0);
            rel = max(abs(z - z_ref)) / max(abs(z_ref));
            testCase.verifyTrue(all(isfinite(z)));
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testSLoreta3DMode2ConstrainedNodes(testCase)
            n = 10;
            [L, F, procFile, sp] = i_synth(20, n, 1);
            procFile.s_ind_4 = (1:3)';
            inv = inverse.CSMInverter("method_type", "sLORETA 3D", ...
                "number_of_frames", 1, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            inv = inv.precompute(L);
            [z, inv] = inv.invert(F(:,1), L, procFile, 2, sp, "use_gpu", false);
            z_ref = i_sqrtm_loop_mode2(inv.precomputed_P, L, F(:,1), n, ...
                inv.theta0, procFile);
            rel = max(abs(z - z_ref)) / max(abs(z_ref));
            testCase.verifyLessThanOrEqual(rel, 1e-12);
            % Inverse-tools CSM (zef_CSM_iteration, csm_type 3, mode 2) uses
            % the same 1/sqrt surface weights on constrained nodes.
        end

        function testCacheInvalidatedWhenTheta0Changes(testCase)
            % Regression: precompute bakes theta0 into P, but invert also
            % divides by sqrt(theta0). Changing theta0 after precompute used
            % to mix an old P with the new scaling (~10% error on this input).
            [L, F, procFile, sp] = i_synth(14, 9, 1);
            inv_stale = inverse.CSMInverter("method_type", "sLORETA", ...
                "theta0", 1e-3, "number_of_frames", 1, ...
                "signal_to_noise_ratio", 30);
            inv_stale = inv_stale.precompute(L);
            inv_stale.theta0 = 1e-1;
            [z_stale, ~] = inv_stale.invert(F(:,1), L, procFile, 1, sp, ...
                "use_gpu", false);

            inv_fresh = inverse.CSMInverter("method_type", "sLORETA", ...
                "theta0", 1e-1, "number_of_frames", 1, ...
                "signal_to_noise_ratio", 30);
            [z_fresh, ~] = inv_fresh.invert(F(:,1), L, procFile, 1, sp, ...
                "use_gpu", false);

            testCase.verifyEqual(z_stale, z_fresh, "RelTol", 1e-12, ...
                "Changing theta0 after precompute must not use the stale cache.");
        end

        function testCacheInvalidatedWhenSnrChanges(testCase)
            % Same hazard through the other parameter that enters S_mat.
            [L, F, procFile, sp] = i_synth(14, 9, 1);
            inv_stale = inverse.CSMInverter("method_type", "dSPM", ...
                "theta0", 1e-3, "number_of_frames", 1, ...
                "signal_to_noise_ratio", 30);
            inv_stale = inv_stale.precompute(L);
            inv_stale.signal_to_noise_ratio = 5;
            [z_stale, ~] = inv_stale.invert(F(:,1), L, procFile, 1, sp, ...
                "use_gpu", false);

            inv_fresh = inverse.CSMInverter("method_type", "dSPM", ...
                "theta0", 1e-3, "number_of_frames", 1, ...
                "signal_to_noise_ratio", 5);
            [z_fresh, ~] = inv_fresh.invert(F(:,1), L, procFile, 1, sp, ...
                "use_gpu", false);

            testCase.verifyEqual(z_stale, z_fresh, "RelTol", 1e-12, ...
                "Changing the SNR after precompute must not use the stale cache.");
        end

        function testDispatchSLoretaPopulatesReconstruction(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "sloreta", ...
                "execution", "local", ...
                "MethodParams", struct("method_type", "sLORETA"));
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

        function testDispatchSLoreta3DPopulatesReconstruction(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "sloreta3d", ...
                "execution", "local", ...
                "MethodParams", struct("method_type", "sLORETA 3D"));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(~isempty(run_result.reconstruction));
        end

        function testSLoreta3DUsesInterleavedTripletsNotBlocked(testCase)
            n = 4;
            n_sens = 10;
            L = zeros(n_sens, 3*n);
            for k = 1:n
                cols = 3*k-2:3*k;
                L(:, cols) = randn(n_sens, 3) + 4*k;
            end
            F = randn(n_sens, 1);
            procFile = struct("s_ind_0", (1:n)', "s_ind_4", zeros(0,1), ...
                "n_interp", n, "sizeL2", n, "source_direction_mode", 1, ...
                "source_directions", zeros(n, 3));
            sp = randn(n, 3);
            inv = inverse.CSMInverter("method_type", "sLORETA 3D", ...
                "number_of_frames", 1, "signal_to_noise_ratio", 30);
            inv = inv.initialize(L, F);
            inv = inv.precompute(L);
            [z, inv] = inv.invert(F, L, procFile, 1, sp, "use_gpu", false);
            z_inter = i_sqrtm_loop(inv.precomputed_P, L, F, n, inv.theta0);
            z_block = zeros(size(z_inter));
            zb = inv.precomputed_P * F;
            for i = 1:n
                ind = [i, i+n, i+2*n];
                M = sqrtm(inv.precomputed_P(ind,:)*L(:,ind));
                zb(ind) = M\zb(ind);
            end
            z_block = zb / sqrt(inv.theta0);
            testCase.verifyLessThanOrEqual( ...
                max(abs(z - z_inter)) / max(abs(z_inter)), 1e-10);
            testCase.verifyGreaterThan(max(abs(z_inter - z_block)), ...
                1e-3 * max(abs(z_inter)));
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

function z_vec = i_sqrtm_loop(P, L, f, n, theta0)
z_vec = P * f;
[ix, iy, iz] = zef_interleaved_source_columns(1:n);
for i = 1:n
    ind = [ix(i), iy(i), iz(i)];
    M = sqrtm(P(ind,:)*L(:,ind));
    z_vec(ind) = M\z_vec(ind);
end
z_vec = z_vec / sqrt(theta0);
end

function z_vec = i_sqrtm_loop_mode2(P, L, f, n, theta0, procFile)
z_vec = P * f;
r_ind = setdiff(1:n, procFile.s_ind_4);
[sx, sy, sz] = zef_interleaved_source_columns(procFile.s_ind_4);
surf_ind = [sx; sy; sz];
M = 1./sqrt(sum(P(surf_ind,:).'.*L(:,surf_ind),1))';
z_vec(surf_ind) = M.*z_vec(surf_ind);
[ix, iy, iz] = zef_interleaved_source_columns(r_ind);
for i = 1:numel(r_ind)
    ind = [ix(i), iy(i), iz(i)];
    M = sqrtm(P(ind,:)*L(:,ind));
    z_vec(ind) = M\z_vec(ind);
end
z_vec = z_vec / sqrt(theta0);
end
