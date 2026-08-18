function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
%invert  One spatial Kalman predict-update; does not run NMM/UKF.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once per frame by utilities.inverse.run_frame_loop. Observation
%   model is self.modified_L (per-source SVD U), not the original L, and
%   the update is plugins.ClassKF.kf_update (ordinary KF), matching commit
%   0b33ef8c. The NMM/UKF stage is not invoked here; the inversion driver
%   calls smoother exactly once after the frame loop.
%
%   State carried on self: prev_step_reconstruction, prev_step_posterior_cov
%   (required by plugins.ClassKF.class_kf_predict; the introducing class
%   stored only reconstruction / posterior_covs and therefore could not
%   call class_kf_predict). Optional evolution_var consumes one column per
%   frame into evolution_cov. If smoother_type is RTS or Sample RTS,
%   posterior_covs grows by one gathered P per frame.
%
%   [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, ...
%       source_positions, opts)
%
%   Inputs
%     f     - n_sensors×1 current frame (filtered).
%     L     - original lead field (unused after initialize built
%             modified_L; kept for the shared invert signature).
%     procFile, source_direction_mode, source_positions - common invert
%             signature; unused here.
%     opts.use_gpu - move covariances to gpuArray when a device exists.
%     opts.normalize_data - unused here.
%
%   Outputs
%     z_vec - n_dof×1 spatial-filter mean (gathered to CPU).
%     self  - updated x, P, optional posterior_covs.

    arguments
        self (1,1) inverse.UKFNMMInverter
        f (:,1) {mustBeA(f,["double","gpuArray"])}
        L (:,:) {mustBeA(L,["double","gpuArray"])}
        procFile (1,1) struct
        source_direction_mode
        source_positions
        opts.use_gpu (1,1) logical = false
        opts.normalize_data (1,1) double = 1
    end

    if isempty(self.modified_L) || isempty(self.theta0) || isempty(self.noise_cov)
        error("UKFNMMInverter:NotInitialized", ...
            "Call initialize(L, f_data) before invert.");
    end
    if ~all(isfinite(double(gather(f(:)))))
        error("UKFNMMInverter:NonFiniteMeasurement", ...
            "Measurement frame contains NaN or Inf.");
    end
    if size(f, 1) ~= size(self.modified_L, 1)
        error("UKFNMMInverter:MeasurementSizeMismatch", ...
            "Measurement length %d does not match modified_L sensors %d.", ...
            size(f, 1), size(self.modified_L, 1));
    end
    if size(L, 2) ~= size(self.modified_L, 2)
        error("UKFNMMInverter:LeadFieldSizeMismatch", ...
            "L has %d columns but modified_L has %d.", size(L, 2), size(self.modified_L, 2));
    end

    theta0 = self.theta0;
    n_state = size(self.modified_L, 2);

    if isempty(self.prev_step_posterior_cov)
        if isscalar(theta0)
            self.prev_step_posterior_cov = eye(n_state) * theta0;
        else
            theta0 = theta0(:);
            if numel(theta0) ~= n_state
                error("UKFNMMInverter:BadTheta0Size", ...
                    "theta0 must be scalar or length %d; got %d.", n_state, numel(theta0));
            end
            self.prev_step_posterior_cov = diag(theta0);
        end
    end

    if isempty(self.prev_step_reconstruction)
        self.prev_step_reconstruction = zeros(n_state, 1);
    end

    if isprop(self, 'evolution_var') && ~isempty(self.evolution_var)
        self.evolution_cov = diag(self.evolution_var(:, 1));
        self.evolution_var(:, 1) = [];
    end
    if isempty(self.evolution_cov)
        error("UKFNMMInverter:MissingEvolutionCov", ...
            "evolution_cov is empty. initialize must set Q, or evolution_var must still have a column for this frame.");
    end

    use_gpu = false;
    if opts.use_gpu
        try
            use_gpu = gpuDeviceCount > 0;
        catch
            use_gpu = false;
        end
    end
    if use_gpu
        self.evolution_cov = gpuArray(self.evolution_cov);
        self.noise_cov = gpuArray(self.noise_cov);
        self.prev_step_posterior_cov = gpuArray(self.prev_step_posterior_cov);
        self.prev_step_reconstruction = gpuArray(self.prev_step_reconstruction);
        self.modified_L = gpuArray(self.modified_L);
        f = gpuArray(f);
    end

    [x, P] = plugins.ClassKF.class_kf_predict(self);
    [x, P] = plugins.ClassKF.kf_update(x, P, f, self.modified_L, self.noise_cov);

    if i_wants_rts(self)
        self.posterior_covs = [self.posterior_covs, gather(P)];
    end

    z_vec = gather(x);
    if ~all(isfinite(double(z_vec(:))))
        error("UKFNMMInverter:NonFiniteSpatialEstimate", ...
            "Spatial Kalman estimate contains NaN or Inf.");
    end
    self.prev_step_reconstruction = x;
    self.prev_step_posterior_cov = P;
end

function tf = i_wants_rts(self)
tf = self.smoother_type == "RTS" || self.smoother_type == "Sample RTS";
end
