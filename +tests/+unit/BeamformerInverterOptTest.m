classdef BeamformerInverterOptTest < matlab.unittest.TestCase
%BEAMFORMERINVERTEROPTTEST  Cached operator B*f matches the per-source loop.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(23, "twister");
        end
    end

    methods (Test)
        function testCachedMatchesLegacyAllSettings(testCase)
            [L, F, procFile, sp] = i_synth(36, 24, 2);
            methods = [ ...
                "Linearly constrained minimum variance (LCMV) beamformer", ...
                "Unit noise gain (UNG) beamformer", ...
                "Unit-gain constrained beamformer"];
            regs = ["Basic", "Pseudoinverse"];
            norms = ["None", "Matrix norm", "Column norm", "Row norm"];
            worst = 0;
            for mi = 1:numel(methods)
                for ri = 1:numel(regs)
                    for ni = 1:numel(norms)
                        [z_new, z_old] = i_pair(L, F, procFile, sp, ...
                            methods(mi), regs(ri), norms(ni));
                        testCase.verifyEqual(size(z_new), size(z_old));
                        testCase.verifyEqual(class(z_new), class(z_old));
                        mae = max(abs(z_new(:) - z_old(:)));
                        worst = max(worst, mae);
                        rel = norm(z_new(:) - z_old(:)) / max(norm(z_old(:)), eps);
                        testCase.verifyLessThanOrEqual(rel, 1e-12);
                    end
                end
            end
            testCase.verifyLessThanOrEqual(worst, 1e-12);
        end

        function testMixedFixedOrientation(testCase)
            [L, F, procFile, sp] = i_synth(32, 20, 2);
            procFile.s_ind_4 = (1:5)';
            [z_new, z_old] = i_pair(L, F, procFile, sp, ...
                "Linearly constrained minimum variance (LCMV) beamformer", ...
                "Basic", "None");
            rel = max(abs(z_new(:) - z_old(:))) / max(max(abs(z_old)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
            [z_new, z_old] = i_pair(L, F, procFile, sp, ...
                "Unit-gain constrained beamformer", "Basic", "Column norm");
            rel = max(abs(z_new(:) - z_old(:))) / max(max(abs(z_old)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
            testCase.verifyTrue(all(isfinite(z_new)));
        end

        function testMultiFrameOperatorReuse(testCase)
            [L, F, procFile, sp] = i_synth(28, 16, 4);
            inv_new = inverse.BeamformerInverter("number_of_frames", 4);
            inv_new = inv_new.initialize(L, F);
            inv_new = inv_new.precompute(L, procFile);
            inv_old = inverse.BeamformerInverter("number_of_frames", 4);
            inv_old.error_cov = inv_new.error_cov;
            for k = 1:4
                [z_new, ~] = inv_new.invert(F(:,k), L, procFile, 1, sp, "use_gpu", false);
                [z_old, ~] = inv_old.invert(F(:,k), L, procFile, 1, sp, "use_gpu", false);
                rel = max(abs(z_new(:) - z_old(:))) / max(max(abs(z_old)), eps);
                testCase.verifyLessThanOrEqual(rel, 1e-12);
            end
        end

        function testSingleSourceAndEmptyFixed(testCase)
            [L, F, procFile, sp] = i_synth(12, 1, 2);
            [z_new, z_old] = i_pair(L, F, procFile, sp, ...
                "Unit noise gain (UNG) beamformer", "Basic", "None");
            testCase.verifyEqual(size(z_new), [3, 1]);
            rel = max(abs(z_new(:) - z_old(:))) / max(max(abs(z_old)), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testTerminateClearsCacheKeepsUserCov(testCase)
            [L, F, procFile] = i_synth(16, 8, 2);
            inv = inverse.BeamformerInverter("number_of_frames", 2);
            inv = inv.initialize(L, F);
            inv.error_covSetted = true;
            C = inv.error_cov;
            inv = inv.precompute(L, procFile);
            testCase.verifyFalse(isempty(inv.precomputed_inverse_operator));
            inv = inv.terminateComputation();
            testCase.verifyTrue(isempty(inv.precomputed_inverse_operator));
            testCase.verifyEqual(inv.error_cov, C);
        end

        function testDispatchBeamformer(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_b, r_b] = zef_inverse_run(zef, "beamformer", "execution", "local");
            testCase.verifyTrue(~isempty(zef_b.reconstruction));
            testCase.verifyTrue(~isempty(r_b.reconstruction));
            recon = r_b.reconstruction;
            if iscell(recon)
                testCase.verifyEqual(numel(recon), zef.number_of_frames);
                testCase.verifyTrue(all(isfinite(recon{1})));
            else
                testCase.verifyTrue(all(isfinite(recon(:))));
            end
        end

        function testPluginFactorizationEquivalence(testCase)
            rng(5, "twister");
            n_ch = 24;
            C = cov(randn(80, n_ch)) + 0.05*eye(n_ch);
            L = randn(n_ch, 30);
            f = randn(n_ch, 1);
            C_sqrt = sqrtm(C);
            testCase.verifyLessThanOrEqual(max(abs((C_sqrt\L) - (sqrtm(C)\L)), [], "all"), 1e-12);
            testCase.verifyLessThanOrEqual(max(abs((C_sqrt\f) - (sqrtm(C)\f))), 1e-12);
            C_dec = decomposition(C);
            X = randn(n_ch, 3);
            testCase.verifyLessThanOrEqual(max(abs((C_dec\X) - (C\X)), [], "all"), 1e-12);
            L_aux = L(:, 1:3);
            L_c = C_dec \ L_aux;
            g1 = L_aux' * (C \ L_aux);
            g2 = L_aux' * L_c;
            testCase.verifyLessThanOrEqual(max(abs(g1(:) - g2(:))), 1e-12);
        end

        function testLCMVRecoversExactSourceWhenCIsIdentity(testCase)
            [L, ~, procFile, sp] = i_synth(32, 6, 2);
            src = 4;
            x = [0.3; -0.2; 0.5];
            f = L(:, 3*src - [2, 1, 0]) * x;
            inv = inverse.BeamformerInverter( ...
                "number_of_frames", 2, ...
                "method_type", "Linearly constrained minimum variance (LCMV) beamformer", ...
                "cov_reg_parameter", 0, ...
                "leadfield_reg_parameter", 0, ...
                "leadfield_normalization", "None");
            inv.error_cov = eye(size(L, 1));
            [z, ~] = inv.invert(f, L, procFile, 1, sp, "use_gpu", false);
            z_src = z(3*src - [2, 1, 0]);
            rel = norm(z_src - x) / max(norm(x), eps);
            testCase.verifyLessThanOrEqual(rel, 1e-12);
        end

        function testInvertWithoutErrorCovErrors(testCase)
            [L, F, procFile, sp] = i_synth(12, 3, 2);
            inv = inverse.BeamformerInverter("number_of_frames", 2);
            testCase.verifyError( ...
                @() inv.invert(F(:, 1), L, procFile, 1, sp, "use_gpu", false), ...
                "BeamformerInverter:MissingErrorCov");
        end

        function testLegacyBeamformerPluginSmoke(testCase)
            for bf_type = 1:4
                zef = i_plugin_zef();
                zef.bf_type = bf_type;
                [z, Var_loc, info] = zef_beamformer(zef);
                testCase.verifyTrue(iscell(z));
                testCase.verifyEqual(numel(z), zef.number_of_frames);
                testCase.verifyTrue(all(isfinite(z{1})));
                testCase.verifyTrue(iscell(Var_loc));
                testCase.verifyTrue(isfield(info, "tag"));
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
    "sizeL2", n_src, ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_src, 3));
sp = randn(n_src, 3);
end

function [z_new, z_old] = i_pair(L, F, procFile, sp, method, reg, nrm)
inv_new = inverse.BeamformerInverter( ...
    "number_of_frames", size(F, 2), ...
    "method_type", method, ...
    "reg_type", reg, ...
    "leadfield_normalization", nrm);
inv_new = inv_new.initialize(L, F);
inv_new = inv_new.precompute(L, procFile);
[z_new, ~] = inv_new.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);

inv_old = inverse.BeamformerInverter( ...
    "number_of_frames", size(F, 2), ...
    "method_type", method, ...
    "reg_type", reg, ...
    "leadfield_normalization", nrm);
inv_old.error_cov = inv_new.error_cov;
[z_old, ~] = inv_old.invert(F(:,1), L, procFile, 1, sp, "use_gpu", false);
end

function zef = i_plugin_zef()
zef = tests.support.createSyntheticInverseZef();
zef.bf_type = 1;
zef.cov_type = 1;
zef.inv_cov_lambda = 0.05;
zef.inv_leadfield_lambda = 0.001;
zef.L_reg_type = 1;
zef.beamformer.normalize_leadfield.Value = '4';
end
