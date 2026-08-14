function M = zef_volume_scalar_matrix_GFu(nodes,tetra,g_i_ind,scalar_field)
%ZEF_VOLUME_SCALAR_MATRIX_GFU  Identical implementation to zef_volume_scalar_matrix_FFG.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Name suggests G·F·u; body is FF-weighted zef_volume_scalar_matrix_D.
%   No first-party caller.
%
%   M = zef_volume_scalar_matrix_GFu(nodes, tetra, g_i_ind, scalar_field)
%
%   See also zef_volume_scalar_matrix_D.

weighting = zef_barycentric_weighting('FF');
M = zef_volume_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting);

end
