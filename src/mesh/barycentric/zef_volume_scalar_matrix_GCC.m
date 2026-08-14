function M = zef_volume_scalar_matrix_GCC(nodes, tetra, g_i_ind, scalar_field, weighting)
%ZEF_VOLUME_SCALAR_MATRIX_GCC  Scatter φ V (∇ψ_i)_α from tets to nodes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Loop i=1:4 adds sparse(tetra(:,i), aux_vec.*g_i(:,g_i_ind)) with two
%   arguments only (MATLAB treats the second as values, column index 1).
%   weighting is read but not used. No first-party caller.
%
%   M = zef_volume_scalar_matrix_GCC(nodes, tetra, g_i_ind, scalar_field, weighting)
%
%   See also zef_volume_scalar_matrix_CC, zef_volume_barycentric.

N = size(nodes,1);
K = size(tetra,1);

if nargin < 5
    weighting = 1;
end

if nargin < 4
    scalar_field = ones(size(tetra,1),1);
end

if length(weighting)==1
    weight_param = weighting([1 1]);
else
    weight_param = weighting;
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

aux_vec = scalar_field.*volume;

M = spalloc(N,N,0);

for i = 1 : 4

    [g_i] = zef_volume_barycentric(nodes,tetra,i,det);
    M_part =  sparse(tetra(:,i),aux_vec.*g_i(:,g_i_ind));
    M = M + M_part;
end
end
