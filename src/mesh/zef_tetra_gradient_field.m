function [G1, G2, G3] = zef_tetra_gradient_field(nodes, tetrahedra, volume, tensor, eval_point_inds, K, N)
%ZEF_TETRA_GRADIENT_FIELD  Sparse maps from nodal scalars to σ∇u at tetra centroids.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For a P1 potential u interpolating nodal values, this builds three
%   K-by-N sparse matrices such that G1*u, G2*u, G3*u are the Cartesian
%   components of σ∇u evaluated at the centroids of selected tetrahedra.
%
%   Unlike zef_volume_gradient (used by the stiffness matrix), the face
%   cross product is scaled by 1/6 and then divided by tetrahedron volume.
%   That combination is the true linear hat-function gradient
%   |∇ψ| = A/(3V): ||cross(e1,e2)||/6 = A/3, then /V yields A/(3V).
%
%   The conductivity tensor is the same 6-component packed layout used by
%   zef_stiffness_matrix: rows 1–3 are σ_xx, σ_yy, σ_zz; rows 4–6 are the
%   symmetric off-diagonals σ_xy, σ_xz, σ_yz. Off-diagonal terms are added
%   in both index orders so that (σ∇u)_i = σ_ij (∇u)_j.
%
%   Primary caller: src/forward/lead_field/zef_lead_field_tes_fem.m, which
%   evaluates the current density in source (brain) tetrahedra after the
%   TES transfer matrix has been solved. EEG/MEG stiffness assembly does
%   not use this function.
%
%   [G1, G2, G3] = zef_tetra_gradient_field(nodes, tetrahedra, volume, tensor, eval_point_inds, K, N)
%
%   Inputs
%     nodes            - N-by-3 vertex coordinates.
%     tetrahedra       - T-by-4 1-based node indices.
%     volume           - T-by-1 signed tetra volumes (same unit^3 as nodes).
%     tensor           - 6-by-T packed conductivity. Columns not listed in
%                        eval_point_inds are unused.
%     eval_point_inds  - K-vector of tetra rows to evaluate (e.g. brain_ind).
%     K                - number of evaluation tets; must equal numel(eval_point_inds).
%     N                - number of mesh nodes; must equal size(nodes,1).
%
%   Outputs
%     G1, G2, G3       - K-by-N sparse matrices. Row k is σ∇ψ at tetra
%                        eval_point_inds(k); column n is the contribution
%                        of nodal degree of freedom n.
%
%   See also zef_volume_gradient, zef_stiffness_matrix, zef_lead_field_tes_fem.

G1 = spalloc(K,N,0);
G2 = spalloc(K,N,0);
G3 = spalloc(K,N,0);

% Face opposite local vertex i (same stencil as zef_volume_gradient).
ind_m = [ 2 3 4 ;
    3 4 1 ;
    4 1 2 ;
    1 2 3 ];

for i = 1 : 4

    % True ∇ψ_i: area/3 then /volume, with sign toward local vertex i.
    grad = cross(nodes(tetrahedra(eval_point_inds,ind_m(i,2)),:)'-nodes(tetrahedra(eval_point_inds,ind_m(i,1)),:)', nodes(tetrahedra(eval_point_inds,ind_m(i,3)),:)'-nodes(tetrahedra(eval_point_inds,ind_m(i,1)),:)')/6;
    grad = repmat(sign(dot(grad,(nodes(tetrahedra(eval_point_inds,i),:)'-nodes(tetrahedra(eval_point_inds,ind_m(i,1)),:)'))),3,1).*grad;
    grad = grad ./ volume(eval_point_inds);

    entry_vec_1 = zeros(1,size(eval_point_inds,1));
    entry_vec_2 = zeros(1,size(eval_point_inds,1));
    entry_vec_3 = zeros(1,size(eval_point_inds,1));

    % Pack σ∇ψ into Cartesian components using the 6-row tensor layout.
    for k = 1 : 6

        switch k
            case 1
                k_1 = 1;
                k_2 = 1;
            case 2
                k_1 = 2;
                k_2 = 2;
            case 3
                k_1 = 3;
                k_2 = 3;
            case 4
                k_1 = 1;
                k_2 = 2;
            case 5
                k_1 = 1;
                k_2 = 3;
            case 6
                k_1 = 2;
                k_2 = 3;
        end

        if k <= 3

            % Diagonal σ_xx, σ_yy, σ_zz: contribute only to that component.
            switch k_1
                case 1
                    entry_vec_1 = entry_vec_1 + tensor(k,eval_point_inds).*grad(k_2,:);
                case 2
                    entry_vec_2 = entry_vec_2 + tensor(k,eval_point_inds).*grad(k_2,:);
                case 3
                    entry_vec_3 = entry_vec_3 + tensor(k,eval_point_inds).*grad(k_2,:);
            end

        else

            % Off-diagonal σ_xy, σ_xz, σ_yz: add both (i,j) and (j,i).
            switch k_1
                case 1
                    entry_vec_1 = entry_vec_1 + tensor(k,eval_point_inds).*grad(k_2,:);
                case 2
                    entry_vec_2 = entry_vec_2 + tensor(k,eval_point_inds).*grad(k_2,:);
                case 3
                    entry_vec_3 = entry_vec_3 + tensor(k,eval_point_inds).*grad(k_2,:);
            end

            switch k_2
                case 1
                    entry_vec_1 = entry_vec_1 + tensor(k,eval_point_inds).*grad(k_1,:);
                case 2
                    entry_vec_2 = entry_vec_2 + tensor(k,eval_point_inds).*grad(k_1,:);
                case 3
                    entry_vec_3 = entry_vec_3 + tensor(k,eval_point_inds).*grad(k_1,:);
            end

        end
    end

    % Scatter this local vertex's contribution into global nodal columns.
    G1 = G1 + sparse([1:K]',tetrahedra(eval_point_inds,i), entry_vec_1,K,N);
    G2 = G2 + sparse([1:K]',tetrahedra(eval_point_inds,i), entry_vec_2,K,N);
    G3 = G3 + sparse([1:K]',tetrahedra(eval_point_inds,i), entry_vec_3,K,N);

end
end
