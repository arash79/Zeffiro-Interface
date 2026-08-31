function [m, P, K] = kf_update(m,P,y,H,R)
%KF_UPDATE  Kalman measurement update with H = L and noise R.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K] = kf_update(m, P, y, H, R)
%
%   Called from kalman_filter (filter_type 1 and 4) and the block filters.
%   Innovation v = y - H m; K = P H' / (H P H' + R). No zef fields.
%
%   Inputs
%     m - predicted mean
%     P - predicted covariance
%     y - measurement (one frame)
%     H - observation (processed lead field L)
%     R - measurement noise
%
%   Outputs
%     m - updated mean
%     P - updated covariance (symmetric in exact arithmetic)
%     K - Kalman gain
%
%   See also kf_predict, kf_sL_update, kalman_filter.
%

    v = y - H*m;
    PHt = P * H';
    S = H * PHt + R; 
    S = (S + S')/2;  % Ensure S is symmetric positive definite for numerical stability
    K = PHt / S;
    m = m + K*v;
    P = P - K * PHt'; % we have K = PHt / S then PHt = K*S hence PHt' = S*K' (s is symmetric)
    P = (P + P')/2; % Ensure P is symmetric positive definite for numerical stability
end
