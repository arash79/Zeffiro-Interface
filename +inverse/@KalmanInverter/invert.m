function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
%invert  One Kalman predict-update step; output is filtered (or standardized) source estimate.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once per frame by utilities.inverse.run_frame_loop. Inverse
%   tools → Kalman uses tools/plugins/Kalman/m/zef_KF.m instead (that
%   plugin is also where DTI structural Q lives).
%
%   State carried on self: prev_step_reconstruction, prev_step_posterior_cov
%   (initialized from theta0 on the first frame). Optional evolution_var
%   consumes one column per frame into evolution_cov. If use_smoothing,
%   posterior_covs grows by one gathered P per frame for smoother().
%
%   method_type (mustBeMember on the class):
%     "Basic Kalman filter" — ClassKF predict + kf_update; z = x.
%     "Standardized Kalman filter" — kf_sL_update; z = D*x.
%     "Approximated Standardized Kalman filter" — kf_sL_update_approx; z = D*x.
%     "Ensembled Kalman filter" — ensemble forecast, corrcoef localization
%       (|ρ|<0.05 zeroed), Kalman gain; z = D*mean(ensemble) with D = I
%       in the live branch (method = '3').
%
%   [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, ...
%       source_positions, opts)
%
%   Inputs
%     f     - n_sensors×1 current frame (filtered).
%     L     - n_sensors×n_dof observation model (lead field).
%     procFile, source_direction_mode, source_positions - common invert
%             signature; unused in this method.
%     opts.use_gpu - move covariances to gpuArray when a device exists.
%     opts.normalize_data - unused here.
%
%   Outputs
%     z_vec - n_dof×1 filtered (or standardized) estimate.
%     self  - updated x, P, optional posterior_covs.

    arguments

        self (1,1) inverse.KalmanInverter

        f (:,1) {mustBeA(f,["double","gpuArray"])}

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        procFile (1,1) struct

        source_direction_mode

        source_positions

        opts.use_gpu (1,1) logical = false

        opts.normalize_data (1,1) double = 1

    end


    % Get needed parameters from self and others.
    theta0 = self.theta0;

    % Then start inverting.
    %% CALCULATION STARTS HERE
    
%Prior covariance is saved in self.prev_step_posterior_cov
if isempty(self.prev_step_posterior_cov)
    if max(size(theta0)) == 1
        self.prev_step_posterior_cov = eye(size(L,2)) * theta0;
    else
        self.prev_step_posterior_cov = diag(theta0);
    end
end


if isempty(self.prev_step_reconstruction)
    if not(strcmp(self.method_type,"Ensembled Kalman filter"))
        self.prev_step_reconstruction = zeros(size(L,2),1);
    else
        self.prev_step_reconstruction = mvnrnd(zeros(size(L,2),1), self.prev_step_posterior_cov, self.number_of_ensembles)';
    end
end

if not(isempty(self.evolution_var))
    % Time-varying diagonal Q: consume one column of evolution_var per frame.
    self.evolution_cov = diag(self.evolution_var(:,1));
    self.evolution_var(:,1) = [];
end

if opts.use_gpu && gpuDeviceCount > 0
    self.evolution_cov = gpuArray(self.evolution_cov);
    self.noise_cov = gpuArray(self.noise_cov);
    self.prev_step_posterior_cov = gpuArray(self.prev_step_posterior_cov);
end
%% KALMAN FILTER
% Basic KF: x̂, P from ClassKF predict then kf_update; z = x.
% Standardized: same predict, kf_sL_update, z = D x (sLORETA scale).
% Approx sKF: kf_sL_update_approx. EnKF: ensemble forecast + localization.
% sel.fsmoother_type is as written (not self.smoother_type). Standardized
% methods therefore take this Basic-KF branch only if a variable sel with
% that field exists in the caller; otherwise MATLAB errors. Documented,
% not patched.
if strcmp(self.method_type,"Basic Kalman filter") || ((strcmp(self.method_type,"Standardized Kalman filter") || strcmp(self.method_type,"Approximated Standardized Kalman filter")) && strcmp(sel.fsmoother_type,"RTS"))
    % Prediction
    [x, P] = plugins.ClassKF.class_kf_predict(self);
    % Update
    [x, P] = plugins.ClassKF.kf_update(x, P, f, L, self.noise_cov);
    if self.use_smoothing
        self.posterior_covs = [self.posterior_covs,gather(P)];
    end
    z_vec = gather(x);
    self.prev_step_reconstruction = x;
    self.prev_step_posterior_cov = P;
elseif strcmp(self.method_type,"Standardized Kalman filter")
    % Prediction
    [x, P] = plugins.ClassKF.class_kf_predict(self);
    % Update
    [x, P, ~, D] = plugins.ClassKF.kf_sL_update(x, gather(P), f, L, self.noise_cov);
    if self.use_smoothing
        self.posterior_covs = [self.posterior_covs,gather(P)];
    end
    self.prev_step_reconstruction = x;
    z_vec = gather(D*self.prev_step_reconstruction);
    self.prev_step_posterior_cov = P;
elseif strcmp(self.method_type,"Approximated Standardized Kalman filter")
    % Prediction
    [x, P] = plugins.ClassKF.class_kf_predict(self);
    % Update
    [x, P, ~, D] = plugins.ClassKF.kf_sL_update_approx(x, P, f, L, self.noise_cov);
    if self.use_smoothing
        self.posterior_covs = [self.posterior_covs,gather(P)];
    end
    self.prev_step_reconstruction = x;
    z_vec = gather(D*self.prev_step_reconstruction);
    self.prev_step_posterior_cov = P;
elseif strcmp(self.method_type,"Ensembled Kalman filter")
    w = mvnrnd(zeros(size(L,2),1), self.evolution_cov, self.number_of_ensembles)';
    % Forecasts
    x_f = self.state_transition_model_A * self.prev_step_reconstruction + w;
    C = cov(x_f');
    correlationLocalization = true;
    if correlationLocalization
    T = corrcoef(x_f');
    % explain How to find 0.05
    T(abs(T) < 0.05) = 0;
    C = C .* T;
    end
    v = mvnrnd(zeros(size(self.noise_cov,1),1), self.noise_cov, self.number_of_ensembles);
    
    % method to calculate resolution D
    method = '3';
    if(method == '1')
        P_sqrtm = sqrtm(C);
        B = L * P_sqrtm;
        G = B' / (B * B' + self.noise_cov);
        w_t = 1 ./ sum(G.' .* B, 1)';
        D = w_t .* inv(P_sqrtm);
    elseif(method == '2')
        % complexity O(n^3)
        [Ur,Sr,Vr] = svd(C);
        Sr = diag(Sr);
        RNK = sum(Sr > (length(Sr) * eps(single(Sr(1)))));
        SIR = Vr(:,1:RNK) * diag(1./sqrt(Sr(1:RNK))) * Ur(:,1:RNK)'; % square root
        P_sqrtm = Vr(:,1:RNK) * diag(sqrt(Sr(1:RNK))) * Ur(:,1:RNK)';
        B = L * P_sqrtm;
        G = B' / (B * B' + self.noise_cov);
        w_t = 1 ./ sum(G.' .* B, 1)';
        D = w_t .* SIR;
    else
        D = speye(size(C));
    end
    % Update
    K = C * L' / (L * C * L' + self.noise_cov);
    self.prev_step_reconstruction = x_f + K *(f + v' - L*x_f);
    % x_ensemble = x_ensemble';
    mean_x = mean(self.prev_step_reconstruction,2);
    z_vec = D*mean_x;
end

end % function
