classdef DipoleScanInverter < inverse.CommonInverseParameters & handle
%DipoleScanInverter  Dipole scan with goodness-of-fit (GoF) metric per source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each source, fits a dipole (SVD or pseudoinverse) to whitened data and
%   stores GoF = 1 - ||f - L s||^2/||f||^2 in the orientation components. Free
%   sources also encode estimated direction. precompute caches per-source SVDs for
%   batched pagemtimes in invert.
%
%   See also inverse.BeamformerInverter.
%

    properties

        %
        %The inverse algorithm used. The options are currently: 
        % - SVD
        % - Pseudoinverse
        %
        method_type (1,1) string { mustBeMember(method_type, ["SVD", "Pseudoinverse"]) } = "SVD"

        %
        %The regularization type. Options:
        % - None
        % - Basic
        %
        reg_type (1,1) string { mustBeMember(reg_type, ["None", "Basic"]) } = "None"
        
        %
        %The regularization parameter
        %
        reg_parameter (1,1) double {mustBeNonnegative} = 0.001

        %
        %Noise covariance matrix (optional)
        %
        noise_cov = [];

        % Cached whitened lead field, used by precompute()/invert() to avoid
        % redoing the Mahalanobis whitening per frame.
        precomputed_L_w (:,:) {mustBeA(precomputed_L_w,["double","gpuArray"])} = []

        % Cached whitening matrix (Chalf \ I) so per-call f can be whitened
        % without recomputing sqrtm(noise_cov).
        precomputed_whitening (:,:) {mustBeA(precomputed_whitening,["double","gpuArray"])} = []

        % Per-source SVD factorisations of the whitened (and optionally
        % regularised) 3-column lead field, stored as paged arrays so the
        % per-frame loop can be replaced by batched pagemtimes calls.
        % Layout: precomputed_U_pages is (n_ch x 3 x n_sources),
        %         precomputed_S_diag is (3 x n_sources) holding diag(S),
        %         precomputed_V_pages is (3 x 3 x n_sources).
        precomputed_U_pages (:,:,:) {mustBeA(precomputed_U_pages,["double","gpuArray"])} = []

        precomputed_S_diag (:,:) {mustBeA(precomputed_S_diag,["double","gpuArray"])} = []

        precomputed_V_pages (:,:,:) {mustBeA(precomputed_V_pages,["double","gpuArray"])} = []

        % Fingerprint of the lead field and settings the caches above were
        % built from. invert discards them on any mismatch. See
        % inverse.precompute_cache_key.
        precomputed_cache_key struct = struct([])

    end % properties

    methods

        function self = DipoleScanInverter(args)
            %DipoleScanInverter  Construct a dipole-scan GoF inverter.
            %
            %   Name-value: method_type ("SVD"|"Pseudoinverse"), reg_type
            %   ("None"|"Basic"), reg_parameter, noise_cov, plus
            %   CommonInverseParameters band/frame fields.

            arguments

                args.method_type = "SVD"

                args.reg_type = "None"

                args.reg_parameter = 0.001

                args.noise_cov = []

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
                "time_step", args.time_step...
            );

            % Initialize own fields.

            self.method_type = args.method_type;

            self.reg_type = args.reg_type;

            self.reg_parameter = args.reg_parameter;

            self.noise_cov = args.noise_cov;

        end

        % Declare the inverse method defined in the file invert, in this same
        % folder.

        self = initialize(self, L, f_data)

        self = precompute(self, L)

        [reconstruction, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)

        function key = cacheKey(self, L)
            %cacheKey  Fingerprint of L plus every setting the caches depend on.
            %
            %   The whitening comes from noise_cov and the cached singular
            %   values carry the Tikhonov shift selected by reg_type /
            %   reg_parameter.
            key = inverse.precompute_cache_key(L, { ...
                gather(double(self.noise_cov)), ...
                self.reg_type, ...
                double(self.reg_parameter)});
        end

    end % methods

end % classdef
