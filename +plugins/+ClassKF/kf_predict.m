function [m, P] = kf_predict(m, P, A, Q)
%KF_PREDICT Kalman filter prediction step.
%
%   [M, P] = KF_PREDICT(M, P, A, Q) computes the predicted state mean and
%   covariance:
%     m_pred = A * m
%     P_pred = A * P * A' + Q
%
%   When A is the identity matrix, the computation is simplified to avoid
%   redundant multiplications: m_pred = m, P_pred = P + Q.
%
%   Inputs:
%     M - Current state mean (column vector)
%     P - Current state covariance
%     A - State transition matrix
%     Q - Process noise covariance
%
%   Outputs:
%     M - Predicted state mean
%     P - Predicted state covariance

if (isdiag(A) && all(diag(A) - 1) < eps)
    P = P + Q;
    % m unchanged when A = I
else
    m = A * m;
    P = A * P * A' + Q;
end
end
