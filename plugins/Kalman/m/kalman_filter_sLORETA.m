function [P_store,z_inverse,D_store] = kalman_filter_sLORETA(m,P,A,Q,L,R, timeSteps ,number_of_frames, smoothing,standardization_exponent)
%KALMAN_FILTER_SLORETA  Per-frame kf_predict + kf_sL_update; stores raw m.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [P_store, z_inverse, D_store] = kalman_filter_sLORETA(...)
%
%   zef_KF filter_type 3. z_inverse{k} is the raw Kalman mean; D_store{k}
%   is the sLORETA operator from the prior P so the caller can RTS on m
%   then apply D (RTS on already-standardized states is not a Kalman RTS).
%
%   See also zef_KF, kf_sL_update, kalman_filter.

P_store = cell(0);
z_inverse = cell(0);
D_store = cell(0);
h = zef_waitbar(0,1, 'Filtering');
for f_ind = 1: number_of_frames
    zef_waitbar(f_ind,number_of_frames,h,...
        ['Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    [m,P] = kf_predict(m, P, A, Q);
    [m, P, ~, D] = kf_sL_update(m, P, f, L, R, standardization_exponent);
    z_inverse{f_ind} = gather(m);
    D_store{f_ind} = gather(D);
    if (smoothing == 2)
        P_store{f_ind} = gather(P);
    end
end
zef_close_waitbar(h);
end
