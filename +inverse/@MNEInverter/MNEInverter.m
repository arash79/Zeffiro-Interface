classdef MNEInverter < inverse.CommonInverseParameters & handle
%MNEInverter  Minimum-norm estimate (MNE / weighted MNE) source inverter.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Weighted MNE with diagonal prior theta and noise covariance C:
%     z = (theta.*L)' * ((theta.*L)*L' + C) \ f
%   or z = W*f when W is precomputed in precompute(L).
%
%   initialize estimates theta from SNR and lead-field sensitivity; noise_cov
%   from data when unset. SetObservable theta/noise_cov track user overrides.
%
%   See also inverse.ELORETAInverter, inverse.CSMInverter.
%

    properties

        %
        % Parameter for prior variance selection
        %

        initial_prior_steering_db (1,1) {mustBeA(initial_prior_steering_db,["double","gpuArray"])} = 0

        %
        % Checking flag if user has changed the value of theta parameter
        %
        thetaSetted (1,1) {mustBeNumericOrLogical} = false

        %
        % Checking flag if user has changed the value of noise_cov parameter
        %
        noise_covSetted (1,1) {mustBeNumericOrLogical} = false

        %
        % Checking flag if the inversion computing is running. This
        % prevents the value changes made by computation to be identified
        % as user-made.
        %
        computing_parameters (1,1) {mustBeNumericOrLogical} = false

        % Cached linear operator W so each frame is W*f.
        precomputed_inverse_operator (:,:) {mustBeA(precomputed_inverse_operator,["double","gpuArray"])} = []

    end % properties

    properties (SetObservable) %properties whose value changes we want to inspect
        %
        % Prior variance 
        % User can set the value themselves. If value is not given,
        % parameter selection method is used.
        %
        
        theta (:,:) {mustBeA(theta,["double","gpuArray"]), mustBeNonnegative} = []  %an empty double is positive and negative at the same time

        %
        % Measurement noise covariace (optional)
        % User can set their own noise covariance matrix through this
        % property.
        %
        
        noise_cov (:,:) {mustBeA(noise_cov,["double","gpuArray"])} = []

    end % SetObservable properties

    methods

        function self = MNEInverter(args)
            %MNEInverter  Construct a weighted minimum-norm inverter.
            %
            %   Name-value: theta, noise_cov, initial_prior_steering_db,
            %   thetaSetted, noise_covSetted, plus CommonInverseParameters
            %   band/frame/SNR fields. Empty theta/noise_cov are estimated in
            %   initialize from SNR and data.

            arguments

                args.theta = []

                args.noise_cov = []

                args.thetaSetted = false;

                args.noise_covSetted = false;

                args.computing_parameters = false;

                args.initial_prior_steering_db = 0

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

            % Initialize superclass fields.

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

            % Initialize own fields.

            self.theta = args.theta;
            self.noise_cov = args.noise_cov;
            self.initial_prior_steering_db = args.initial_prior_steering_db;
            self.thetaSetted = args.thetaSetted;
            self.noise_covSetted = args.noise_covSetted;
            self.computing_parameters = args.computing_parameters;

            % Initialize listeners (independent PropListener function do
            % not work).
            % PostSet is a built-in-event for a handle class. 
            % This event gets triggered AFTER the value of the listened
            % property has been changed.
            addlistener(self,'theta','PostSet',@(src,evnt)self.setEventsFlags(src,evnt,self));
            addlistener(self,'noise_cov','PostSet',@(src,evnt)self.setEventsFlags(src,evnt,self));

        end %MNEINverter class constructor function

        %- - - - - - - - - - - - - - - - - - - - - - - - - - - 

        % The 'initialize' function is run on Zeffiro Interface befor the
        % inversion is calculated. This allows us to compute and set
        % parameters that do not change between time steps.
        function self = initialize(self,L,f_data)
        %initialize  Estimate MNE prior variance theta and noise covariance from data.
        %
        %   noise_cov: sample covariance if multiple frames, else SNR-scaled identity.
        %   theta: per-DOF prior from data power, SNR, and column norms of L.
    
        arguments
    
            self (1,1) inverse.MNEInverter
    
            L (:,:) {mustBeA(L,["double","gpuArray"])}
    
            f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}
    
        end

        self.computing_parameters = true;

        noise_p2 = 10^(-self.signal_to_noise_ratio/10);

        if isempty(self.noise_cov)
            if size(f_data,2) > 1
                self.noise_cov = cov(f_data');
            else
                self.noise_cov = noise_p2 * mean(f_data.^2) * eye(size(L,1));
            end
        end
        
        if size(f_data, 2) > 1
            data_power = mean(var(f_data, 0, 2));
        else
            data_power = mean(f_data(:).^2);
        end
        if isa(data_power, "gpuArray")
            data_floor = gpuArray(eps(classUnderlying(data_power)));
        else
            data_floor = eps(class(data_power));
        end
        data_power = max(data_power, data_floor);

        % Per-source prior: θ ∝ (1-p²) 10^(steer_dB/10) data_power / ‖L_triplet‖²
        self.theta = mean( ...
            (1-noise_p2) * 10.^(self.initial_prior_steering_db/10) * data_power ...
            ./ repelem(sum(reshape(sum(L.^2),3,[])),3));
        end % initialize function

        %- - - - - - - - - - - - - - - - - - - - - - - - - - - 

        function self = precompute(self, L)
            %precompute  Cache W = (theta.*L)' / ((theta.*L)*L' + noise_cov).
            arguments
                self (1,1) inverse.MNEInverter
                L (:,:) {mustBeA(L,["double","gpuArray"])}
            end

            L_modified = L .* self.theta;
            self.precomputed_inverse_operator = L_modified' / (L_modified * L' + self.noise_cov);
        end

        %- - - - - - - - - - - - - - - - - - - - - - - - - - - 

        % Declare the inverse method defined in the file invert, in this same
        % folder.

        function [reconstruction, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
            %invert  Minimum-norm reconstruction for one frame: z = W*f or direct formula.
            %
            %   Called from utilities.inverse.run_frame_loop. Inverse tools →
            %   Minimum norm estimation uses zef_find_mne_reconstruction.
            %   Registry ids mne and wmne both select this class; weighting
            %   is always theta (there is no unweighted branch).
            %
            %   If precompute stored W, z = W*f. Otherwise L_modified = L.*theta
            %   (column scaling) and z solves the weighted normal equations
            %   with noise_cov. procFile / source_direction_mode /
            %   source_positions unused. opts.use_gpu gathers the result.
        
            arguments
        
                self (1,1) inverse.MNEInverter
        
                f (:,1) {mustBeA(f,["double","gpuArray"])}
        
                L (:,:) {mustBeA(L,["double","gpuArray"])}
        
                procFile (1,1) struct
        
                source_direction_mode
        
                source_positions
        
                opts.use_gpu (1,1) logical = false
        
                opts.normalize_data (1,1) double = 1
        
            end

            %When inversion starts, we do not change the inversion
            %parameters anymore
            self.computing_parameters = false;
        
            % Initialize waitbar with a cleanup object that automatically closes the
            % waitbar, if there is an interruption with Ctrl + C or when this function
            % exits.
        
            if self.number_of_frames <= 1
                h = zef_waitbar(0,'MNE Reconstruction.');
                cleanup_fn = @(wb) close(wb);    
                cleanup_obj = onCleanup(@() cleanup_fn(h));
            end
        
            if ~isempty(self.precomputed_inverse_operator)
                reconstruction = self.precomputed_inverse_operator * f;
                if opts.use_gpu && gpuDeviceCount > 0
                    reconstruction = gather(reconstruction);
                end
                return;
            end

            % Get needed parameters from self and others.
            L_modified = L.*self.theta;
            
            % Set matrices as gpuARRAYS for faster matrix algebraic
            % computations
            if opts.use_gpu && gpuDeviceCount > 0
                L_modified = gpuArray(L_modified);
                L = gpuArray(L);
                f = gpuArray(f);
                C = gpuArray(self.noise_cov);
            end

            % Compute the reconstruction
            % Weighted MNE: z = L_θ' (L_θ L' + C)^{-1} f  with L_θ = L .* θ
            reconstruction = L_modified'*((L_modified*L'+C)\f);

            % As the output of inversion will be in gpuArray class, change
            % it back for the sake of ZI's visualization or inspection
            if opts.use_gpu && gpuDeviceCount > 0
                reconstruction = gather(reconstruction);
            end

        end % invert function

        %- - - - - - - - - - - - - - - - - - - - - - - - - - - 

        % Function that ZI runs after all inversions are done for each
        % desired time steps. With this function, one can reset the
        % variables and properties that has been changed during the
        % computing process

        function self = terminateComputation(self)
            %terminateComputation  Clear auto-estimated theta, noise_cov, and cached W.
            %
            %   User-set theta/noise_cov (thetaSetted / noise_covSetted) are kept.

            %If the user has not given their own inversion parameters, we
            %reset the automatically computed parameters because the user 
            %could change the data or model between separate runs.
            if not(self.thetaSetted)
                self.theta = [];
            end
            if not(self.noise_covSetted)
                self.noise_cov = [];
            end
            self.precomputed_inverse_operator = [];
        end

    end % methods

    methods (Static)
        %The function that is woken by listener when the value of theta or
        %noise_cov is changed to something else than empty by hand. 
        % The function set the respective *Setted property value true when 
        % value is changed.
        function setEventsFlags(src,evnt,self) %two first inputs must be there and have these dedicated roles. The third 'self' is an extra variable.
        %setEventsFlags  PostSet listener: mark theta/noise_cov as user-set when not computing.
         if not(self.computing_parameters)
          switch src.Name
             case 'theta'
               if isempty(self.theta)
                   self.thetaSetted = false;
               else
                   self.thetaSetted = true;
               end
             case 'noise_cov'
               if isempty(self.noise_cov)
                   self.noise_covSetted = false;
               else
                   self.noise_covSetted = true;
               end
          end
         end
        end % function
    end % static methods

end % classdef
