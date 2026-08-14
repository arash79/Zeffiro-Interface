function v = zef_surface_scalar_vector_F(nodes, tetra, scalar_field)
%ZEF_SURFACE_SCALAR_VECTOR_F  Boundary load ∫_∂Ω φ ψ_i dS with weight 1/3.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Each skin-face vertex gets φ*area/3. NSE uses this for mean-pressure
%   weights and surface integrals param_aux_integral_mean, w_2, w_3.
%
%   v = zef_surface_scalar_vector_F(nodes, tetra, scalar_field)
%
%   See also zef_surface_scalar_vector_Fn, zef_nse_poisson.

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

[~,~,t_ind,~,~,~,~,f_ind] = zef_surface_mesh(tetra);

N = size(nodes,1);

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

[~,det] = zef_volume_barycentric(nodes,tetra);
[b_vec,det] = zef_volume_barycentric(nodes,tetra(t_ind,:),f_ind);
area = (abs(det)/2).*sqrt(sum(b_vec(:,1:3).^2,2));

v = zeros(N,1);
weight_param = 1/3;

for i = 1 : 3

    I = sub2ind(size(tetra),t_ind,ind_m(f_ind,i));
    v_part = sparse(tetra(I),ones(size(I)),weight_param.*scalar_field(t_ind).*area,N,1);
    v = v + full(v_part);

end

end
