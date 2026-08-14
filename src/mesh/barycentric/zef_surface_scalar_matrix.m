function M = zef_surface_scalar_matrix(nodes, tetra, scalar_field, weighting)
%ZEF_SURFACE_SCALAR_MATRIX  Boundary mass ∫_∂Ω φ ψ_i ψ_j dS (surface F·F).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Skin faces from zef_surface_mesh. Face area is
%   (abs(det)/2)*||∇ψ_f|| where ψ_f is the hat of the vertex opposite the
%   face (zef_volume_barycentric on those tets with p_ind = f_ind).
%   NSE uses the surface_FF wrapper ([1/6 1/12]) for Robin/mass terms.
%
%   M = zef_surface_scalar_matrix(nodes, tetra, scalar_field, weighting)
%
%   Inputs: nodes N×3, tetra T×4, scalar_field T×1 (indexed by tet, default 1),
%   weighting scalar or 1×2 default 1. N×N sparse, symmetrized for i≠j.
%
%   See also zef_surface_scalar_matrix_FF, zef_surface_mesh.

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

[~,~,t_ind,~,~,~,~,f_ind] = zef_surface_mesh(tetra);

N = size(nodes,1);

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

[b_vec,det] = zef_volume_barycentric(nodes,tetra(t_ind,:),f_ind);
% |∇ψ_opposite| * |det|/2 = triangle area (ψ drops from 1 to 0 across height).
area = (abs(det)/2).*sqrt(sum(b_vec(:,1:3).^2,2));

M = spalloc(N,N,0);

for i = 1 : 3

    I = sub2ind(size(tetra),t_ind,ind_m(f_ind,i));

    for j = i : 3

        J = sub2ind(size(tetra),t_ind,ind_m(f_ind,j));

        if i == j
            entry_vec = area*weight_param(1);
        else
            entry_vec = area*weight_param(2);
        end
        M_part = sparse(tetra(I),tetra(J),scalar_field(t_ind).*entry_vec,N,N);

        if i == j
            M = M + M_part;
        else
            M = M + M_part;
            M = M + M_part';
        end

    end
end

end
