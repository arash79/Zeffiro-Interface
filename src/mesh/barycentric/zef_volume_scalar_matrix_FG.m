function M = zef_volume_scalar_matrix_FG(nodes,tetra,g_i_ind,scalar_field)
%ZEF_VOLUME_SCALAR_MATRIX_FG  ∫ φ ψ (∇ψ)_α dV with FG weight 1/4.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_volume_scalar_matrix_D. NSE divergence/gradient blocks
%   Q_1,Q_2,Q_3 (one per Cartesian component).
%
%   M = zef_volume_scalar_matrix_FG(nodes, tetra, g_i_ind, scalar_field)
%
%   See also zef_volume_scalar_matrix_D, zef_nse_poisson.

weighting = zef_barycentric_weighting('FG');
M = zef_volume_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting);

end
