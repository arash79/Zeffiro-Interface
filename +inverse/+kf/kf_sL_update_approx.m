function [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R, standardization_exponent)
%KF_SL_UPDATE_APPROX  Kalman update with approximate P^{1/2} for sLORETA D.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R)
%   [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R, standardization_exponent)
%
%   Approximates P^{-1/2} with inverse.kf.spd_invsqrt_denman_beavers
%   (SPD eigendecomposition; the inherited Schulz-from-I stencil is not
%   used). Then D = w .* P^{-1/2} with the same sLORETA weights as
%   kf_sL_update. Measurement update matches kf_update.
%
%   standardization_exponent defaults to 1/2, as in kf_sL_update; see that
%   function for why it is a parameter and how it relates to the legacy
%   zef.standardization_exponent.
%
%   See also inverse.kf.kf_sL_update.

if nargin < 6
    standardization_exponent = 0.5;
end

    P_invsqrt = inverse.kf.spd_invsqrt_denman_beavers(P);
    B = H * P;
    K = B * P_invsqrt;
    G = K' / (B * H' + R);
    w_t = 1 ./ (sum(G.' .* K, 1)').^standardization_exponent;
    D = w_t .* P_invsqrt;

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
