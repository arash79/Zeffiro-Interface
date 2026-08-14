function M = zef_volume_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting)
%ZEF_VOLUME_SCALAR_MATRIX_D  Volume matrix ∫ φ (∇ψ_i)_α ψ_j dV (G·F / FG).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   G is one Cartesian component of ∇ψ (g_i_ind 1=x, 2=y, 3=z). Rows of M
%   are the test vertex j, columns the trial vertex i (sparse(tetra(:,j),
%   tetra(:,i), ...)). NSE's zef_volume_scalar_matrix_FG uses weight 1/4.
%
%   M = zef_volume_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting)
%
%   Inputs: nodes N×3, tetra T×4, g_i_ind 1..3, scalar_field T×1 (default 1),
%   weighting scalar (default 1). Volume = abs(det)/6.
%
%   Output: N×N sparse, not symmetrized (gradient–hat is unsymmetric).
%
%   See also zef_volume_scalar_matrix_FG, zef_volume_barycentric.

N = size(nodes,1);

if nargin < 5
    weighting = 1;
end

if nargin < 4
    scalar_field = ones(size(tetra,1),1);
end

weight_param = weighting;

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

M = spalloc(N,N,0);

entry_vec = volume*weight_param;

for i = 1 : 4

    [g_i] = zef_volume_barycentric(nodes,tetra,i);

    for j = 1 : 4

        M_part = sparse(tetra(:,j),tetra(:,i),scalar_field.*g_i(:,g_i_ind).*entry_vec,N,N);
        M = M + M_part;

    end

end

end
