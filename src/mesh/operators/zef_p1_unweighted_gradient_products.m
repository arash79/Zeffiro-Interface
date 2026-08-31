function D_A = zef_p1_unweighted_gradient_products(nodes, tetrahedra, brain_ind)
%ZEF_P1_UNWEIGHTED_GRADIENT_PRODUCTS  Packed ∫ ∇ψ_i·∇ψ_j dV on brain tets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   P1 hats satisfy ∇ψ_i = a_i / (3V) with a_i the signed face-area vector
%   from zef_volume_gradient, so
%
%       ∫ ∇ψ_i · ∇ψ_j dV = (a_i · a_j) / (9V).
%
%   Only the three diagonal Cartesian products enter that inner product.
%   Off-diagonal conductivity terms belong in the stiffness, not here.
%
%   D_A is K×10, K = numel(brain_ind). Columns follow the upper-triangle
%   order of the EIT Jacobian (i=1:4, j=i:4):
%   (1,1)(1,2)(1,3)(1,4)(2,2)(2,3)(2,4)(3,3)(3,4)(4,4).
%
%   D_A = zef_p1_unweighted_gradient_products(nodes, tetrahedra, brain_ind)
%
%   See also zef_lead_field_eit_fem, zef_stiffness_matrix.

K = numel(brain_ind);
D_A = zeros(K, 10);

Aux_mat = [nodes(tetrahedra(:, 1), :)'; nodes(tetrahedra(:, 2), :)'; ...
    nodes(tetrahedra(:, 3), :)'] - repmat(nodes(tetrahedra(:, 4), :)', 3, 1);
ind_vol = [1 4 7; 2 5 8; 3 6 9];
tilavuus = abs(Aux_mat(ind_vol(1, 1), :) .* (Aux_mat(ind_vol(2, 2), :) .* Aux_mat(ind_vol(3, 3), :) ...
    - Aux_mat(ind_vol(2, 3), :) .* Aux_mat(ind_vol(3, 2), :)) ...
    - Aux_mat(ind_vol(1, 2), :) .* (Aux_mat(ind_vol(2, 1), :) .* Aux_mat(ind_vol(3, 3), :) ...
    - Aux_mat(ind_vol(2, 3), :) .* Aux_mat(ind_vol(3, 1), :)) ...
    + Aux_mat(ind_vol(1, 3), :) .* (Aux_mat(ind_vol(2, 1), :) .* Aux_mat(ind_vol(3, 2), :) ...
    - Aux_mat(ind_vol(2, 2), :) .* Aux_mat(ind_vol(3, 1), :))) / 6;

ind_m = [2 3 4; 3 4 1; 4 1 2; 1 2 3];
D_A_count = 0;
for i = 1:4
    grad_1 = cross(nodes(tetrahedra(:, ind_m(i, 2)), :)' - nodes(tetrahedra(:, ind_m(i, 1)), :)', ...
        nodes(tetrahedra(:, ind_m(i, 3)), :)' - nodes(tetrahedra(:, ind_m(i, 1)), :)') / 2;
    grad_1 = repmat(sign(dot(grad_1, (nodes(tetrahedra(:, i), :)' - nodes(tetrahedra(:, ind_m(i, 1)), :)'))), 3, 1) .* grad_1;
    for j = i:4
        D_A_count = D_A_count + 1;
        if i == j
            grad_2 = grad_1;
        else
            grad_2 = cross(nodes(tetrahedra(:, ind_m(j, 2)), :)' - nodes(tetrahedra(:, ind_m(j, 1)), :)', ...
                nodes(tetrahedra(:, ind_m(j, 3)), :)' - nodes(tetrahedra(:, ind_m(j, 1)), :)') / 2;
            grad_2 = repmat(sign(dot(grad_2, (nodes(tetrahedra(:, j), :)' - nodes(tetrahedra(:, ind_m(j, 1)), :)'))), 3, 1) .* grad_2;
        end
        entry_vec_2 = (grad_1(1, :) .* grad_2(1, :) + grad_1(2, :) .* grad_2(2, :) ...
            + grad_1(3, :) .* grad_2(3, :)) ./ (9 * tilavuus);
        D_A(:, D_A_count) = entry_vec_2(brain_ind)';
    end
end

end
