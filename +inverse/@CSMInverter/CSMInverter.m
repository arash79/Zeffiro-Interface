classdef CSMInverter < inverse.CommonInverseParameters & handle
%CSMInverter  Cortical source mapping: dSPM, sLORETA, 3D sLORETA, and SBL.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   method_type selects the algorithm. dSPM and sLORETA share a precomputed
%   minimum-norm backbone P = L'/(L*L'+S) with per-source standardization d;
%   3D sLORETA applies block-wise G^{-1/2} corrections per dipole triplet. SBL runs
%   iterative gamma updates from the data covariance.
%
%   See also inverse.MNEInverter, inverse.ELORETAInverter.
%

    properties

        %
        %The inverse algorithm used. The options are: dSPM, sLORETA,
        %sLORETA's 3D implementation and Sparse Bayesian learning
        %
        method_type (1,1) string { mustBeMember(method_type, ["dSPM", "sLORETA", "sLORETA 3D", "SBL"]) } = "dSPM"

        %
        %Iteration number for sparse Bayesian learning
        %
        SBL_number_of_iterations (1,1) int8 {mustBeNonnegative, mustBeInteger} = 1

        %
        % Prior variance
        %
        theta0 (1,1) {mustBeA(theta0,["double","gpuArray"])} = 1e-3

        % Cached source covariance operator for dSPM/sLORETA
        precomputed_P (:,:) {mustBeA(precomputed_P,["double","gpuArray"])} = []

        % Cached standardization vector for dSPM/sLORETA
        precomputed_d (:,1) {mustBeA(precomputed_d,["double","gpuArray"])} = []

        % Cached 3×3 G^{-1/2} pages for sLORETA 3D (3 x 3 x n_sources)
        precomputed_Minv {mustBeA(precomputed_Minv,["double","gpuArray"])} = []

        % Fingerprint of the lead field and of every setting precompute baked
        % into the caches above: method_type, theta0 and signal_to_noise_ratio.
        % P depends on the latter two through S = (10^(-SNR/20)^2 / theta0) I,
        % the sLORETA scaling uses theta0 directly, and d has a different
        % definition per method_type. invert discards the caches on any
        % mismatch. See inverse.precompute_cache_key.
        precomputed_cache_key struct = struct([])

    end % properties

    methods

        function self = CSMInverter(args)
            %CSMInverter  Construct a CSM inverter (dSPM / sLORETA / SBL).
            %
            %   Name-value: method_type ("dSPM","sLORETA","sLORETA 3D","SBL"),
            %   theta0, SBL_number_of_iterations, normalize_reconstruction,
            %   plus CommonInverseParameters band/frame/SNR fields.

            arguments

                args.method_type = "dSPM"

                args.theta0 = 1e-3

                args.SBL_number_of_iterations = 1

                args.normalize_reconstruction = false

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
                "signal_to_noise_ratio", args.signal_to_noise_ratio, ...
                "normalize_reconstruction", args.normalize_reconstruction...
            );

            % Initialize own fields.

            self.method_type = args.method_type;

            self.SBL_number_of_iterations = args.SBL_number_of_iterations;

            self.theta0 = args.theta0;

        end

        function key = cacheKey(self, L)
            %cacheKey  Fingerprint of L plus every setting the caches depend on.
            %
            %   P depends on theta0 and signal_to_noise_ratio through
            %   S = (10^(-SNR/20)^2 / theta0) I, and the standardization
            %   vector d is defined differently for each method_type, so all
            %   three belong in the key. Used by precompute to stamp the
            %   caches and by invert to validate them.
            key = inverse.precompute_cache_key(L, { ...
                self.method_type, ...
                gather(double(self.theta0)), ...
                double(self.signal_to_noise_ratio)});
        end

        % Declare the initialize and inverse method defined in the files invert and initialize in this same
        % folder.
        
        self = initialize(self, L, f_data)

        self = precompute(self, L)

        [reconstruction, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)

    end % methods

end % classdef
