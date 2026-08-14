function M = zef_surface_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting)
%ZEF_SURFACE_SCALAR_MATRIX_D  Boundary ∫ φ (∇ψ_i)_α ψ_j dS (surface G·F).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Face mapping as zef_surface_scalar_matrix. g_i is ∇ψ of local vertex i
%   on the *full* tet (not just the face). Used by unused wrapper
%   zef_surface_scalar_matrix_FG. No NSE caller.
%
%   M = zef_surface_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting)
%
%   See also zef_surface_scalar_matrix, zef_surface_mesh.

N = size(nodes,1);
K = size(tetra,1);

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

[~,~,t_ind,~,~,~,~,f_ind] = zef_surface_mesh(tetra);

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

[b_vec,det] = zef_volume_barycentric(nodes,tetra(t_ind,:),f_ind);
area = (abs(det)/2).*sqrt(sum(b_vec(:,1:3).^2,2));

M = spalloc(N,N,0);

for i = 1 : 3

    [g_i] = zef_volume_barycentric(nodes,tetra,i,det);

    I = sub2ind(size(tetra),t_ind,ind_m(f_ind,i));

    for j = i : 3

        J = sub2ind(size(tetra),t_ind,ind_m(f_ind,j));

        if i == j
            entry_vec = area*weight_param(1);
        else
            entry_vec = area*weight_param(2);
        end
        M_part =  sparse(tetra(I),tetra(J),scalar_field(t_ind).*g_i(t_ind,g_i_ind).*entry_vec,N,N);
        if i == j
            M = M + M_part;
        else
            M = M + M_part;
            M = M + M_part';
        end

    end

end
end
