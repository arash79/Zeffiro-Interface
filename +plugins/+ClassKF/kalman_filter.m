function [P_store, z_inverse] = kalman_filter(m, P, A, Q, L, R, timeSteps, number_of_frames, smoothing, q_given)
%KALMAN_FILTER Standard Kalman filter for dynamic source reconstruction.
%
%   [P_STORE, Z_INVERSE] = KALMAN_FILTER(M, P, A, Q, L, R, TIMESTEPS,
%   NUMBER_OF_FRAMES, SMOOTHING, Q_GIVEN) runs a sequential Kalman filter
%   over multiple time frames. Each frame: predict, then update with new
%   measurement. Optional RTS smoothing if SMOOTHING == 2.
%
%   Inputs:
%     M               - Initial state mean (column vector)
%     P               - Initial state covariance
%     A               - State transition matrix
%     Q               - Process noise covariance (or cell if time-varying)
%     L               - Lead field (observation matrix)
%     R               - Measurement noise covariance
%     TIMESTEPS       - Cell array; timeSteps{f} = measurement at frame f
%     NUMBER_OF_FRAMES- Number of time frames
%     SMOOTHING       - 2 to store P for RTS smoothing; else no storage
%     Q_GIVEN         - true if Q is fixed matrix; false if Q is time-varying
%
%   Outputs:
%     P_STORE   - Cell of posterior covariances (populated if smoothing == 2)
%     Z_INVERSE - Cell array; z_inverse{f} = posterior mean at frame f
%
%   See also KF_PREDICT, KF_UPDATE, KALMAN_FILTER_SLORETA, RTS_SMOOTHER.

P_store = cell(0);
z_inverse = cell(0);
if not(q_given)
    q_values = Q;
end
h = zef_waitbar(0, 'Filtering');
for f_ind = 1: number_of_frames
    zef_waitbar(f_ind/number_of_frames,h,...
        ['Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    if not(q_given)
        Q = diag(q_values(:,f_ind));
    end
    % Prediction step
    [m, P] = kf_predict(m, P, A, Q);
    % Update step
    [m, P] = kf_update(m, P, f, L, R);
    if (smoothing == 2)
        P_store{f_ind} = gather(P);
    end
    z_inverse{f_ind} = gather(m);
end
close(h);
end