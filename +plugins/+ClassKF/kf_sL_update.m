function [m, P, K, D] = kf_sL_update(m, P, y, H, R)
%KF_SL_UPDATE Kalman update with sLORETA resolution matrix for depth bias correction.
%
%   [M, P, K, D] = KF_SL_UPDATE(M, P, Y, H, R) performs the Kalman update step
%   and computes the sLORETA-style resolution matrix D. Output estimate is D*m,
%   which reduces depth bias in source localization compared to raw m.
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
%     D - sLORETA resolution matrix (apply to m for depth-unbiased estimate)
%
%   See also KF_UPDATE, KF_SL_UPDATE_APPROX.

method = '1';  % 1: sqrtm; 2: SVD-based (for singular/near-singular P)
if method == '1'
    P_sqrtm = sqrtm(P);
    B = H * P_sqrtm;
    G = B' / (B * B' + R);
    w_t = 1 ./ sqrt(sum(G.' .* B, 1))';
    D = w_t .* inv(P_sqrtm);
elseif method == '2'
    [Ur,Sr,Vr] = svd(P);
    Sr = diag(Sr);
    RNK = sum(Sr > (length(Sr) * eps(single(Sr(1)))));
    SIR = Vr(:,1:RNK) * diag(1./sqrt(Sr(1:RNK))) * Ur(:,1:RNK)'; % square root
    P_sqrtm = Vr(:,1:RNK) * diag(sqrt(Sr(1:RNK))) * Ur(:,1:RNK)';
    B = H * P_sqrtm;
    G = B' / (B * B' + R);
    w_t = 1 ./ sum(G.' .* B, 1)';
    D = w_t .* SIR;
end

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

