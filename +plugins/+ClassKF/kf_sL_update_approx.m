function [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R)
%KF_SL_UPDATE_APPROX Kalman update with approximated sLORETA resolution matrix.
%
%   [M, P, K, D] = KF_SL_UPDATE_APPROX(M, P, Y, H, R) performs the Kalman
%   update step and computes an approximate resolution matrix D using
%   Newton-Schulz iterations for matrix square root/inverse. Use when sqrtm(P)
%   is too expensive; trade-off is approximation accuracy.
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
%     K - Kalman gain
%     D - Approximate sLORETA resolution matrix

% Newton-Schulz iterations to approximate P^(-1/2) and P^(1/2)
N = 5; M_iter = 1;
    Z = eye(length(m));
    Y_mat = P;
    invY = Z;
    invZ = Z;
    for n = 1:N
        for k = 1:M_iter
            invY = 2*invY - invY*Y_mat*invY;
            invZ = 2*invZ - invZ*Z*invZ;
        end
        Y_mat = 0.5*(Y_mat + invZ);
        Z = 0.5*(Z + invY);
    end
    P_sqrtm_right = Z;
    B = H * P;  % H * P^(1/2) approximation
    K = B*P_sqrtm_right;
    G = K' / (B * H' + R);
    w_t = 1 ./ sqrt(sum(G.' .* K, 1))';
    D = w_t .* P_sqrtm_right;

    % Standard Kalman update
    v = y - H*m;
    PHt = P * H';
    S = H * PHt + R;
    S = (S + S')/2; % Ensure S is symmetric positive definite for numerical stability
    K = PHt / S;
    m = m + K*v;
    P = P - K * PHt';
    P = (P + P')/2; % Ensure P is symmetric positive definite for numerical stability



end

