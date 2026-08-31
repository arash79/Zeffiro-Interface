classdef UKFNMMInverterTest < matlab.unittest.TestCase
%UKFNMMINVERTERTEST  inverse.UKFNMMInverter spatial KF + NMM/UKF on synthetic L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Covers construction, initialize dimensions, per-frame invert,
%   run_frame_loop without NMM, smoother NMM exactly once, RTS / Sample
%   RTS, CPU, GPU fallback, and edge-case errors.

    methods (TestMethodSetup)
        function seedRngAndCloseWaitbars(~)
            rng(1, "twister");
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
        function testConstructDefaults(testCase)
            inverter = inverse.UKFNMMInverter();
            testCase.verifyEqual(inverter.number_of_corrclusters, 3);
            testCase.verifyEqual(inverter.score_threshold, 0.2);
            testCase.verifyEqual(inverter.alpha, 1);
            testCase.verifyEqual(inverter.kappa, 0);
            testCase.verifyEqual(inverter.beta, 2);
            testCase.verifyEqual(inverter.evolution_prior_model, "Sensitivity scaling");
            testCase.verifyEqual(inverter.smoother_type, "None");
            testCase.verifyTrue(inverter.use_smoothing);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 0);
            testCase.verifyEqual(inverter.DOI, "");
        end

        function testConstructCustomNMMUKFParameters(testCase)
            inverter = inverse.UKFNMMInverter( ...
                "number_of_corrclusters", 2, ...
                "score_threshold", 0.35, ...
                "alpha", 1, ...
                "kappa", 1, ...
                "beta", 2, ...
                "smoother_type", "RTS", ...
                "evolution_prior_model", "Reworked original", ...
                "number_of_frames", 8, ...
                "sampling_frequency", 200);
            testCase.verifyEqual(inverter.number_of_corrclusters, 2);
            testCase.verifyEqual(inverter.score_threshold, 0.35);
            testCase.verifyEqual(inverter.alpha, 1);
            testCase.verifyEqual(inverter.kappa, 1);
            testCase.verifyEqual(inverter.beta, 2);
            testCase.verifyEqual(inverter.smoother_type, "RTS");
            testCase.verifyTrue(inverter.use_smoothing);
            testCase.verifyEqual(inverter.number_of_frames, 8);
            testCase.verifyEqual(inverter.sampling_frequency, 200);
        end

        function testUseSmoothingCannotBeDisabled(testCase)
            inverter = inverse.UKFNMMInverter("use_smoothing", false);
            testCase.verifyTrue(inverter.use_smoothing);
            inverter.use_smoothing = false;
            testCase.verifyTrue(inverter.use_smoothing);
            inverter.smoother_type = "None";
            testCase.verifyTrue(inverter.use_smoothing);
            testCase.verifyEqual(inverter.smoother_type, "None");
        end

        function testInitializeDimensionsAndModifiedL(testCase)
            [L, f_data] = i_synth_leadfield_data(8, 4, 6);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 6, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);

            testCase.verifyEqual(size(inverter.modified_L), size(L));
            testCase.verifyEqual(numel(inverter.theta0), size(L, 2));
            testCase.verifyEqual(size(inverter.noise_cov), [size(L, 1), size(L, 1)]);
            testCase.verifyEqual(size(inverter.state_transition_model_A), [size(L, 2), size(L, 2)]);
            testCase.verifyEqual(size(inverter.evolution_cov), [size(L, 2), size(L, 2)]);
            testCase.verifyEmpty(inverter.prev_step_reconstruction);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 0);

            expected = i_upstream_modified_L(L);
            testCase.verifyEqual(inverter.modified_L, expected, "AbsTol", 1e-12);
            testCase.verifyEqual(size(inverter.u_to_dipole), [3, 3, 4]);
            for n = 1:4
                cols = 3 * n - [2, 1, 0];
                U = inverter.modified_L(:, cols);
                testCase.verifyEqual(U' * U, eye(3), "AbsTol", 1e-10);
            end
        end

        function testUSpaceStateMapsToPhysicalDipoles(testCase)
            rng(7, "twister");
            L = randn(12, 6);
            p = [0.4; -0.2; 0.8; 1.1; 0.3; -0.5];
            y = L * p;
            f_data = [y, y, y, y];
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);
            x_U = zeros(6, 1);
            for n = 1:2
                cols = 3 * n - [2, 1, 0];
                [~, S, V] = svd(L(:, cols), "econ");
                x_U(cols) = S * V' * p(cols);
                p_hat = inverter.u_to_dipole(:, :, n) * x_U(cols);
                testCase.verifyEqual(p_hat, p(cols), "AbsTol", 1e-10);
            end
            testCase.verifyEqual(inverter.modified_L * x_U, y, "AbsTol", 1e-10);
            testCase.verifyGreaterThan(norm(L * x_U - y), 1e-6);
        end

        function testSmootherMapsUSpaceBeforeNMM(testCase)
            src = fileread(fullfile("+inverse", "@UKFNMMInverter", "smoother.m"));
            testCase.verifyTrue(contains(src, "i_map_u_space_to_dipoles"));
            testCase.verifyTrue(contains(src, "self.u_to_dipole"));
        end

        function testInitializeUserSuppliedQ(testCase)
            [L, f_data] = i_synth_leadfield_data(6, 3, 4);
            Q = eye(size(L, 2)) * 0.05;
            inverter = inverse.UKFNMMInverter( ...
                "evolution_prior_model", "User supplied Q", ...
                "evolution_cov", Q, ...
                "number_of_frames", 4);
            inverter = inverter.initialize(L, f_data);
            testCase.verifyEqual(inverter.evolution_cov, Q);
        end

        function testOneFrameInvertDoesNotRunNMM(testCase)
            [L, f_data, procFile, source_positions] = i_synth_leadfield_data(8, 4, 5);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 5, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);
            [z_vec, inverter] = inverter.invert( ...
                f_data(:, 1), L, procFile, 1, source_positions, ...
                "use_gpu", false, "normalize_data", 1);
            testCase.verifySize(z_vec, [size(L, 2), 1]);
            testCase.verifyTrue(all(isfinite(z_vec)));
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 0);
            testCase.verifyEmpty(inverter.time_series);
        end

        function testSpatialUpdateMatchesClassKFOnModifiedL(testCase)
            [L, f_data, procFile, source_positions] = i_synth_leadfield_data(8, 3, 4);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);

            [z_vec, inverter] = inverter.invert( ...
                f_data(:, 1), L, procFile, 1, source_positions, ...
                "use_gpu", false, "normalize_data", 1);

            x0 = zeros(size(L, 2), 1);
            P0 = diag(inverter.theta0(:));
            ref = inverter;
            ref.prev_step_reconstruction = x0;
            ref.prev_step_posterior_cov = P0;
            [x_pred, P_pred] = inverse.kf.class_kf_predict(ref);
            [x_upd, ~] = inverse.kf.kf_update( ...
                x_pred, P_pred, f_data(:, 1), inverter.modified_L, inverter.noise_cov);
            testCase.verifyEqual(z_vec, gather(x_upd), "AbsTol", 1e-10);
        end

        function testRunFrameLoopDoesNotRunNMM(testCase)
            [L, f_data, procFile, source_positions, zef_shim] = i_synth_leadfield_data(8, 4, 6);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 6, ...
                "sampling_frequency", 100, ...
                "time_step", 0.01, ...
                "evolution_prior_model", "Reworked original");
            h = zef_waitbar(0, "UKFNMM frame loop test");
            cleanup = onCleanup(@() i_close(h));
            [z_cell, inverter] = utilities.inverse.run_frame_loop( ...
                zef_shim, inverter, L, procFile, 1, source_positions, h, "UKFNMM test");
            testCase.verifyEqual(numel(z_cell), 6);
            testCase.verifySize(z_cell{1}, [size(L, 2), 1]);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 0);
            testCase.verifyEqual(size(inverter.modified_L), size(L));
        end

        function testSmootherRunsNMMExactlyOnce(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            [L, f_data, procFile, source_positions, zef_shim] = i_synth_leadfield_data(8, 6, 10);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 10, ...
                "sampling_frequency", 100, ...
                "time_step", 0.01, ...
                "number_of_corrclusters", 1, ...
                "score_threshold", 0.05, ...
                "evolution_prior_model", "Reworked original", ...
                "number_of_noise_steps", 2);
            h = zef_waitbar(0, "UKFNMM NMM test");
            cleanup = onCleanup(@() i_close(h));
            [z_cell, inverter] = utilities.inverse.run_frame_loop( ...
                zef_shim, inverter, L, procFile, 1, source_positions, h, "UKFNMM NMM");
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 0);

            [z_nmm, inverter] = inverter.smoother(z_cell, L);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 1);
            testCase.verifyEqual(numel(z_nmm), 10);
            testCase.verifySize(z_nmm{1}, [size(L, 2), 1]);
            testCase.verifySize(inverter.time_series, [1, 10]);
            testCase.verifyTrue(all(isfinite(cell2mat(z_nmm)), "all"));
            testCase.verifyTrue(all(isfinite(inverter.time_series), "all"));

            [z_nmm2, inverter] = inverter.smoother(z_cell, L);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 2);
            testCase.verifyEqual(numel(z_nmm2), 10);
        end

        function testRTSThenNMMStillOnce(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            [L, f_data, procFile, source_positions, zef_shim] = i_synth_leadfield_data(8, 6, 8);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 8, ...
                "sampling_frequency", 100, ...
                "time_step", 0.01, ...
                "number_of_corrclusters", 1, ...
                "score_threshold", 0.05, ...
                "smoother_type", "RTS", ...
                "evolution_prior_model", "Reworked original", ...
                "number_of_noise_steps", 2);
            h = zef_waitbar(0, "UKFNMM RTS test");
            cleanup = onCleanup(@() i_close(h));
            [z_cell, inverter] = utilities.inverse.run_frame_loop( ...
                zef_shim, inverter, L, procFile, 1, source_positions, h, "UKFNMM RTS");
            testCase.verifyEqual(numel(inverter.posterior_covs), 8);
            [z_nmm, inverter] = inverter.smoother(z_cell, L);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 1);
            testCase.verifyEqual(numel(z_nmm), 8);
        end

        function testSampleRTSThenNMM(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            [L, f_data, procFile, source_positions, zef_shim] = i_synth_leadfield_data(8, 6, 8);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 8, ...
                "sampling_frequency", 100, ...
                "time_step", 0.01, ...
                "number_of_corrclusters", 1, ...
                "score_threshold", 0.05, ...
                "smoother_type", "Sample RTS", ...
                "evolution_prior_model", "Reworked original", ...
                "number_of_noise_steps", 2);
            h = zef_waitbar(0, "UKFNMM Sample RTS test");
            cleanup = onCleanup(@() i_close(h));
            [z_cell, inverter] = utilities.inverse.run_frame_loop( ...
                zef_shim, inverter, L, procFile, 1, source_positions, h, "UKFNMM SRTS");
            [z_nmm, inverter] = inverter.smoother(z_cell, L);
            testCase.verifyEqual(inverter.n_temporal_postprocess_runs, 1);
            testCase.verifyEqual(numel(z_nmm), 8);
        end

        function testCPUExecutionFinite(testCase)
            [L, f_data, procFile, source_positions] = i_synth_leadfield_data(6, 3, 4);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);
            [z_vec, ~] = inverter.invert( ...
                f_data(:, 2), L, procFile, 1, source_positions, ...
                "use_gpu", false, "normalize_data", 1);
            testCase.verifyClass(z_vec, 'double');
            testCase.verifyTrue(all(isfinite(z_vec)));
        end

        function testGPUOrGracefulFallback(testCase)
            [L, f_data, procFile, source_positions] = i_synth_leadfield_data(6, 3, 4);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);
            n_gpu = 0;
            try
                n_gpu = gpuDeviceCount;
            catch
            end
            [z_vec, inverter] = inverter.invert( ...
                f_data(:, 1), L, procFile, 1, source_positions, ...
                "use_gpu", true, "normalize_data", 1);
            testCase.verifySize(z_vec, [size(L, 2), 1]);
            testCase.verifyTrue(all(isfinite(double(gather(z_vec)))));
            if n_gpu == 0
                testCase.verifyClass(z_vec, 'double');
            end
        end

        function testZeroReconstructionRejected(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            [L, f_data] = i_synth_leadfield_data(6, 3, 8);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 8, ...
                "sampling_frequency", 100, ...
                "number_of_corrclusters", 1);
            inverter.reconstruction = zeros(size(L, 2), 8);
            inverter.noise_cov = 0.05 * eye(size(L, 1));
            testCase.verifyError( ...
                @() inverter.UKF_estimate_NMM_parameters(L), ...
                "UKFNMMInverter:ZeroReconstruction");
        end

        function testNoSourceAboveThresholdRejected(testCase)
            [L, ~] = i_synth_leadfield_data(6, 3, 8);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 8, ...
                "sampling_frequency", 100, ...
                "number_of_corrclusters", 1, ...
                "score_threshold", 1);
            z = zeros(size(L, 2), 8);
            z(1, 4) = 1;
            inverter.reconstruction = z;
            inverter.noise_cov = 0.05 * eye(size(L, 1));
            testCase.verifyError( ...
                @() inverter.UKF_estimate_NMM_parameters(L), ...
                "UKFNMMInverter:NoSignificantSources");
        end

        function testTooFewSourcesForClustersRejected(testCase)
            [L, ~] = i_synth_leadfield_data(6, 2, 8);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 8, ...
                "sampling_frequency", 100, ...
                "number_of_corrclusters", 3, ...
                "score_threshold", 0);
            z = randn(size(L, 2), 8);
            inverter.reconstruction = z;
            inverter.noise_cov = 0.05 * eye(size(L, 1));
            testCase.verifyError( ...
                @() inverter.UKF_estimate_NMM_parameters(L), ...
                "UKFNMMInverter:TooFewSourcesForClusters");
        end

        function testDegenerateIdenticalTrajectories(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            [L, ~] = i_synth_leadfield_data(8, 6, 10);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 10, ...
                "sampling_frequency", 100, ...
                "number_of_corrclusters", 1, ...
                "score_threshold", 0);
            t = linspace(0, 1, 10);
            bump = exp(-((t - 0.4) / 0.1).^2);
            z = zeros(size(L, 2), 10);
            for n = 1:6
                z(3 * n - 2, :) = bump;
            end
            inverter.reconstruction = z;
            inverter.noise_cov = 0.05 * eye(size(L, 1));
            [z_out, ts, inverter] = inverter.UKF_estimate_NMM_parameters(L);
            testCase.verifySize(z_out, size(z));
            testCase.verifySize(ts, [1, 10]);
            testCase.verifyTrue(all(isfinite(z_out), "all"));
        end

        function testShortRecordingNMMDimensions(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            [L, ~] = i_synth_leadfield_data(8, 4, 4);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "sampling_frequency", 50, ...
                "number_of_corrclusters", 1, ...
                "score_threshold", 0);
            t = linspace(0, 1, 4);
            z = zeros(size(L, 2), 4);
            z(1, :) = exp(-((t - 0.3) / 0.2).^2);
            z(4, :) = 0.6 * exp(-((t - 0.7) / 0.2).^2);
            z(7, :) = 0.5 * exp(-((t - 0.5) / 0.2).^2);
            z(10, :) = 0.4 * exp(-((t - 0.4) / 0.2).^2);
            inverter.reconstruction = z;
            inverter.noise_cov = 0.05 * eye(size(L, 1));
            [z_out, ts] = inverter.UKF_estimate_NMM_parameters(L);
            testCase.verifySize(z_out, [size(L, 2), 4]);
            testCase.verifySize(ts, [1, 4]);
        end

        function testInvalidSourceDimensionality(testCase)
            L = randn(8, 5);
            f_data = randn(8, 4);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "evolution_prior_model", "Reworked original");
            testCase.verifyError( ...
                @() inverter.initialize(L, f_data), ...
                "UKFNMMInverter:InvalidSourceDimensionality");
        end

        function testNonFiniteMeasurementRejected(testCase)
            [L, f_data, procFile, source_positions] = i_synth_leadfield_data(6, 3, 4);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 4, ...
                "evolution_prior_model", "Reworked original");
            inverter = inverter.initialize(L, f_data);
            f = f_data(:, 1);
            f(1) = NaN;
            testCase.verifyError( ...
                @() inverter.invert(f, L, procFile, 1, source_positions, ...
                    "use_gpu", false, "normalize_data", 1), ...
                "UKFNMMInverter:NonFiniteMeasurement");
        end

        function testInvertWithoutInitializeRejected(testCase)
            [L, f_data, procFile, source_positions] = i_synth_leadfield_data(6, 3, 3);
            inverter = inverse.UKFNMMInverter("number_of_frames", 3);
            testCase.verifyError( ...
                @() inverter.invert(f_data(:, 1), L, procFile, 1, source_positions), ...
                "UKFNMMInverter:NotInitialized");
        end

        function testSensitivityScalingNeedsTwoFrames(testCase)
            L = randn(6, 9);
            f_data = randn(6, 1);
            inverter = inverse.UKFNMMInverter( ...
                "number_of_frames", 1, ...
                "evolution_prior_model", "Sensitivity scaling");
            testCase.verifyError( ...
                @() inverter.initialize(L, f_data), ...
                "UKFNMMInverter:InsufficientFramesForProcessNoise");
        end

        function testIsAnInverter(testCase)
            inverter = inverse.UKFNMMInverter();
            inverse.CommonInverseParameters.isAnInverter(inverter);
        end
    end
