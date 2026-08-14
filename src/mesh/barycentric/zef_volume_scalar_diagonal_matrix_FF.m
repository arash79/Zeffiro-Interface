function M = zef_volume_scalar_diagonal_matrix_FF(nodes, tetra, scalar_field)
%ZEF_VOLUME_SCALAR_DIAGONAL_MATRIX_FF  Vertex-1-only mass with FF w_diag=1/10.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wrapper → zef_volume_scalar_diagonal_matrix. No first-party caller.
%
%   M = zef_volume_scalar_diagonal_matrix_FF(nodes, tetra, scalar_field)
%
%   See also zef_volume_scalar_diagonal_matrix.

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

weighting = zef_barycentric_weighting('FF');
M = zef_volume_scalar_diagonal_matrix(nodes, tetra, scalar_field, weighting);

end
