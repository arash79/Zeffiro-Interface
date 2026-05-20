classdef ELORETAInverter < inverse.CommonInverseParameters & handle

    %
    % ELORETAInverter
    %
    % A class that implements exact low-resolution electromagnetic
    % tomography (eLORETA) using a fixed-point iteration over source-space
    % weights. The frame-wise inversion is linear once the inverse operator
    % has been precomputed.
    %

    properties

        %
        % Maximum number of fixed-point iterations.
        %
        n_max_iterations (1,1) double {mustBePositive, mustBeInteger} = 200

        %
        % Relative convergence tolerance of the fixed-point iteration.
        %
        convergence_tolerance (1,1) double {mustBePositive} = 1e-6

        %
        % If true, use average-reference centering matrix in
        % regularization; otherwise use identity.
        %
        apply_average_reference (1,1) logical = true

        %
        % Tracking user-set status for regularization parameter.
        %
        regularization_parameterSetted (1,1) {mustBeNumericOrLogical} = false

        %
        % Tracking user-set status for noise covariance.
        %
        noise_covSetted (1,1) {mustBeNumericOrLogical} = false

        %
        % Internal guard for listeners so computed values are not mistaken
        % as user inputs.
        %
        computing_parameters (1,1) {mustBeNumericOrLogical} = false

        %
        % Cached inverse operator T so each frame is T*f.
        %
        precomputed_inverse_operator (:,:) {mustBeA(precomputed_inverse_operator,["double","gpuArray"])} = []

        %
        % Cached diagonal of W^{-1} for diagnostics.
        %
        precomputed_W_inv_diag (:,1) {mustBeA(precomputed_W_inv_diag,["double","gpuArray"])} = []

        %
        % Number of iterations used by fixed-point updates.
        %
        n_iterations_used (1,1) double {mustBeNonnegative} = 0

        %
        % Final relative residual of fixed-point updates.
        %
        final_residual (1,1) double {mustBeNonnegative} = Inf

    end % properties

    properties (SetObservable)

        %
        % The regularization parameter alpha. If empty, it is estimated
        % from the SNR.
        %
        regularization_parameter (:,:) {mustBeA(regularization_parameter,["double","gpuArray"]), mustBeNonnegative} = []

        %
        % Measurement noise covariance (optional). If empty, initialized
        % from data.
        %
        noise_cov (:,:) {mustBeA(noise_cov,["double","gpuArray"])} = []

    end % SetObservable properties

    methods

        function self = ELORETAInverter(args)

            arguments
                args.regularization_parameter = []
                args.noise_cov = []
                args.n_max_iterations = 200
                args.convergence_tolerance = 1e-6
                args.apply_average_reference = true
                args.regularization_parameterSetted = false
                args.noise_covSetted = false
                args.computing_parameters = false
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
                "low_cut_frequency" ,args.low_cut_frequency, ...
                "high_cut_frequency", args.high_cut_frequency, ...
                "data_normalization_method", args.data_normalization_method, ...
                "number_of_frames", args.number_of_frames, ...
                "sampling_frequency", args.sampling_frequency, ...
                "time_start", args.time_start, ...
                "time_window", args.time_window, ...
                "time_step", args.time_step, ...
                "signal_to_noise_ratio", args.signal_to_noise_ratio ...
            );

            self.regularization_parameter = args.regularization_parameter;
            self.noise_cov = args.noise_cov;
            self.n_max_iterations = args.n_max_iterations;
            self.convergence_tolerance = args.convergence_tolerance;
            self.apply_average_reference = args.apply_average_reference;
            self.regularization_parameterSetted = args.regularization_parameterSetted;
            self.noise_covSetted = args.noise_covSetted;
            self.computing_parameters = args.computing_parameters;

            addlistener(self, "regularization_parameter", "PostSet", ...
                @(src,evnt) self.setEventsFlags(src,evnt,self));
            addlistener(self, "noise_cov", "PostSet", ...
                @(src,evnt) self.setEventsFlags(src,evnt,self));

        end

        self = initialize(self, L, f_data)

        self = precompute(self, L, procFile)

        [reconstruction, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)

        function self = terminateComputation(self)
            if not(self.regularization_parameterSetted)
                self.regularization_parameter = [];
            end
            if not(self.noise_covSetted)
                self.noise_cov = [];
            end
            self.precomputed_inverse_operator = [];
            self.precomputed_W_inv_diag = [];
            self.n_iterations_used = 0;
            self.final_residual = Inf;
        end

    end % methods

    methods (Static)
        function setEventsFlags(src,evnt,self)
            if not(self.computing_parameters)
                switch src.Name
                    case "regularization_parameter"
                        self.regularization_parameterSetted = ~isempty(self.regularization_parameter);
                    case "noise_cov"
                        self.noise_covSetted = ~isempty(self.noise_cov);
                end
            end
        end
    end % static methods

end % classdef
