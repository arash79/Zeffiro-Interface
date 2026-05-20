function [m, P, K] = kf_update(m,P,y,H,R)
% kf_update is the update step of kalman filter
    v = y - H*m;
    PHt = P * H';
    S = H * PHt + R; 
    S = (S + S')/2;  % Ensure S is symmetric positive definite for numerical stability
    K = PHt / S;
    m = m + K*v;
    P = P - K * PHt'; % we have K = PHt / S then PHt = K*S hence PHt' = S*K' (s is symmetric)
    P = (P + P')/2; % Ensure P is symmetric positive definite for numerical stability
end
