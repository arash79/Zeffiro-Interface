function M = zef_volume_scalar_matrix_FF(nodes, tetra, scalar_field)
%ZEF_VOLUME_SCALAR_MATRIX_FF  P1 mass ∫ φ ψ_i ψ_j dV with weights [1/10 1/20].
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_volume_scalar_matrix. NSE mass C, I_μ, M_2. scalar_field
%   default ones(T,1).
%
%   M = zef_volume_scalar_matrix_FF(nodes, tetra, scalar_field)
%
%   See also zef_volume_scalar_matrix, zef_nse_poisson.

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

weighting = zef_barycentric_weighting('FF');
M = zef_volume_scalar_matrix(nodes, tetra, scalar_field, weighting);

end
