function [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R)
%KF_SL_UPDATE_APPROX  Kalman update with approximate P^{1/2} for sLORETA D.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R)
%
%   Approximates a square-root factor of P with N=5 / M=1 Schulz iterations,
%   then D = w .* P_sqrtm_right with the same sLORETA weights as kf_sL_update.
%   Measurement update matches kf_update.
%
%   See also plugins.ClassKF.kf_sL_update.

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
