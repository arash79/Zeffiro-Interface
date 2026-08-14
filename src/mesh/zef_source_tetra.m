function [t_ind, coeff, f_ind] = zef_source_tetra(source_positions, tetra, nodes, K)
%ZEF_SOURCE_TETRA  Barycentric locate of points in a tetrahedral mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each source xyz, knnsearch's K nearest tet centroids, then solves
%   (v2-v1, v3-v1, v4-v1) λ = p-v1 with zef_3by3_solver. The first neighbour
%   with λ in [0,1]^3 is kept (f_ind=1). If none hit, the nearest centroid's
%   tet is stored but coeff may be empty because aux_val is empty.
%
%   No first-party caller in this tree; source interpolation uses other
%   helpers (zef_source_interpolation, zef_decompose_dof_space).
%
%   [t_ind, coeff, f_ind] = zef_source_tetra(source_positions, tetra, nodes)
%   [t_ind, coeff, f_ind] = zef_source_tetra(source_positions, tetra, nodes, K)
%
%   Inputs
%     source_positions - P×3 query points, same frame/unit as nodes.
%     tetra            - T×4 1-based indices.
%     nodes            - N×3.
%     K                - number of centroid neighbours, default 25.
%
%   Outputs
%     t_ind  - P×1 tet index (1-based into tetra).
%     coeff  - P×3 barycentric (λ2,λ3,λ4) relative to vertex 1. λ1 = 1-sum.
%     f_ind  - P×1, 1 if a neighbour contained the point, else 0.
%
%   See also zef_3by3_solver, zef_tetra_barycentra.

if nargin < 4
    K = 25;
end

h_waitbar = zef_waitbar(0, 'Finding nearest tetrahedra');

n_points = size(source_positions,1);
t_ind = zeros(n_points,1);
coeff = zeros(n_points,3);
f_ind = zeros(n_points,1);

v_1 = nodes(tetra(:,1),:);
v_2 = nodes(tetra(:,2),:);
v_3 = nodes(tetra(:,3),:);
v_4 = nodes(tetra(:,4),:);

t_c_p = 0.25 * (v_1 + v_2 + v_3 + v_4);

% Edge matrix from vertex 1 (same layout zef_3by3_solver expects).
v_2 = v_2 - v_1;
v_3 = v_3 - v_1;
v_4 = v_4 - v_1; 

s_ind = knnsearch(t_c_p,source_positions,'K',K);

s_aux = source_positions(ones(K,1),:) - v_1(s_ind(1,:),:);

[x, y, z] = zef_3by3_solver(v_2(s_ind(1,:),:),v_3(s_ind(1,:),:),v_4(s_ind(1,:),:),s_aux);

aux_val = find(x>=0 & x<=1 & y>=0 & y<=1 & z>=0 & z<=1, 1, 'first');

if not(isempty(aux_val))
    t_ind(1) = s_ind(1,aux_val);
    f_ind(1) = 1;
else
t_ind(1) = s_ind(1,1);
end

if t_ind(1) > 0 
coeff(1,1) = x(aux_val);
coeff(1,2) = y(aux_val);
coeff(1,3) = z(aux_val);
end

if n_points == 1
    zef_waitbar(1, h_waitbar, 'Finding nearest tetrahedra');
end

for i = 2 : n_points

s_aux = source_positions(i*ones(K,1),:) - v_1(s_ind(i,:),:);

if mod(i,ceil(n_points/20))==0
zef_waitbar(i/n_points, h_waitbar, 'Finding nearest tetrahedra');
end

[x, y, z] = zef_3by3_solver(v_2(s_ind(i,:),:),v_3(s_ind(i,:),:),v_4(s_ind(i,:),:),s_aux);

aux_val = find(x>=0 & x<=1 & y>=0 & y<=1 & z>=0 & z<=1, 1,'first');

if not(isempty(aux_val))
    t_ind(i) = s_ind(i,aux_val);
    f_ind(i) = 1;
else
t_ind(i) = s_ind(i,1);
end

if t_ind(i) > 0 
coeff(i,1) = x(aux_val);
coeff(i,2) = y(aux_val);
coeff(i,3) = z(aux_val);
end

end

% Properly delete waitbar by clearing DeleteFcn first
if ~isempty(h_waitbar) && isvalid(h_waitbar)
    set(h_waitbar, 'DeleteFcn', '');
    delete(h_waitbar);
end

end
