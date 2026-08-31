classdef BeamformerInverter < inverse.CommonInverseParameters & handle
%BeamformerInverter  Per-source LCMV, UNG, and unit-gain beamformers.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Scans each source (fixed then free orientation). With error_cov, lead fields
%   are Mahalanobis-whitened (C\\L). Weights w = (L' C^{-1} L + lambda I)^{-1} L' C^{-1} f
%   with optional UNG / unit-gain normalization. Unit-gain constrained mode picks
%   optimal orientation via dominant eigenvector of L'*L (Rayleigh–Ritz).
%   precompute caches the linear operator B so each frame is z = B*f.
%
%   See also inverse.DipoleScanInverter.
%

    properties

        %
        %The inverse algorithm used. The options are currently: 
        % - Linearly constrained minimum variance (LCMV) beamformer
        % - Unit noise gain (UNG) beamformer
        % - Unit-gain constrained beamformer
        % The last option is essentially UNG but beamformer-optimal, i.e.,
        % maximal-signal-producing orientation is calculated first.
        %
        method_type (1,1) string { mustBeMember(method_type, ["Linearly constrained minimum variance (LCMV) beamformer", "Unit noise gain (UNG) beamformer", "Unit-gain constrained beamformer"]) } = "Linearly constrained minimum variance (LCMV) beamformer"

        %
        %The error covariance regularization parameter
        %
        cov_reg_parameter (1,1) double {mustBeNonnegative} = 0.05

        %
        %The lead field regularization parameter
        %
        leadfield_reg_parameter (1,1) double {mustBeNonnegative} = 0.001

        %
        %The leadfield regularization procedure
        %
        leadfield_reg_type (1,1) string { mustBeMember(leadfield_reg_type, ["Basic", "Pseudoinverse"]) } = "Basic"
       
        %
        %Lead field normalization strategy
        %
        leadfield_normalization (1,1) string { mustBeMember(leadfield_normalization, ["None", "Matrix norm", "Column norm", "Row norm"]) } = "None"

        %
        % Property to check if user has changed the error covariance by
        % hand
        %
        error_covSetted (1,1) {mustBeNumericOrLogical} = false

        %
        % Support variable to ensure that only user changed of error_cov
        % causes action.
        %
        computing_parameters (1,1) {mustBeNumericOrLogical} = false

        % Cached linear operator B so each frame is z = B*f. Built by
        % precompute from regularized error_cov, L, and the current method /
        % lead-field regularization / normalization settings.
        precomputed_inverse_operator (:,:) {mustBeA(precomputed_inverse_operator,["double","gpuArray"])} = []

        % Fingerprint of the lead field, orientation split and settings B was
        % built from. invert discards B on any mismatch. See
        % inverse.precompute_cache_key.
        precomputed_cache_key struct = struct([])

    end % properties
    properties (SetObservable)
         
        %
        %The data error covariance matrix (optional)
        %
        error_cov = []

    end %SetObservable properties

    methods

        function self = BeamformerInverter(args)
            %BeamformerInverter  Construct an LCMV / UNG / unit-gain beamformer.
            %
            %   Name-value: method_type, cov_reg_parameter, leadfield_reg_parameter,
            %   reg_type (stored as leadfield_reg_type), error_cov,
            %   leadfield_normalization, plus CommonInverseParameters fields.
            %   SNR is inherited but invert uses error_cov, not inv_snr, for C.
            arguments

                args.method_type = "Linearly constrained minimum variance (LCMV) beamformer"

                args.cov_reg_parameter = 0.05

                args.leadfield_reg_parameter = 0.001

                args.reg_type = "Basic"

                args.error_cov = []

                args.error_covSetted = false

                args.computing_parameters = false

                args.leadfield_normalization = "None"

                args.data_normalization_method = "Maximum entry"

                args.high_cut_frequency = 9

                args.low_cut_frequency = 7

                args.number_of_frames = 1

                args.sampling_frequency = 1024

                args.time_start = 0

                args.time_window = 0

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
                "time_step", args.time_step ...
            );

            % Initialize own fields.

            self.method_type = args.method_type;

            self.leadfield_reg_type = args.reg_type;

            self.cov_reg_parameter = args.cov_reg_parameter;

            self.leadfield_reg_parameter = args.leadfield_reg_parameter;

            self.leadfield_normalization = args.leadfield_normalization;

            self.error_cov = args.error_cov;

            self.error_covSetted = args.error_covSetted;

            self.computing_parameters = args.computing_parameters;

            %Set listener for error_cov
            addlistener(self,'error_cov','PostSet',@(src,evnt)self.setEventsFlags(src,evnt,self));

        end

        % Declare the initialize and inverse method defined in the files invert and initialize in this same
        % folder.

        self = initialize(self, L, f_data)

        self = precompute(self, L, procFile)

        [reconstruction, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)

        function key = cacheKey(self, L, procFile)
            %cacheKey  Fingerprint of L plus every setting B depends on.
            %
            %   B is assembled from the ridge-regularized error_cov, the
            %   beamformer variant, the lead-field regularization and
            %   normalization choices, and the fixed/free orientation split
            %   taken from procFile.
            if nargin < 3 || ~isstruct(procFile)
                s_ind_0 = []; s_ind_4 = [];
            else
                s_ind_0 = i_field(procFile, "s_ind_0");
                s_ind_4 = i_field(procFile, "s_ind_4");
            end
            key = inverse.precompute_cache_key(L, { ...
                self.method_type, ...
                double(self.cov_reg_parameter), ...
                double(self.leadfield_reg_parameter), ...
                self.leadfield_reg_type, ...
                self.leadfield_normalization, ...
                gather(double(self.error_cov)), ...
                s_ind_0, s_ind_4});

            function v = i_field(s, name)
                if isfield(s, name) && ~isempty(s.(name))
                    v = double(s.(name)(:));
                else
                    v = [];
                end
            end
        end

        % Function that ZI runs after all inversions are done for each
        % desired time steps. With this function, one can reset the
        % variables and properties that has been changed during the
        % computing process

        function self = terminateComputation(self)
            %terminateComputation  Clear auto-estimated error_cov unless user-set.
            if not(self.error_covSetted)
                self.error_cov = [];
            end
            self.precomputed_inverse_operator = [];
            self.precomputed_cache_key = struct([]);
        end

    end % methods

    methods (Static)
        %The function that is woken by listener when the value of theta or
        %noise_cov is changed to something else than empty by hand. 
        % The function set the respective *Setted property value true when 
        % value is changed.
        function setEventsFlags(src,evnt,self) %two first inputs must be there and have these dedicated roles. The third 'self' is an extra variable.
        %setEventsFlags  PostSet listener: mark error_cov as user-set when not computing.
         if not(self.computing_parameters)
               if isempty(self.error_cov)
                   self.error_covSetted = false;
               else
                   self.error_covSetted = true;
               end
         end
        end % function
    end % static methods

end % classdef
