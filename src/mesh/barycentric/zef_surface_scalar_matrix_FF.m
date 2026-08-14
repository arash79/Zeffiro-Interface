function M = zef_surface_scalar_matrix_FF(nodes,tetra,scalar_field)
%ZEF_SURFACE_SCALAR_MATRIX_FF  Boundary mass with weights [1/6 1/12].
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_surface_scalar_matrix. NSE M_1 (Robin / dynamic mass).
%
%   M = zef_surface_scalar_matrix_FF(nodes, tetra, scalar_field)
%
%   See also zef_surface_scalar_matrix, zef_nse_poisson.

weighting = zef_barycentric_weighting('surface_FF');
M = zef_surface_scalar_matrix(nodes, tetra, scalar_field, weighting);

end
