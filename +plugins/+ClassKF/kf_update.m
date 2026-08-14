function [m, P, K] = kf_update(m, P, y, H, R)
%KF_UPDATE  Kalman measurement update (Joseph-form covariance).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K] = kf_update(m, P, y, H, R)
%
%   Innovation v = y - H m, gain K = P H' / (H P H' + R), then
%   m ← m + K v and P ← P - K (P H')' with explicit symmetrization of S and P.
%   H is the processed lead field L; R is measurement noise_cov.
%
%   See also plugins.ClassKF.class_kf_predict, plugins.ClassKF.kf_sL_update.

v = y - H*m;
PHt = P * H';
S = H * PHt + R;
S = (S + S')/2;  % Ensure S is symmetric positive definite for numerical stability
K = PHt / S;
% m ← m + K (y - H m);  P ← P - K (P H')'
m = m + K*v;
P = P - K * PHt';
P = (P + P')/2; % Ensure P remains symmetric positive definite
end
