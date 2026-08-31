function Q = zef_dti_expand_source_covariance(Q_source, source_direction_mode)
%ZEF_DTI_EXPAND_SOURCE_COVARIANCE  Lift N×N source Q onto the KF state.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_processLeadfields stores Cartesian L as blocked
%   [X-block, Y-block, Z-block]. Plugin Kalman (zef_KF) uses that layout,
%   so the 3-component expansion is kron(I_3, Q_source) = blkdiag(Q,Q,Q).
%   kron(Q, I_3) would be correct only for interleaved [x1 y1 z1 …] state
%   (the class path after zef_process_inversion).
%
%   Mode 2/3 (one component per location) leave Q unchanged.
%
%   Q = zef_dti_expand_source_covariance(Q_source, source_direction_mode)
%
%   See also zef_dti_structural_Q, zef_processLeadfields.

if source_direction_mode == 1
    Q = kron(speye(3), Q_source);
else
    Q = Q_source;
end

end
