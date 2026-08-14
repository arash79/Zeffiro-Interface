function A = zef_stiffness_matrix(nodes, tetrahedra, volume, tensor)
%ZEF_STIFFNESS_MATRIX  Sparse N×N P1 stiffness A_ij = ∫ ∇ψ_i · (σ ∇ψ_j) dV.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   EEG/MEG/EIT/TES lead fields call this after zef_tetra_volume(..., true).
%   zef_volume_gradient returns the signed *area vector* of the face
%   opposite local vertex i (½ e1×e2, oriented toward that vertex), not
%   ∇ψ_i. For linear hats, ∇ψ_i = area_i / (3V), so
%
%       ∫ ∇ψ_i · (σ ∇ψ_j) dV = (area_i · σ area_j) / (9V)
%
%   because the two missing 3V factors give 9V² and the remaining V is the
%   integration measure. That is why every entry is divided by (9*volume).
%   Contrast zef_tetra_gradient_field, which *does* divide by volume and is
%   used by TES for σ∇u, not by this matrix.
%
%   A = zef_stiffness_matrix(nodes, tetrahedra, volume, tensor)
%
%   Inputs
%     nodes       - N×3 (metres on the lead-field path).
%     tetrahedra  - T×4 1-based indices.
%     volume      - 1×T (or T×1) tet volumes from zef_tetra_volume. Must
%                   match the length unit of nodes.
%     tensor      - 6×T packed symmetric conductivity per tet:
%                   row 1 σ_xx, 2 σ_yy, 3 σ_zz, 4 σ_xy, 5 σ_xz, 6 σ_yz.
%                   Isotropic tissue repeats the scalar on rows 1–3 and
%                   leaves 4–6 zero. Off-diagonal rows add both
%                   g_i(a)g_j(b) and g_i(b)g_j(a) (the missing transpose
%                   of σ).
%
%   Output
%     A  - N×N sparse, symmetric. Assembly: for local vertices i ≤ j,
%          sparse(tetrahedra(:,i), tetrahedra(:,j), entry_vec', N, N);
%          off-diagonals add A_part + A_part'.
%
%   Side effects: waitbar, closed by onCleanup.
%
%   See also zef_volume_gradient, zef_tetra_volume, zef_build_electrodes,
%            zef_lead_field_eeg_fem.

wb = zef_waitbar(0,1,'Stiffness matrix.');

% Automatic closing of waitbar.

fn = @(h) close(h);

cuo = onCleanup(@() fn(wb));

wbi = 0;

N = size(nodes,1);

A = spalloc(N,N,0);

n_of_tetra_faces = 4;

% Start constructing the elements of 𝐴 iteratively. Summing the integrands
% ∇ψⱼ ⋅ (𝑇∇ψᵢ) multiplied by volume elements d𝑉 like this corresponds to
% integration.

for i = 1 : n_of_tetra_faces

    grad_1 = zef_volume_gradient(nodes, tetrahedra, i);

    for j = i : n_of_tetra_faces

        if i == j
            grad_2 = grad_1;
        else
            grad_2 = zef_volume_gradient(nodes, tetrahedra, j);
        end

        % Preallocate integrand vector

        entry_vec = zeros(1,size(tetrahedra,1));

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

            % Calculate the integrand times a volume element ∇ψⱼ⋅(σ∇ψᵢ) d𝑉

            if k <= 3
                % Diagonal σ_aa: area_i(a) * σ_aa * area_j(a) / (9V).
                entry_vec =         ...
                    entry_vec       ...
                    +               ...
                    tensor(k,:)     ...
                    .*              ...
                    grad_1(k_1,:)   ...
                    .*              ...
                    grad_2(k_2,:)   ...
                    ./              ...
                    (9 * volume);
            else
                % Off-diagonal σ_ab: both area_i(a)area_j(b) and area_i(b)area_j(a).
                entry_vec =             ...
                    entry_vec           ...
                    +                   ...
                    tensor(k,:)         ...
                    .*                  ...
                    (                   ...
                    grad_1(k_1,:)   ...
                    .*              ...
                    grad_2(k_2,:)   ...
                    +               ...
                    grad_1(k_2,:)   ...
                    .*              ...
                    grad_2(k_1,:)   ...
                    )                   ...
                    ./                  ...
                    (9 * volume);
            end
        end

        % Construct a part of 𝐴 by mapping the indices of the tetrahedra to
        % the integrand (a sparse matrix is a hash table).

        A_part = sparse(tetrahedra(:,i),tetrahedra(:,j), entry_vec',N,N);

        % Sum the integrand to 𝐴 iteratively. This corresponds to integration.

        if i == j

            % On the diagonal, no need to do anthing special

            A = A + A_part;

        else

            % Stiffness matrices are symmetric, so what is added to the
            % lower triangle must be added to the upper one. Hence the
            % added transpose.

            A = A + A_part + A_part';

        end
    end

    wbi = wbi + 1;
    zef_waitbar(wbi , n_of_tetra_faces, wb);

end

zef_waitbar(1,1,wb);

end
