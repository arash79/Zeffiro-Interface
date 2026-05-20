function [q] = find_evolution_prior(L, f_data, likelihood_std, evolution_prior_db, evolution_mode)
%FIND_EVOLUTION_PRIOR Compute process noise covariance Q for Kalman filter.
%
%   Q = FIND_EVOLUTION_PRIOR(L, F_DATA, LIKELIHOOD_STD, EVOLUTION_PRIOR_DB, EVOLUTION_MODE)
%   computes the evolution (process) noise covariance matrix Q based on the
%   lead field L, measured data f_data, and user-specified prior strength.
%
%   Inputs:
%     L                 - Lead field matrix
%     F_DATA            - Filtered measurement data (sensors x time)
%     LIKELIHOOD_STD    - Measurement noise std (typically 10^(-SNR_dB/20))
%     EVOLUTION_PRIOR_DB- Prior strength in dB (relative to measurement)
%     EVOLUTION_MODE    - 1: Spatially adaptive, sensitivity-weighted
%                         2: Spatially averaged sensitivity
%                         3: SVD-based (full matrix Q; may be numerically unstable)
%                         4: Averaged signal-space contribution
%                         5: Time-step scaled
%
%   Output:
%     Q - Process noise covariance (matrix or vector depending on mode)

switch evolution_mode
    case 1
    % Spatially adaptive: scale Q by local lead field sensitivity and data
    % variability. SNR relation: (q*||L||^2)^2 / E[||noise||^2]
        f = sqrt(mean(diff(f_data').^2,2))*10^(evolution_prior_db/20);
        f = [f;f(end)];
        q = transpose((1-likelihood_std^2)*f./repelem(sum(reshape(sum(L.^2),3,[])),3));
    case 2
        % Same as case 1 but with spatially averaged sensitivity
        f = sqrt(mean(diff(f_data').^2,2))*10^(evolution_prior_db/20);
        f = [f;f(end)];
        q = transpose((1-likelihood_std^2)*f/mean(repelem(sum(reshape(sum(L.^2),3,[])),3)));
    case 3
        % SVD-based: theoretically optimal for tracking but may be numerically unstable
        [~,S,V] =  svd(L,"econ");
        f = diff(f_data')';
        f = 10^(evolution_prior_db/20)*sum(f.^2,2)./sum(f_data.^2,2);         
        S = max((diag(S).^2),likelihood_std^2/(1-likelihood_std^2));
        q = (V.*(f./S)')*V';
    case 4
        % Averaged signal-space contribution
        S =  svd(L);
        f = diff(f_data')';
        f = sum(f.^2,2)./sum(f_data.^2,2);         
        S = max(S.^2,likelihood_std^2/(1-likelihood_std^2));
        q = mean(f./S)*10^(evolution_prior_db/20);
    case 5
        q = time_step*(svds(L,1).^(2)/sum(L(:).^2))*10^(evolution_prior_db/20);
end
end

