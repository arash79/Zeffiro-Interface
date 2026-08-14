function M = zef_volume_scalar_matrix_GG(nodes,tetra,g_i_ind,g_j_ind,scalar_field)
%ZEF_VOLUME_SCALAR_MATRIX_GG  ∫ φ (∇ψ)_α (∇ψ)_β dV with GG weight 1.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_volume_scalar_matrix_DD. NSE Laplacian K, L use
%   GG(1,1)+GG(2,2)+GG(3,3). No other first-party callers.
%
%   M = zef_volume_scalar_matrix_GG(nodes, tetra, g_i_ind, g_j_ind, scalar_field)
%
%   See also zef_volume_scalar_matrix_DD, zef_nse_poisson.

weighting = zef_barycentric_weighting('GG');
M = zef_volume_scalar_matrix_DD(nodes,tetra,g_i_ind,g_j_ind,scalar_field,weighting);

end
