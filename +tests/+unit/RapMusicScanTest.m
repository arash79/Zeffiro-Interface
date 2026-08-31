classdef RapMusicScanTest < matlab.unittest.TestCase
%RAPMUSICSCANTEST  RAP-MUSIC recovers known dipoles; orientations accumulate.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(31, "twister");
        end
    end

    methods (Test)
        function twoDipolesRecoveredWithDistinctOrientations(testCase)
            n_ch = 32;
            n_loc = 12;
            Lx = randn(n_ch, n_loc);
            Ly = randn(n_ch, n_loc);
            Lz = randn(n_ch, n_loc);
            L = [Lx, Ly, Lz];
            L_ind = [(1:n_loc).', n_loc+(1:n_loc).', 2*n_loc+(1:n_loc).'];
            loc = [3, 8];
            u1 = [1; 0; 0];
            u2 = [0; 1; 0];
            A = [L(:, L_ind(loc(1), :)) * u1, L(:, L_ind(loc(2), :)) * u2];
            T = 40;
            s = randn(2, T);
            f = A * s;
            [z_vec, loc_ind, orj_mat, A_top] = zef_rap_music_scan(L, L_ind, f, 2, 1e-12);
            testCase.verifyEqual(sort(loc_ind), loc);
            testCase.verifyEqual(size(A_top, 2), 2);
            testCase.verifyEqual(size(orj_mat, 2), 2);
            for k = 1:2
                if loc_ind(k) == loc(1)
                    testCase.verifyGreaterThan(abs(dot(orj_mat(:, k), u1)), 0.95);
                else
                    testCase.verifyGreaterThan(abs(dot(orj_mat(:, k), u2)), 0.95);
                end
            end
            amp = norm(z_vec(L_ind(loc(1), :)));
            amp2 = norm(z_vec(L_ind(loc(2), :)));
            others = setdiff(1:n_loc, loc);
            rest = zeros(numel(others), 1);
            for i = 1:numel(others)
                rest(i) = norm(z_vec(L_ind(others(i), :)));
            end
            testCase.verifyGreaterThan(min([amp, amp2]), max(rest) + 1e-8);
        end

        function singlePeelFindsStrongerSource(testCase)
            n_ch = 24;
            n_loc = 8;
            Lx = randn(n_ch, n_loc);
            Ly = randn(n_ch, n_loc);
            Lz = randn(n_ch, n_loc);
            Lz(:, 5) = 8 * Lz(:, 5);
            L = [Lx, Ly, Lz];
            L_ind = [(1:n_loc).', n_loc+(1:n_loc).', 2*n_loc+(1:n_loc).'];
            u = [0; 0; 1];
            a = L(:, L_ind(5, :)) * u;
            t = linspace(0, 2*pi, 30);
            f = a * sin(t);
            [~, loc_ind] = zef_rap_music_scan(L, L_ind, f, 1, 1e-10);
            testCase.verifyEqual(loc_ind, 5);
        end

        function mode3ScalarColumns(testCase)
            n_ch = 20;
            n_loc = 10;
            L = randn(n_ch, n_loc);
            L(:, [2, 7]) = 10 * L(:, [2, 7]);
            L_ind = (1:n_loc).';
            A = L(:, [2, 7]);
            f = A * randn(2, 40);
            [z_vec, loc_ind] = zef_rap_music_scan(L, L_ind, f, 2, 1e-12);
            testCase.verifyEqual(sort(loc_ind), [2, 7]);
            testCase.verifyGreaterThan(max(abs(z_vec([2, 7]))), ...
                max(abs(z_vec(setdiff(1:n_loc, [2, 7])))));
        end

        function subspaceCorrMaxIsScalarForRankOneSignal(testCase)
            A = randn(20, 3);
            B = A * [0; 0; 1];
            s = zef_subspace_corr(A, B, 'max');
            testCase.verifyTrue(isscalar(s) && isreal(s));
            testCase.verifyGreaterThan(s, 1 - 1e-12);
            A2 = randn(20, 3);
            s2 = zef_subspace_corr(A2, B, 'max');
            testCase.verifyTrue(isscalar(s2));
            testCase.verifyLessThan(s2, s);
        end

        function blockedIndexUsesNInterpNotUnexpandedOverThree(testCase)
            n_interp = 12;
            L_ind = zef_blocked_source_index(n_interp, 1);
            testCase.verifyEqual(size(L_ind), [n_interp, 3]);
            testCase.verifyEqual(L_ind(1, :), [1, 13, 25]);
            testCase.verifyEqual(L_ind(end, :), [12, 24, 36]);
            wrong_nn = n_interp / 3;
            testCase.verifyNotEqual(size(L_ind, 1), wrong_nn);
            L_ind3 = zef_blocked_source_index(n_interp, 3);
            testCase.verifyEqual(L_ind3(:), (1:n_interp).');
        end
    end
end
