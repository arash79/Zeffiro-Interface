function M = zef_volume_scalar_diagonal_matrix(nodes, tetra, scalar_field, weighting)
%ZEF_VOLUME_SCALAR_DIAGONAL_MATRIX  Mass using only local vertex 1 (i=j=1).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unlike zef_volume_scalar_matrix this loops i=1:1, j=1:1, so only
%   sparse(tetra(:,1),tetra(:,1), φ V w_diag). Not a lumped four-vertex
%   mass. No first-party caller except the unused FF wrapper.
%
%   M = zef_volume_scalar_diagonal_matrix(nodes, tetra, scalar_field, weighting)
%
%   See also zef_volume_scalar_diagonal_matrix_FF.

N = size(nodes,1);
K = size(tetra,1);

if nargin < 4
    weighting = 1;
end

if nargin < 3
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

for i = 1 : 1
    for j = 1 : 1

        if i == j
            entry_vec = volume*weight_param(1);
        else
            entry_vec = volume*weight_param(2);
        end
        M_part = sparse(tetra(:,i),tetra(:,j),scalar_field.*entry_vec,N,N);

        if i == j
            M = M + M_part;
        else
            M = M + M_part;
            M = M + M_part';
        end

    end
end

end
