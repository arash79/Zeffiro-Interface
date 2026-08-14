function [b_coord, det] = zef_volume_barycentric(nodes,tetra,p_ind,det)
%ZEF_VOLUME_BARYCENTRIC  Affine hats ψ and ∇ψ on linear tetrahedra.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each tet, ψ_k(x) = b·[x y z 1] with ψ_k=1 at local vertex k.
%   Columns 1:3 of b_coord are ∇ψ_k (constant on the tet); column 4 is
%   the constant term. det is the scalar triple product of (v1-v4, v2-v4,
%   v3-v4), so volume = abs(det)/6 (same as zef_tetra_volume).
%
%   Primary consumers: barycentric volume/surface assemblers in this
%   folder, and src/forward/nse (zef_nse_poisson*). Also zef_3by3_solver
%   is the batched Cramer kernel.
%
%   [b_coord, det] = zef_volume_barycentric(nodes, tetra)
%   [b_coord, det] = zef_volume_barycentric(nodes, tetra, p_ind)
%   [b_coord, det] = zef_volume_barycentric(nodes, tetra, p_ind, det)
%
%   Inputs
%     nodes  - N×3.
%     tetra  - T×4 1-based indices.
%     p_ind  - omitted: only det is computed (b_coord=[]).
%              scalar 1..4: hat of that local vertex on every tet.
%              T×1: hat of local vertex p_ind(t) on tet t. Rows with
%              p_ind==4 are solved in a rotated vertex order because the
%              3×3 uses vertices 1:3 relative to vertex 4.
%     det    - optional T×1 from a previous call (avoids recomputing D).
%
%   Outputs
%     b_coord - T×4, or [] when nargin==2.
%     det     - T×1 signed 6V. When p_ind mixes 4 and not-4, det is
%               stitched from the two batches only if both computed D.
%
%   See also zef_3by3_solver, zef_volume_scalar_matrix_D, zef_tetra_volume.

b_coord = [];
det_1 = [];
det_2 = [];
I = [1 2 3 4];

if nargin == 2
    p_ind = [];
    [~,~,~,det] = zef_3by3_solver(reshape(nodes(tetra(:,I(1:3)),1)-nodes(tetra(:,I([4 4 4])),1),size(tetra,1),3),...
        reshape(nodes(tetra(:,I(1:3)),2)-nodes(tetra(:,I([4 4 4])),2),size(tetra,1),3),...
        reshape(nodes(tetra(:,I(1:3)),3)-nodes(tetra(:,I([4 4 4])),3),size(tetra,1),3));
