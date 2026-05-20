function [m, P, K] = kf_update(m, P, y, H, R)
%KF_UPDATE Kalman filter update step.
%
%   [M, P, K] = KF_UPDATE(M, P, Y, H, R) performs the Kalman filter update
%   given predicted state (m, P) and new measurement y:
%     v = y - H*m                    (innovation)
%     S = H*P*H' + R                 (innovation covariance)
%     K = P*H'/S                     (Kalman gain)
%     m = m + K*v                    (updated mean)
%     P = (I - K*H)*P                (updated covariance)
%
%   Inputs:
%     M - Predicted state mean
%     P - Predicted state covariance
%     Y - Measurement vector
%     H - Observation matrix (lead field)
%     R - Measurement noise covariance
%
%   Outputs:
%     M - Updated state mean
%     P - Updated state covariance
%     K - Kalman gain matrix

v = y - H*m;
PHt = P * H';
S = H * PHt + R;
S = (S + S')/2;  % Ensure S is symmetric positive definite for numerical stability
K = PHt / S;
m = m + K*v;
P = P - K * PHt';
P = (P + P')/2; % Ensure P remains symmetric positive definite
end
