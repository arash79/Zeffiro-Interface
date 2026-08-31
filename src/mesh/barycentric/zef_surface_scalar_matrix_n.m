function M = zef_surface_scalar_matrix_n(nodes, tetra, n_ind, scalar_field, weighting)
%ZEF_SURFACE_SCALAR_MATRIX_N  Boundary mass times unit-normal component n_ind.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   n = −∇ψ_f / ||∇ψ_f|| on each skin face (outward relative to the
%   opposite vertex). All 3×3 face vertex pairs are accumulated (not
%   symmetrized). NSE uses this for B1_* traction mass in zef_nse_matrices.
%
%   M = zef_surface_scalar_matrix_n(nodes, tetra, n_ind, scalar_field, weighting)
%
%   See also zef_nse_matrices, zef_surface_mesh.

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

[~,~,t_ind,~,~,~,~,f_ind] = zef_surface_mesh(tetra);

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

[n_vec,det] = zef_volume_barycentric(nodes,tetra(t_ind,:),f_ind);
area = (abs(det)/2).*sqrt(sum(n_vec.^2,2));
n_vec = n_vec(:,1:3);
n_vec = -n_vec./repmat(sqrt(sum(n_vec.^2,2)),1,3);

M = spalloc(N,N,0);

for i = 1 : 3

    I = sub2ind(size(tetra),t_ind,ind_m(f_ind,i));

    for j = 1 : 3

        J = sub2ind(size(tetra),t_ind,ind_m(f_ind,j));

        if i == j
            entry_vec = area*weight_param(1);
        else
            entry_vec = area*weight_param(2);
        end

        M_part = sparse(tetra(I),tetra(J),scalar_field(t_ind).*entry_vec.*n_vec(:,n_ind),N,N);

        M = M + M_part;

    end

end
end
