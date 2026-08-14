function S_mat = zef_simple_smoothing_matrix(tetra, nodes)
%ZEF_SIMPLE_SMOOTHING_MATRIX  Row-stochastic graph smoother from tet connectivity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   S = zef_simple_smoothing_matrix(tetra, nodes)
%
%   For each tet, add 1 on every vertex pair (including i=i). Then
%   S = D^{-1} A with D_ii = sum_j A_ij so rows sum to 1. c_ave is
%   computed (1/4) but unused. zef_smooth_field does *not* call this;
%   it rebuilds a similar average with accumarray.
%
%   See also zef_smooth_field.
n_nodes = size(nodes,1);
c_ave = 1/size(tetra,2);

S_mat = spalloc(n_nodes,n_nodes,0);

for i = 1 : size(tetra,2)
    for j = i : size(tetra,2) 

S_part = sparse(tetra(:,i),tetra(:,j),ones(size(tetra,1),1),n_nodes,n_nodes);

if i == j
    S_mat = S_mat + S_part;
else
    S_mat = S_mat + S_part;
    S_mat = S_mat + S_part';
end

    end
end

scale_vec=S_mat*ones(n_nodes,1);
D = spdiags(1./scale_vec,0,n_nodes,n_nodes);
S_mat = D*S_mat;

end
