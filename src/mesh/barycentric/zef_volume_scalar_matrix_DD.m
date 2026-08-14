function M = zef_volume_scalar_matrix_DD(nodes, tetra, g_i_ind, g_j_ind, scalar_field, weighting)
%ZEF_VOLUME_SCALAR_MATRIX_DD  Volume matrix ∫ φ (∇ψ_i)_α (∇ψ_j)_β dV (G·G).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Stiffness-like product of two gradient components. NSE builds the
%   vector Laplacian as GG(1,1)+GG(2,2)+GG(3,3) with weight 1 via
%   zef_volume_scalar_matrix_GG.
%
%   M = zef_volume_scalar_matrix_DD(nodes, tetra, g_i_ind, g_j_ind, scalar_field, weighting)
%
%   Inputs: g_i_ind, g_j_ind in {1,2,3}; scalar_field T×1 default 1;
%   weighting scalar or 1×2 default 1. Off-diagonals i<j add A+A'.
%
%   Output: N×N sparse.
%
%   See also zef_volume_scalar_matrix_GG, zef_volume_barycentric.

N = size(nodes,1);
K = size(tetra,1);

if nargin < 6
    weighting = 1;
end

if nargin < 5
    scalar_field = ones(size(tetra,1),1);
end

if length(weighting)==1
    weight_param = weighting([1 1]);
else
    weight_param = weighting;
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

M = spalloc(N,N,0);

for i = 1 : 4
    [g_i] = zef_volume_barycentric(nodes,tetra,i);

    for j = i : 4
        [g_j] = zef_volume_barycentric(nodes,tetra,j);

        if i == j
            entry_vec = volume*weight_param(1);
        else
            entry_vec = volume*weight_param(2);
        end
        M_part = sparse(tetra(:,i),tetra(:,j),scalar_field.*g_i(:,g_i_ind).*g_j(:,g_j_ind).*entry_vec,N,N);

        if i == j
            M = M + M_part;
        else
            M = M + M_part;
            M = M + M_part';
        end

    end
end
end
