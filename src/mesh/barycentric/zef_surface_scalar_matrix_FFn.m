function M = zef_surface_scalar_matrix_FFn(nodes,tetra,n_ind,scalar_field)
%ZEF_SURFACE_SCALAR_MATRIX_FFN  Surface F·F·n with [1/6 1/12]. No first-party caller.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   M = zef_surface_scalar_matrix_FFn(nodes, tetra, n_ind, scalar_field)
%
%   See also zef_surface_scalar_matrix_n.

weighting = zef_barycentric_weighting('surface_FF');
M = zef_surface_scalar_matrix_n(nodes, tetra, n_ind, scalar_field, weighting);

end
