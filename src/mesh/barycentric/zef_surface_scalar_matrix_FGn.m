function M = zef_surface_scalar_matrix_FGn(nodes,tetra,g_i_ind,n_ind,scalar_field)
%ZEF_SURFACE_SCALAR_MATRIX_FGN  Surface F·G·n with weight 1/3.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_surface_scalar_matrix_Dn. Only appears in commented NSE
%   lines (zef_nse_poisson_dynamic).
%
%   M = zef_surface_scalar_matrix_FGn(nodes, tetra, g_i_ind, n_ind, scalar_field)
%
%   See also zef_surface_scalar_matrix_Dn.

weighting = zef_barycentric_weighting('surface_FG');
M = zef_surface_scalar_matrix_Dn(nodes, tetra, g_i_ind, n_ind, scalar_field, weighting);

end
