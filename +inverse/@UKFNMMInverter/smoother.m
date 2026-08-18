function [reconstruction, self] = smoother(self, z_inverse, L)
%smoother  Optional RTS on the spatial sequence, then NMM/UKF once.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Run after the frame loop by zef_process_inversion /
%   utilities.cluster.dispatch_inverse. invert does not call this method.
%
%   1. Assemble the spatial Kalman sequence from z_inverse.
%   2. If smoother_type is "RTS" or "Sample RTS", apply a Rauch–Tung–
%      Striebel backward pass. "Sample RTS" replaces Q with the sample
%      covariance of consecutive filtered (or A-predicted) states.
%   3. Always run UKF_estimate_NMM_parameters on the (optionally smoothed)
%      spatial sequence. That is the defining post-frame stage of this
%      method and must execute exactly once per inversion.
%
%   Inputs
%     z_inverse - cell, one n_dof×1 spatial vector per frame (same order
%                 as invert).
%     L         - original lead field used by NMM back-projection, not
%                 modified_L.
%
%   Outputs
%     reconstruction - cell of NMM-constrained frames, same length as
%                      z_inverse.
%     self           - time_series and n_temporal_postprocess_runs updated.

    arguments
        self (1,1) inverse.UKFNMMInverter
        z_inverse
        L (:,:)
    end

    z_mat = i_spatial_matrix(z_inverse);
    n_frames = size(z_mat, 2);
    if n_frames ~= self.number_of_frames
        error("UKFNMMInverter:FrameCountMismatch", ...
            "z_inverse has %d frames but number_of_frames is %d.", ...
            n_frames, self.number_of_frames);
    end
    if size(z_mat, 1) ~= size(L, 2)
        error("UKFNMMInverter:ReconstructionLeadFieldMismatch", ...
            "Spatial reconstruction has %d rows but L has %d columns.", ...
            size(z_mat, 1), size(L, 2));
    end

    self.reconstruction = z_mat;

    if self.smoother_type == "RTS" || self.smoother_type == "Sample RTS"
        self.reconstruction = i_rts_pass(self, L);
    end

    [recon_mat, time_series, self] = self.UKF_estimate_NMM_parameters(L);
    self.time_series = time_series;
    self.n_temporal_postprocess_runs = self.n_temporal_postprocess_runs + 1;

    reconstruction = mat2cell(recon_mat, size(recon_mat, 1), ones(1, size(recon_mat, 2)));
end

function z_mat = i_spatial_matrix(z_inverse)
if iscell(z_inverse)
    if isempty(z_inverse)
        error("UKFNMMInverter:EmptySpatialSequence", ...
            "z_inverse is empty; spatial Kalman produced no frames.");
    end
    n_dof = numel(gather(z_inverse{1}));
    n_frames = numel(z_inverse);
    z_mat = zeros(n_dof, n_frames);
    for k = 1:n_frames
        zk = gather(z_inverse{k});
        zk = zk(:);
        if numel(zk) ~= n_dof
            error("UKFNMMInverter:InconsistentFrameSize", ...
                "Frame %d has %d entries; expected %d.", k, numel(zk), n_dof);
        end
        z_mat(:, k) = zk;
    end
else
    z_mat = double(gather(z_inverse));
end
if ~all(isfinite(z_mat(:)))
    error("UKFNMMInverter:NonFiniteSpatialSequence", ...
        "Spatial reconstruction contains NaN or Inf.");
end
end

function reconstruction = i_rts_pass(self, L)
n_frames = self.number_of_frames;
if n_frames < 2
    error("UKFNMMInverter:RTSNeedsMultipleFrames", ...
        "RTS / Sample RTS needs at least 2 frames; got %d.", n_frames);
end
if numel(self.posterior_covs) ~= n_frames
    error("UKFNMMInverter:MissingPosteriorCovariances", ...
        "smoother_type '%s' needs one posterior covariance per frame; stored %d, frames %d.", ...
        self.smoother_type, numel(self.posterior_covs), n_frames);
end

A = self.state_transition_model_A;
if isempty(A)
    A = eye(size(self.reconstruction, 1));
end
Q = self.evolution_cov;
if self.smoother_type == "Sample RTS"
    z = self.reconstruction;
    if i_is_identity(A)
        dZ = z(:, 2:n_frames) - z(:, 1:n_frames-1);
    else
        dZ = z(:, 2:n_frames) - A * z(:, 1:n_frames-1);
    end
    Q = cov(dZ');
    Q = (Q + Q') / 2;
end
if isempty(Q)
    error("UKFNMMInverter:MissingProcessNoiseForRTS", ...
        "RTS requires a process-noise covariance Q.");
end

h = zef_waitbar(0, 'Smoothing');
cleanup_wb = onCleanup(@() i_safe_close_waitbar(h));

reconstruction = zeros(size(L, 2), n_frames);
m_s = [];
P_s = [];
for f_ind = n_frames:-1:1
    zef_waitbar(1 - f_ind / n_frames, h, ...
        ['Smoothing ' int2str(n_frames - f_ind) ' of ' int2str(n_frames) '.']);

    P = self.posterior_covs{f_ind};
    m = self.reconstruction(:, f_ind);
    if i_is_identity(A)
        P_ = P + Q;
        m_ = m;
        G = P / P_;
    else
        P_ = A * P * A' + Q;
        m_ = A * m;
        G = (P * A') / P_;
    end
    if f_ind == n_frames
        m_s = m;
        P_s = P;
    else
        m_s = m + G * (m_s - m_);
        P_s = P + G * (P_s - P_) * G';
        P_s = (P_s + P_s') / 2;
    end
    reconstruction(:, f_ind) = m_s;
end

clear cleanup_wb;
end

function tf = i_is_identity(A)
tf = isdiag(A) && all(abs(diag(A) - 1) < eps);
end

function i_safe_close_waitbar(h)
try
    if ~isempty(h) && isgraphics(h)
        close(h);
    end
catch
end
end
