function M = zef_surface_scalar_matrix_FG(nodes,tetra,g_i_ind,scalar_field)
%ZEF_SURFACE_SCALAR_MATRIX_FG  Surface G·F with weight 1/3. No first-party caller.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   M = zef_surface_scalar_matrix_FG(nodes, tetra, g_i_ind, scalar_field)
%
%   See also zef_surface_scalar_matrix_D.

weighting = zef_barycentric_weighting('surface_FG');
M = zef_surface_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting);

end