else

    if nargin > 2


        if nargin < 4
            det = [];
        end

        if isequal(length(p_ind),1)
            p_val = zeros(size(tetra));
            J_2 = [];
            p_val(:,p_ind) = 1;
            if isequal(p_ind,4)
                % Vertex 4 is the origin of the 3×3; cycle so it is last.
                I = [4 1 2 3];
            end
        else
            p_val = zeros(size(tetra));
            p_ind = p_ind(:);
            J_2 = find(p_ind == 4);
            J_1 = setdiff([1:size(tetra,1)]',J_2);
            p_ind_aux = sub2ind(size(tetra),[1:size(tetra,1)]',p_ind);
            p_val(p_ind_aux) = 1;
        end

    end

    if isempty(J_2)

        if isempty(det)
            [x,y,z,det] = zef_3by3_solver(reshape(nodes(tetra(:,I(1:3)),1)-nodes(tetra(:,I([4 4 4])),1),size(tetra,1),3),...
                reshape(nodes(tetra(:,I(1:3)),2)-nodes(tetra(:,I([4 4 4])),2),size(tetra,1),3),...
                reshape(nodes(tetra(:,I(1:3)),3)-nodes(tetra(:,I([4 4 4])),3),size(tetra,1),3),...
                p_val(:,I(1:3)));
        else
            [x,y,z] = zef_3by3_solver(reshape(nodes(tetra(:,I(1:3)),1)-nodes(tetra(:,I([4 4 4])),1),size(tetra,1),3),...
                reshape(nodes(tetra(:,I(1:3)),2)-nodes(tetra(:,I([4 4 4])),2),size(tetra,1),3),...
                reshape(nodes(tetra(:,I(1:3)),3)-nodes(tetra(:,I([4 4 4])),3),size(tetra,1),3),...
                p_val(:,I(1:3)),det);
        end

        % [∇ψ_x ∇ψ_y ∇ψ_z, ψ(0)-∇ψ·v_origin] so ψ(x)= b·[x y z 1].
        b_coord = [x y z p_val(:,I(4))-x.*nodes(tetra(:,I(4)),1)-y.*nodes(tetra(:,I(4)),2)-z.*nodes(tetra(:,I(4)),3)];


    else

        if isempty(det)
            [x,y,z,det_1] = zef_3by3_solver(reshape(nodes(tetra(J_1,I(1:3)),1)-nodes(tetra(J_1,I([4 4 4])),1),length(J_1),3),...
                reshape(nodes(tetra(J_1,I(1:3)),2)-nodes(tetra(J_1,I([4 4 4])),2),length(J_1),3),...
                reshape(nodes(tetra(J_1,I(1:3)),3)-nodes(tetra(J_1,I([4 4 4])),3),length(J_1),3),...
                p_val(J_1,I(1:3)));
        else
            [x,y,z] = zef_3by3_solver(reshape(nodes(tetra(J_1,I(1:3)),1)-nodes(tetra(J_1,I([4 4 4])),1),length(J_1),3),...
                reshape(nodes(tetra(J_1,I(1:3)),2)-nodes(tetra(J_1,I([4 4 4])),2),length(J_1),3),...
                reshape(nodes(tetra(J_1,I(1:3)),3)-nodes(tetra(J_1,I([4 4 4])),3),length(J_1),3),...
                p_val(J_1,I(1:3)),det(J_1));
        end

        b_coord = zeros(size(tetra));
        b_coord(J_1,:) = [x y z p_val(J_1,I(4))-x.*nodes(tetra(J_1,I(4)),1)-y.*nodes(tetra(J_1,I(4)),2)-z.*nodes(tetra(J_1,I(4)),3)];

        I = [4 1 2 3];

        if isempty(det)
            [x,y,z,det_2] = zef_3by3_solver(reshape(nodes(tetra(J_2,I(1:3)),1)-nodes(tetra(J_2,I([4 4 4])),1),length(J_2),3),...
                reshape(nodes(tetra(J_2,I(1:3)),2)-nodes(tetra(J_2,I([4 4 4])),2),length(J_2),3),...
                reshape(nodes(tetra(J_2,I(1:3)),3)-nodes(tetra(J_2,I([4 4 4])),3),length(J_2),3),...
                p_val(J_2,I(1:3)));
        else

            [x,y,z] = zef_3by3_solver(reshape(nodes(tetra(J_2,I(1:3)),1)-nodes(tetra(J_2,I([4 4 4])),1),length(J_2),3),...
                reshape(nodes(tetra(J_2,I(1:3)),2)-nodes(tetra(J_2,I([4 4 4])),2),length(J_2),3),...
                reshape(nodes(tetra(J_2,I(1:3)),3)-nodes(tetra(J_2,I([4 4 4])),3),length(J_2),3),...
                p_val(J_2,I(1:3)),det(J_2));
        end

        b_coord(J_2,:) = [x y z p_val(J_2,I(4))-x.*nodes(tetra(J_2,I(4)),1)-y.*nodes(tetra(J_2,I(4)),2)-z.*nodes(tetra(J_2,I(4)),3)];

        if and(not(isempty(det_1)),not(isempty(det_2)))
            det = zeros(size(tetra,1),1);
            det(J_1) = det_1;
            det(J_2) = det_2;
        end

    end

end
end
