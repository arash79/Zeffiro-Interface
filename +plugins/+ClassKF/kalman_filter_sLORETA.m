function [P_store, z_inverse] = kalman_filter_sLORETA(m, P, A, Q, L, R, timeSteps, number_of_frames, smoothing, q_given)
%KALMAN_FILTER_SLORETA Kalman filter with sLORETA-style resolution weighting.
%
%   [P_STORE, Z_INVERSE] = KALMAN_FILTER_SLORETA(M, P, A, Q, L, R, TIMESTEPS,
%   NUMBER_OF_FRAMES, SMOOTHING, Q_GIVEN) runs a Kalman filter that applies
%   sLORETA-type resolution weighting (D matrix) to the posterior mean before
%   output. This reduces depth bias in source localization.
%
%   Inputs:
%     M, P, A, Q, L, R - Standard Kalman filter quantities
%     TIMESTEPS        - Cell array of measurements per frame
%     NUMBER_OF_FRAMES - Number of time frames
%     SMOOTHING        - 2 to store P for RTS smoothing; otherwise filtering only
%     Q_GIVEN          - true if Q is fixed; false if time-varying
%
%   Outputs:
%     P_STORE   - Cell of posterior covariances (if smoothing == 2)
%     Z_INVERSE - Cell array; z_inverse{f} = D*m (resolution-weighted estimate)
%
%   See also KALMAN_FILTER, KF_SL_UPDATE, RTS_SMOOTHER.

P_store = cell(0);
z_inverse = cell(0);
h = zef_waitbar(0, 'Filtering');
if not(q_given)
    q_values = Q;
end

for f_ind = 1: number_of_frames
    zef_waitbar(f_ind/number_of_frames,h,...
        ['Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    if not(q_given)
        Q = diag(q_values(:,f_ind));
    end
    % Prediction
    [m,P] = kf_predict(m, P, A, Q);
    % Update
    [m, P, ~, D] = kf_sL_update(m, P, f, L, R);
    z_inverse{f_ind} = gather(D*m);
    if (smoothing == 2)
        P_store{f_ind} = gather(P);
    end
end
close(h);
end