end

function [L, f_data, procFile, source_positions, zef_shim] = i_synth_leadfield_data(n_sensors, n_sources, n_frames)
rng(1, "twister");
L = randn(n_sensors, 3 * n_sources);
t = linspace(0, 1, n_frames);
x = zeros(3 * n_sources, n_frames);
x(1, :) = exp(-((t - 0.3) / 0.1).^2);
if n_sources >= 3
    x(7, :) = 0.8 * exp(-((t - 0.7) / 0.1).^2);
end
if n_sources >= 5
    x(13, :) = 0.5 * exp(-((t - 0.5) / 0.12).^2);
end
f_data = L * x + 0.02 * randn(n_sensors, n_frames);
source_positions = [(0:n_sources-1)', zeros(n_sources, 2)];
procFile = struct( ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_sources, 3), ...
    "s_ind_1", [], ...
    "s_ind_2", [], ...
    "s_ind_3", [], ...
    "s_ind_4", [], ...
    "n_interp", n_sources, ...
    "sizeL2", size(L, 2), ...
    "s_ind_0", 1:n_sources);
zef_shim = struct;
zef_shim.measurements = f_data;
zef_shim.inv_data_mode = 'raw';
zef_shim.use_gpu = false;
zef_shim.gpu_count = 0;
zef_shim.normalize_data = 1;
zef_shim.inv_time_interval_averaging = false;
end

function modified_L = i_upstream_modified_L(L)
modified_L = L;
n_sources = size(L, 2) / 3;
for n = 1:n_sources
    s_ind = 3 * n - [2, 1, 0];
    [u, ~, ~] = svd(L(:, s_ind), "econ");
    modified_L(:, s_ind) = u;
end
end

function i_close(h)
try
    if ~isempty(h) && isgraphics(h)
        close(h);
    end
catch
end
end
