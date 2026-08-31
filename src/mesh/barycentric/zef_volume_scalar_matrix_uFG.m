function [y_1, y_2, y_3, b_coord, volume] = zef_volume_scalar_matrix_uFG(nodes, tetra, h, x_1, x_2, x_3, u_field, scalar_field, i_node_ind, b_coord, volume)
%ZEF_VOLUME_SCALAR_MATRIX_UFG  Matrix-free ∫ σ u ψ_k ψ_j (∇ψ)_h · x dV.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Applies the Navier-Stokes convection operator to the three components of
%   a nodal vector field without assembling it, which is why it takes x_1,
%   x_2, x_3 and returns y_1, y_2, y_3 rather than a matrix. h selects the
%   Cartesian component of the gradient, so the caller invokes it once per
%   direction.
%
%   The pairing weights come from zef_barycentric_weighting('uFG') and are
%   [1/10 1/20], i.e. the P1 tetrahedral mass-matrix entries V/10 on the
%   diagonal and V/20 off it. Only the products of two hat functions are
%   integrated exactly this way; the gradient factor is constant per element
%   and already carries the 1/V scaling from zef_volume_barycentric.
%
%   i_node_ind restricts the operator to a submesh: the inputs are scattered
%   into full-length node vectors, the assembly runs over all tetrahedra, and
%   the result is gathered back onto i_node_ind. Pass b_coord and volume back
%   in on later calls to skip recomputing the barycentric data.
%
%   [y_1, y_2, y_3, b_coord, volume] = zef_volume_scalar_matrix_uFG( ...
%       nodes, tetra, h, x_1, x_2, x_3, u_field, scalar_field, i_node_ind)
%   [...] = zef_volume_scalar_matrix_uFG(..., i_node_ind, b_coord, volume)
%
%   Restored from upstream m/barycentric/. It was dropped during the
%   reorganization even though zef_barycentric_weighting kept its 'uFG' case,
%   which left its only caller, zef_nse_iteration, referring to a kernel that
%   did not exist. Note that caller has never been reachable in either tree
%   (see the note in zef_nse_iteration), so this routine's behaviour inside a
%   full NSE run is untested; tests.unit.VolumeScalarMatrixUFGTest checks the
%   assembly itself against a direct reference.
%
%   See also zef_barycentric_weighting, zef_volume_barycentric,
%   zef_volume_scalar_matrix_FG, zef_nse_iteration.

if nargin < 10
    b_coord = zeros(size(tetra,1),size(tetra,2),4);
    [b_coord(:,:,1),det] = zef_volume_barycentric(nodes,tetra,1);
    for i = 2 : 4
        [b_coord(:,:,i)] = zef_volume_barycentric(nodes,tetra,i,det);
    end
    volume = abs(det)/6;
end

if nargin >= 9
    if not(isempty(i_node_ind))
        x_1_aux = zeros(size(nodes,1),1);
        x_2_aux = zeros(size(nodes,1),1);
        x_3_aux = zeros(size(nodes,1),1);
        u_field_aux = zeros(size(nodes,1),1);

        if isgpuarray(x_1)
            x_1_aux = gpuArray(x_1_aux);
            x_2_aux = gpuArray(x_2_aux);
            x_3_aux = gpuArray(x_3_aux);
            u_field_aux = gpuArray(u_field_aux);
        end

        x_1_aux(i_node_ind) = x_1;
        x_2_aux(i_node_ind) = x_2;
        x_3_aux(i_node_ind) = x_3;
        u_field_aux(i_node_ind) = u_field;

        x_1 = x_1_aux;
        x_2 = x_2_aux;
        x_3 = x_3_aux;
        u_field = u_field_aux;

    end
end

weight_param = zef_barycentric_weighting('uFG');
y_1 = zeros(size(nodes,1),1);
y_2 = zeros(size(nodes,1),1);
y_3 = zeros(size(nodes,1),1);

for i = 1 : 4
    for j = 1 : 4
        for k = 1 : 4
            if i == k
                aux_vec = weight_param(1).*u_field(tetra(:,k)).*b_coord(:,h,j).*scalar_field.*volume;
                entry_vec_1 = x_1(tetra(:,j)).*aux_vec;
                entry_vec_2 = x_2(tetra(:,j)).*aux_vec;
                entry_vec_3 = x_3(tetra(:,j)).*aux_vec;
            else
                aux_vec = weight_param(2).*u_field(tetra(:,k)).*b_coord(:,h,j).*scalar_field.*volume;
                entry_vec_1 = x_1(tetra(:,j)).*aux_vec;
                entry_vec_2 = x_2(tetra(:,j)).*aux_vec;
                entry_vec_3 = x_3(tetra(:,j)).*aux_vec;
            end

            y_1 = y_1 + accumarray(tetra(:,i),entry_vec_1,size(y_1));
            y_2 = y_2 + accumarray(tetra(:,i),entry_vec_2,size(y_2));
            y_3 = y_3 + accumarray(tetra(:,i),entry_vec_3,size(y_3));

        end
    end
end

if nargin >= 9

    if not(isempty(i_node_ind))
        y_1 = y_1(i_node_ind);
        y_2 = y_2(i_node_ind);
        y_3 = y_3(i_node_ind);
    end

end

end
