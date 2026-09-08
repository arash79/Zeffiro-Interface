classdef KalmanRtsStoredDTest < matlab.unittest.TestCase
%KALMANRTSSTOREDDTEST  RTS standardizes with the filter D, including exponent.

    methods (TestMethodSetup)
        function seedRng(~)
            rng(17, "twister");
        end
    end

    methods (Test)
        function rtsAppliesStoredFilterD(testCase)
            n_sens = 8;
            n_dof = 6;
            n_frames = 5;
            L = randn(n_sens, n_dof);
            F = randn(n_sens, n_frames);
            procFile = struct("s_ind_0", (1:n_dof)', "s_ind_4", zeros(0,1));
            sp = randn(n_dof, 3);
            inv = inverse.KalmanInverter( ...
                "method_type", "Standardized Kalman filter", ...
                "number_of_frames", n_frames, ...
                "smoother_type", "RTS", ...
                "standardization_exponent", 1);
            inv = inv.initialize(L, F);
            inv.noise_cov = 0.1 * eye(n_sens);
            inv.evolution_cov = 0.01 * eye(n_dof);
            z_cell = cell(1, n_frames);
            for t = 1:n_frames
                [z_cell{t}, inv] = inv.invert(F(:, t), L, procFile, 1, sp, ...
                    "use_gpu", false);
            end
            testCase.verifyEqual(numel(inv.filter_standardization_D), n_frames);
            [z_s, inv] = inv.smoother(z_cell, L);
            D = inv.filter_standardization_D{n_frames};
            testCase.verifyEqual(z_s{n_frames}, D * z_cell{n_frames}, ...
                "AbsTol", 1e-10);
        end

        function rtsHonorsStandardizationExponent(testCase)
            n_sens = 7;
            n_dof = 6;
            n_frames = 4;
            L = randn(n_sens, n_dof);
            F = randn(n_sens, n_frames);
            procFile = struct("s_ind_0", (1:n_dof)', "s_ind_4", zeros(0,1));
            sp = randn(n_dof, 3);
            z_half = i_run(L, F, procFile, sp, 0.5);
            z_one = i_run(L, F, procFile, sp, 1);
            testCase.verifyGreaterThan(norm(z_half{1} - z_one{1}), 1e-8);
        end

        function pluginStoresRawMeanForRts(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            src = fileread(fullfile(root, "plugins", "Kalman", "m", ...
                "kalman_filter_sLORETA.m"));
            testCase.verifyTrue(contains(src, "z_inverse{f_ind} = gather(m)"));
            testCase.verifyTrue(contains(src, "D_store{f_ind}"));
            kf = fileread(fullfile(root, "plugins", "Kalman", "m", "zef_KF.m"));
            testCase.verifyTrue(contains(kf, "D_store{k} * z_inverse{k}"));
        end
    end
end

function z_s = i_run(L, F, procFile, sp, exponent)
n_frames = size(F, 2);
inv = inverse.KalmanInverter( ...
    "method_type", "Standardized Kalman filter", ...
    "number_of_frames", n_frames, ...
    "smoother_type", "RTS", ...
    "standardization_exponent", exponent);
inv = inv.initialize(L, F);
inv.noise_cov = 0.2 * eye(size(L, 1));
inv.evolution_cov = 0.02 * eye(size(L, 2));
z_cell = cell(1, n_frames);
for t = 1:n_frames
    [z_cell{t}, inv] = inv.invert(F(:, t), L, procFile, 1, sp, "use_gpu", false);
end
[z_s, ~] = inv.smoother(z_cell, L);
end
