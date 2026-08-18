classdef UKFNMMInverter < inverse.CommonInverseParameters
%UKFNMMInverter  SKF spatial tracking with Jansen–Rit NMM and UKF parameters.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sequential EEG/MEG inversion whose spatial estimate is a Kalman filter
%   on a per-source SVD-modified lead field, after which significant sources
%   are clustered and each cluster's time course is modelled with the
%   Jansen–Rit neural mass model. Jansen–Rit parameters are estimated with
%   an unscented Kalman filter (UKF).
%
%   Intended pipeline (README of the introducing commit 462bab2c /
%   0b33ef8c):
%     measurements
%     → spatial reconstruction (Kalman on the modified lead field)
%     → source activity over time
%     → significant-source selection
%     → correlation-based source clustering
%     → spike timing estimation
%     → Jansen–Rit neural mass modelling
%     → UKF estimation of Jansen–Rit parameters
%     → final NMM-constrained reconstruction
%
%   This class is a sibling of inverse.KalmanInverter, not a variant of it.
%   The frame loop is the shared class lifecycle:
%     initialize(L, f_data) → per-frame invert(...) → smoother(...) →
%     terminateComputation(). invert never calls smoother. The NMM/UKF
%   stage runs exactly once from smoother, which the inversion drivers
%   invoke after utilities.inverse.run_frame_loop.
%
%   Spatial-filter note: the author's README names the spatial stage SKF,
%   but commit 0b33ef8c calls plugins.ClassKF.kf_update on modified_L
%   rather than plugins.ClassKF.kf_sL_update. That committed spatial
%   behaviour is preserved; see README.md in this folder.
%
%   There is no dedicated SKF–NMM–UKF publication or DOI in this
%   repository. The Standardized Kalman spatial filter that this method
%   was branched from is described in Lahtinen et al., Clinical
%   Neurophysiology 168 (2024), DOI 10.1016/j.clinph.2024.09.021.
%
%   Registry ids: "ukfnmm", "ukf_nmm". There is no Inverse-tools GUI for
%   this class; invoke it through zef_inverse_run / dispatch_inverse.
%
%   See also inverse.KalmanInverter, plugins.ClassKF,
%            utilities.inverse.run_frame_loop.

    properties

        %
        % Number of correlation clusters retained after discarding one
        % extra "nonsense" k-means cluster. kmeans is run with this value
        % plus one.
        %
        number_of_corrclusters (1,1) double {mustBePositive, mustBeInteger} = 3

        %
        % Relative peak-magnitude threshold in [0, 1] after global
        % max-normalisation of the source-wise time series. Sources whose
        % peak is not strictly greater than this value are dropped.
        %
        score_threshold (1,1) double {mustBeNonnegative} = 0.2

        %
        % UKF spread parameter alpha (van der Merwe). The introducing
        % implementation uses 5, which is larger than the usual 1e-3
        % range; that value is preserved.
        %
        alpha (1,1) double {mustBePositive} = 5

        %
        % UKF secondary scaling parameter kappa.
        %
        kappa (1,1) double = 0

        %
        % UKF prior-covariance weight parameter beta. 2 is optimal for
        % Gaussians; the introducing implementation uses 0 and that
        % default is preserved.
        %
        beta (1,1) double = 0

        %
        % Evolution prior (process-noise) model for the spatial Kalman
        % filter. Same options as inverse.KalmanInverter, including
        % "User supplied Q" from the current architecture.
        %
        evolution_prior_model (1,1) string { mustBeMember(evolution_prior_model, ["Sensitivity scaling", "Avg. sensit. scaling", "SVD-based", "Avg. SVD-based", "Reworked original", "User supplied Q"]) } = "Sensitivity scaling"

        %
        % Whether the inversion driver should call smoother after the
        % frame loop. Always true for this class: the NMM/UKF stage is
        % required. RTS itself is selected by smoother_type.
        %
        use_smoothing (1,1) logical = true

        %
        % Optional RTS smoother applied to the spatial Kalman sequence
        % before NMM/UKF. "None" skips RTS but still runs NMM/UKF.
        %
        smoother_type (1,1) string { mustBeMember(smoother_type, ["None", "RTS", "Sample RTS"]) } = "None"

        %
        % State transition of the spatial Kalman filter (usually A = I).
        %
        state_transition_model_A = []

        %
        % Evolution-prior scaling in dB.
        %
        evolution_prior_db (1,1) double {mustBeReal} = 0

        %
        % Initial-prior steering in dB.
        %
        initial_prior_steering_db (1,1) double {mustBeReal} = 0

        %
        % Leading frames treated as noise-only when estimating theta0.
        % Capped to the available measurement length in initialize.
        %
        number_of_noise_steps (1,1) double {mustBePositive, mustBeInteger} = 4

        %
        % Initial prior variance (scalar or n_dof-vector) filled by
        % initialize when empty.
        %
        theta0 = []

        %
        % Measurement-noise covariance. Default is SNR-scaled identity.
        %
        noise_cov = []

        %
        % Process-noise covariance Q of the spatial Kalman filter.
        %
        evolution_cov = []

        %
        % Previous spatial-filter mean. Required by
        % plugins.ClassKF.class_kf_predict.
        %
        prev_step_reconstruction = []

        %
        % Previous spatial-filter covariance. Required by
        % plugins.ClassKF.class_kf_predict.
        %
        prev_step_posterior_cov = []

        %
        % Full spatial (and later NMM) reconstruction as n_dof × T.
        % Filled in smoother from the frame-loop cell array.
        %
        reconstruction = []

        %
        % Cluster-wise Jansen–Rit time series, n_clusters × T, filled by
        % UKF_estimate_NMM_parameters.
        %
        time_series = []

        %
        % Per-source SVD-modified lead field used as the spatial Kalman
        % observation model. Built in initialize. NMM back-projection
        % uses the original lead field passed to smoother, matching the
        % introducing framework call.
        %
        modified_L = []

        %
        % Spatial-filter posterior covariances, one cell per frame, stored
        % only when smoother_type is RTS or Sample RTS.
        %
        posterior_covs = cell(0)

        %
        % How many times the NMM/UKF stage has run on this object. The
        % inversion driver should leave this at 1.
        %
        n_temporal_postprocess_runs (1,1) double {mustBeNonnegative, mustBeInteger} = 0

    end % properties

    properties (SetAccess = protected)

        %
        % No dedicated SKF–NMM–UKF DOI is recorded in this repository.
        %
        DOI (1,1) string = ""
    end

    methods

        function obj = set.use_smoothing(obj, val)
            %set.use_smoothing  Coerce to logical; keep the post-frame hook on.
            %
            %   NMM/UKF is not optional, so the inversion driver's smoother
            %   gate (use_smoothing) cannot be turned off. RTS is selected
            %   independently by smoother_type.
            if islogical(val)
                requested = val;
            elseif isnumeric(val)
                requested = logical(val);
            else
                error("UKFNMMInverter:InvalidUseSmoothing", ...
                    "use_smoothing must be logical or numeric.");
            end
            obj.use_smoothing = true;
            if ~requested
                % Ignore false: smoother() is the NMM/UKF entry point.
            end
        end

        function obj = set.smoother_type(obj, val)
            %set.smoother_type  Store RTS choice and keep use_smoothing true.
            obj.smoother_type = val;
            obj.use_smoothing = true;
        end

        function self = UKFNMMInverter(args)
            %UKFNMMInverter  Construct an SKF–NMM–UKF inverter.
            %
            %   Name-value arguments match class properties: NMM/UKF
            %   (number_of_corrclusters, score_threshold, alpha, kappa,
            %   beta), spatial Kalman priors, optional RTS, plus
            %   CommonInverseParameters band/frame/SNR fields.

            arguments

                args.number_of_corrclusters = 3

                args.score_threshold = 0.2

                args.alpha = 5

                args.kappa = 0

                args.beta = 0

                args.evolution_prior_model = "Sensitivity scaling"

                args.state_transition_model_A = []

                args.use_smoothing = true

                args.smoother_type = "None"

                args.number_of_noise_steps = 4

                args.evolution_prior_db = 0

                args.initial_prior_steering_db = 0

                args.theta0 = []

                args.noise_cov = []

                args.evolution_cov = []

                args.prev_step_reconstruction = []

                args.prev_step_posterior_cov = []

                args.reconstruction = []

                args.time_series = []

                args.modified_L = []

                args.posterior_covs = cell(0)

                args.n_temporal_postprocess_runs = 0

                args.data_normalization_method = "Maximum entry"

                args.high_cut_frequency = 9

                args.low_cut_frequency = 7

                args.number_of_frames = 1

                args.sampling_frequency = 1024

                args.signal_to_noise_ratio = 30

                args.time_start = 0

                args.time_window = 1

                args.time_step = 1

            end

            self = self@inverse.CommonInverseParameters( ...
                "low_cut_frequency", args.low_cut_frequency, ...
                "high_cut_frequency", args.high_cut_frequency, ...
                "data_normalization_method", args.data_normalization_method, ...
                "number_of_frames", args.number_of_frames, ...
                "sampling_frequency", args.sampling_frequency, ...
                "time_start", args.time_start, ...
                "time_window", args.time_window, ...
                "time_step", args.time_step, ...
                "signal_to_noise_ratio", args.signal_to_noise_ratio ...
            );

            self.number_of_corrclusters = args.number_of_corrclusters;
            self.score_threshold = args.score_threshold;
            self.alpha = args.alpha;
            self.kappa = args.kappa;
            self.beta = args.beta;
            self.evolution_prior_model = args.evolution_prior_model;
            self.state_transition_model_A = args.state_transition_model_A;
            self.use_smoothing = args.use_smoothing;
            self.smoother_type = args.smoother_type;
            self.number_of_noise_steps = args.number_of_noise_steps;
            self.evolution_prior_db = args.evolution_prior_db;
            self.initial_prior_steering_db = args.initial_prior_steering_db;
            self.theta0 = args.theta0;
            self.noise_cov = args.noise_cov;
            self.evolution_cov = args.evolution_cov;
            self.prev_step_reconstruction = args.prev_step_reconstruction;
            self.prev_step_posterior_cov = args.prev_step_posterior_cov;
            self.reconstruction = args.reconstruction;
            self.time_series = args.time_series;
            self.modified_L = args.modified_L;
            self.posterior_covs = args.posterior_covs;
            self.n_temporal_postprocess_runs = args.n_temporal_postprocess_runs;

            self.InitialStatement
        end

        self = initialize(self, L, f_data)

        [reconstruction, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)

        [reconstruction, self] = smoother(self, z_inverse, L)

        [reconstruction, time_series, self] = UKF_estimate_NMM_parameters(self, L)

        function self = terminateComputation(self)
            %terminateComputation  Drop dynamic evolution_var after a run.
            evolution_var = findprop(self, 'evolution_var');
            if ~isempty(evolution_var)
                delete(evolution_var);
            end
        end

    end % methods

    methods (Static)
        function InitialStatement
            %InitialStatement  Print authorship once per MATLAB session.
            persistent already_printed
            if ~isempty(already_printed)
                return
            end
            already_printed = true;

            fprintf([ ...
                'UKFNMMInverter: spatial Kalman tracking with Jansen-Rit NMM\n' ...
                'time evolution and UKF parameter estimation. Author:\n' ...
                'Joonas Lahtinen. The spatial Kalman component was branched\n' ...
                'from Standardized Kalman filtering (Lahtinen et al., Clin.\n' ...
                'Neurophysiol. 168, 2024). This combined SKF-NMM-UKF method\n' ...
                'has no dedicated DOI in this repository.\n']);
        end
    end % static methods

end % classdef
