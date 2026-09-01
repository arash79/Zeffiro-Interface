function [P_store,z_inverse] = kalman_filter(m,P,A,Q,L,R, timeSteps ,number_of_frames, smoothing)
%KALMAN_FILTER  Per-frame kf_predict + kf_update over timeSteps.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [P_store, z_inverse] = kalman_filter(m, P, A, Q, L, R, timeSteps, number_of_frames, smoothing)
%
%   Called from zef_KF (legacy Kalman plugin, not inverse.KalmanInverter)
%   for filter_type 1 (no standardization) and type 4 (spatial
%   standardization applied after this loop). If smoothing == 2, stores
%   P_store for RTS_smoother. Waitbar only; no zef I/O.
%
%   Inputs
%     m                 - prior mean (n_sources x 1)
%     P                 - prior covariance
%     A                 - transition (identity in zef_KF)
%     Q                 - process noise (diagonal or DTI structural Q)
%     L                 - processed lead field (H)
%     R                 - measurement noise (std_lhood^2 I)
%     timeSteps         - cell of measurement vectors, one per frame
%     number_of_frames  - length of timeSteps
%     smoothing         - if 2, keep P_store for RTS
%
%   Outputs
%     P_store    - cell of P per frame (empty unless smoothing == 2)
%     z_inverse  - cell of filtered means
%
%   See also zef_KF, kf_predict, kf_update, RTS_smoother.
%

P_store = cell(0);
z_inverse = cell(0);
h = zef_waitbar(0,1, 'Filtering');
for f_ind = 1: number_of_frames
    zef_waitbar(f_ind,number_of_frames,h,...
        ['Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    % Prediction
    [m,P] = kf_predict(m, P, A, Q);
    % Update
    [m, P] = kf_update(m, P, f, L, R);
    if (smoothing == 2)
        P_store{f_ind} = gather(P);
    end
    z_inverse{f_ind} = gather(m);
end
zef_close_waitbar(h);
end
