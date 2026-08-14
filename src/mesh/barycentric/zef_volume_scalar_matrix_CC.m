function M = zef_volume_scalar_matrix_CC(nodes, tetra, scalar_field)
%ZEF_VOLUME_SCALAR_MATRIX_CC  T×T diagonal of φ V (constant-per-tet mass).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   C = piecewise constant on tetrahedra. spdiags(scalar_field.*volume,0,T,T).
%   No first-party caller.
%
%   M = zef_volume_scalar_matrix_CC(nodes, tetra, scalar_field)
%
%   See also zef_volume_scalar_matrix.

K = size(tetra,1);

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

aux_vec = scalar_field.*volume;

M = spdiags(aux_vec,0,K,K);

end
