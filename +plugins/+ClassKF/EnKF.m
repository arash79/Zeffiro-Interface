function [z_inverse] = EnKF(m, A, P, Q, L, R, timeSteps, number_of_frames, n_ensembles, q_given)
%ENKF Ensemble Kalman filter for dynamic source reconstruction.
%
%   Z_INVERSE = ENKF(M, A, P, Q, L, R, TIMESTEPS, NUMBER_OF_FRAMES, N_ENSEMBLES, Q_GIVEN)
%   applies the Ensemble Kalman Filter to estimate brain source activity over
%   time. Uses Monte Carlo sampling instead of explicit covariance propagation.
%
%   Inputs:
%     M               - Initial state mean (column vector)
%     A               - State transition matrix
%     P               - Initial state covariance
%     Q               - Process noise covariance (or cell of time-varying Q if ~q_given)
%     L               - Lead field matrix (observation operator)
%     R               - Measurement noise covariance
%     TIMESTEPS       - Cell array; timeSteps{f} = measurement at frame f
%     NUMBER_OF_FRAMES- Number of time frames
%     N_ENSEMBLES     - Number of ensemble members
%     Q_GIVEN         - true if Q is fixed; false if Q is time-varying (cell)
%
%   Output:
%     Z_INVERSE - Cell array; z_inverse{f} = source estimate at frame f
%                 (resolution-weighted ensemble mean)
%
%   See also KALMAN_FILTER, KALMAN_FILTER_SLORETA.

x_ensemble = mvnrnd(zeros(size(m)), P, n_ensembles)';
z_inverse = cell(0);
if ~q_given
    q_values = Q;
end

h = zef_waitbar(0, 'EnKF Filtering');
for f_ind = 1:number_of_frames
    zef_waitbar(f_ind/number_of_frames,h,...
        ['EnKF Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    if not(q_given)
        Q = diag(q_values(:,f_ind));
    end
    w = mvnrnd(zeros(size(m)), Q, n_ensembles)';
    % Forecast step: propagate ensemble through state transition
    x_f = A * x_ensemble + w;
    C = cov(x_f');
    % Correlation localization: zero out weak correlations to reduce spurious
    % long-range connections and improve conditioning
    correlationLocalization = true;
    if correlationLocalization
        T = corrcoef(x_f');
        T(abs(T) < 0.05) = 0;  % Threshold for negligible correlation
        C = C .* T;
    end
    v = mvnrnd(zeros(size(R,1),1), R, n_ensembles);

    % Resolution matrix D: optional deconvolution for source localization
    method = '3';
    if(method == '1')
        P_sqrtm = sqrtm(C);
        B = L * P_sqrtm;
        G = B' / (B * B' + R);
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
        G = B' / (B * B' + R);
        w_t = 1 ./ sum(G.' .* B, 1)';
        D = w_t .* SIR;
    else
        D = speye(size(C));  % No resolution weighting
    end

    % Update step: Kalman gain and ensemble update
    K = C * L' / (L * C * L' + R);
    x_ensemble = x_f + K*(f + v' - L*x_f);
    mean_x = mean(x_ensemble, 2);
    z_inverse{f_ind} = D*mean_x;  % Apply resolution weighting to output
end
close(h);
end
