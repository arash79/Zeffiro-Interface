function [m, P, K, D] = kf_sL_update(m, P, y, H, R)
%KF_SL_UPDATE  Kalman update plus sLORETA standardization matrix D.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K, D] = kf_sL_update(m, P, y, H, R)
%
%   Builds D = w .* inv(sqrtm(P)) with w_i = 1/sqrt(diag(G' B)) from
%   B = H sqrtm(P) and G = B' / (B B' + R), then the same K/m/P update as
%   kf_update. KalmanInverter.invert returns z = D*x. Local flag method='1'
%   selects dense sqrtm; '2' (truncated SVD) is unused unless that string changes.
%
%   See also plugins.ClassKF.kf_sL_update_approx, plugins.ClassKF.kf_update.

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
