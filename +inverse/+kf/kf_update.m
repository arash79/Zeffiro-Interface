function [m, P, K] = kf_update(m, P, y, H, R)
%KF_UPDATE  Kalman measurement update with symmetrized S and P.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P, K] = kf_update(m, P, y, H, R)
%
%   Inputs: m (state mean), P (state covariance), y (measurement),
%   H (observation matrix: processed lead field L), R (measurement noise).
%   Innovation v = y - H m, S = H P H' + R (symmetrized), gain K = P H' / S,
%   then m ← m + K v and P ← P - K (P H')' with P symmetrized.
%   This is not the Joseph form (I−KH)P(I−KH)'+KRK'.
%
%   Called by KalmanInverter for "Basic Kalman filter" and by
%   UKFNMMInverter's spatial stage.
%
%   See also inverse.kf.class_kf_predict, inverse.kf.kf_sL_update.

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
