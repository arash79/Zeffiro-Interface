function [m, P, K, D] = kf_sL_update(m,P,y,H,R,standardization_exponent)
%KF_SL_UPDATE  sLORETA-weighted Kalman update; also returns diagonal weights D.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K, D] = kf_sL_update(m, P, y, H, R, standardization_exponent)
%
%   Called from kalman_filter_sLORETA (zef_KF filter_type 3). Builds D from
%   sqrtm(P) and H so z_inverse = D*m. standardization_exponent comes from
%   zef.standardization_exponent via zef_KF. No zef fields here.
%
%   Inputs
%     m                         - predicted mean
%     P                         - predicted covariance
%     y                         - measurement
%     H                         - observation (L)
%     R                         - measurement noise
%     standardization_exponent  - power on the sLORETA weights
%
%   Outputs
%     m - updated mean
%     P - updated covariance
%     K - Kalman gain
%     D - sLORETA weight matrix (z = D*m)
%
%   See also kalman_filter_sLORETA.

    P_sqrtm = sqrtm(P);
    B = H * P_sqrtm;
    G = B' / (B * B' + R);
    w_t = 1 ./ ((sum(G.' .* B, 1))').^standardization_exponent;
    D = w_t .* inv(P_sqrtm);

    v = y - H*m;
    PHt = P * H';
    S = H * PHt + R;
    S = (S + S')/2; % Ensure S is symmetric positive definite for numerical stability
    K = PHt / S;
    m = m + K*v;
    P = P - K * PHt';
    P = (P + P')/2; % Ensure P is symmetric positive definite for numerical stability

end
