function [P_s_store, m_s_store, G_store] = RTS_smoother(P_store, z_inverse, A, Q, number_of_frames)
%RTS_SMOOTHER Rauch-Tung-Striebel backward smoother for Kalman filter.
%
%   [P_S_STORE, M_S_STORE, G_STORE] = RTS_SMOOTHER(P_STORE, Z_INVERSE, A, Q, NUMBER_OF_FRAMES)
%   applies the RTS backward pass to obtain smoothed state estimates. Runs
%   backward in time from the last frame to the first.
%
%   Inputs:
%     P_STORE         - Cell array of filter posterior covariances P{k}
%     Z_INVERSE       - Cell array of filter posterior means m{k}
%     A               - State transition matrix
%     Q               - Process noise covariance
%     NUMBER_OF_FRAMES- Number of time frames
%
%   Outputs:
%     P_S_STORE - Cell array of smoothed covariances
%     M_S_STORE - Cell array of smoothed state means
%     G_STORE   - Cell array of smoother gains
%
%   See also KALMAN_FILTER, KALMAN_FILTER_SLORETA.

P_s_store = cell(0);
m_s_store = cell(0);
G_store = cell(0);
h = zef_waitbar(0, 'Smoothing');

for f_ind = number_of_frames:-1:1
    zef_waitbar(1 - f_ind/number_of_frames,h, ['Smoothing ' int2str(number_of_frames -f_ind) ' of ' int2str(number_of_frames) '.']);

    P = P_store{f_ind};
    m = z_inverse{f_ind};
    % Predicted quantities for backward pass
    if (isdiag(A) && all(diag(A) - 1) < eps)
        P_ = P + Q;
        m_ = m;
        G =  P / P_;
    else
        P_ = A * P * A' + Q;
        m_ = A * m;
        G =  (P * A') / P_;
    end
    if f_ind == number_of_frames
        m_s = m;
        P_s = P;
    else
        m_s = m + G * (m_s - m_);
        P_s = P + G * (P_s - P_) * G';
    end
    P_s_store{f_ind} = P_s;
    G_store{f_ind} = G;
    m_s_store{f_ind} = m_s;
end

close(h);
end
