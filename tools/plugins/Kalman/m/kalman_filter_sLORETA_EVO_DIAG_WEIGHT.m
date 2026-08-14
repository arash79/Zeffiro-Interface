function [P_store,z_inverse] = kalman_filter_sLORETA_EVO_DIAG_WEIGHT(m,P,A,Q,L,R, timeSteps ,number_of_frames, smoothing)
%KALMAN_FILTER_SLORETA_EVO_DIAG_WEIGHT  sLORETA Kalman that rescales diag(Q) from the current |source| map.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [P_store, z_inverse] = kalman_filter_sLORETA_EVO_DIAG_WEIGHT(m, P, A, Q, L, R, timeSteps, number_of_frames, smoothing)
%
%   Not wired to the Kalman StartButton (zef_KF uses kalman_filter_sLORETA
%   for type 3). After each update, Q diagonal is weighted by a normalized
%   amplitude map (c_val = 0.05). Optional helper. kf_sL_update is called
%   without standardization_exponent (MATLAB default).
%
%   See also kalman_filter_sLORETA, kf_sL_update.
%

P_store = cell(0);
z_inverse = cell(0);
h = zef_waitbar(0,1, 'Filtering');
c_val = 0.05;
diag_Q = diag(Q);
for f_ind = 1: number_of_frames
    zef_waitbar(f_ind,number_of_frames,h,...
        ['Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    % Prediction
    [m,P] = kf_predict(m, P, A, Q);
    % Update
    [m, P, ~, D] = kf_sL_update(m, P, f, L, R);
    z_inverse{f_ind} = gather(D*m);
    s_aux = z_inverse{f_ind};
    s_aux = abs(s_aux(:));
    max_s_aux = max(s_aux);
    diag_aux = ((1-c_val)*s_aux + c_val)./((1-c_val).*max_s_aux + c_val);
    Q = diag(diag_Q.*diag_aux);
    if (smoothing == 2)
        P_store{f_ind} = gather(P);
    end
end
close(h);
end
