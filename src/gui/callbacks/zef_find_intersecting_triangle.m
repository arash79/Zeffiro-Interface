function [tri_ind, lambda_1, lambda_2, lambda_3] = zef_find_intersecting_triangle(p_1, p_2,sign_val,tri_ref,nodes_tri_ref,varargin)
%ZEF_FIND_INTERSECTING_TRIANGLE  First triangle hit by a directed segment.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Caller: zef_fix_negatives (walk inverted-tet
%   nodes along rays until they sit inside the surface). Pure geometry;
%   no zef.
%
%   [tri_ind, lambda_1, lambda_2, lambda_3] = ...
%       zef_find_intersecting_triangle(p_1, p_2, sign_val, tri_ref, nodes_tri_ref)
%   [tri_ind, lambda_1, lambda_2, lambda_3] = ...
%       zef_find_intersecting_triangle(..., search_type)
%
%   Inputs
%     p_1, p_2       - 1×3 segment ends (direction p_2-p_1).
%     sign_val       - +1 or −1; keeps hits with sign_val*sign(n·dir) ≥ 0.
%     tri_ref        - F×3 triangle node indices.
%     nodes_tri_ref  - N×3 nodes.
%     search_type    - 'convex' (default) or 'nonconvex'.
%
%   Outputs
%     tri_ind            - row of tri_ref, or [] if none.
%     lambda_1,2,3       - barycentric from zef_3by3_solver on that hit.
%                          Closest hit is min abs(lambda_1) among candidates.
%
%   convex: also requires lambda_1 in (−1,0) and lambda_2,3 in (0,1).
%   nonconvex: only lambda_2,3 in (0,1) (used by zef_fix_negatives).
%
%   See also zef_fix_negatives, zef_3by3_solver.

search_type = 'convex';

if not(isempty(varargin))
    search_type = varargin{1};
end

tri_ind = [];
lambda_1 = [];
lambda_2 = [];
lambda_3 = [];

vec_1_aux = p_2 - p_1;
ones_vec_tri = ones(size(tri_ref,1),1);
vec_1 = vec_1_aux(ones_vec_tri,:);
d_vec = p_1(ones_vec_tri,:)  - nodes_tri_ref(tri_ref(:,1),:);
vec_2 = nodes_tri_ref(tri_ref(:,2),:) - nodes_tri_ref(tri_ref(:,1),:);
vec_3 = nodes_tri_ref(tri_ref(:,3),:) - nodes_tri_ref(tri_ref(:,1),:);

sign_vec = sign(dot(cross(vec_2',vec_3'),vec_1'));

[lambda_1, lambda_2, lambda_3] = zef_3by3_solver(vec_1, vec_2, vec_3, d_vec);
if isequal(search_type,'convex')
    I = find(sign_val*sign_vec(:) >= 0 &lambda_1<0 & lambda_1 > -1 & lambda_2 >0 & lambda_2<1 & lambda_3>0 & lambda_3 <1);
elseif isequal(search_type,'nonconvex')
    I = find(sign_val*sign_vec(:) >= 0  & lambda_2 >0 & lambda_2<1 & lambda_3>0 & lambda_3 <1);
end

if not(isempty(I))
    [~, min_ind] = min(abs(lambda_1(I)));

    tri_ind = I(min_ind);
    lambda_1 = lambda_1(tri_ind);
    lambda_2 = lambda_2(tri_ind);
    lambda_3 = lambda_3(tri_ind);

else
    tri_ind = [];
    lambda_1 = [];
    lambda_2 = [];
    lambda_3 = [];

end

end
