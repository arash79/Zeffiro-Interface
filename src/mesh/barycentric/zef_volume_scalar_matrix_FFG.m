function M = zef_volume_scalar_matrix_FFG(nodes, tetra, g_i_ind, scalar_field)
%ZEF_VOLUME_SCALAR_MATRIX_FFG  Same as FG but with FF weights [1/10 1/20].
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_volume_scalar_matrix_D. No first-party caller (NSE uses FG).
%
%   M = zef_volume_scalar_matrix_FFG(nodes, tetra, g_i_ind, scalar_field)
%
%   See also zef_volume_scalar_matrix_D, zef_volume_scalar_matrix_FG.

weighting = zef_barycentric_weighting('FF');
M = zef_volume_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting);

end
