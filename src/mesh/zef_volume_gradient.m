function gradients = zef_volume_gradient(nodes, tetrahedra, node_index)
%ZEF_VOLUME_GRADIENT  Signed face-area vectors for one P1 hat function per tetra.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Linear tetrahedral FEM uses hat functions ψ_i that are 1 at vertex i
%   and 0 at the other three vertices. The true element gradient is
%   constant and equals the area vector of the opposite face divided by
%   3V. This function returns the signed area vector itself
%   (½ × edge1 × edge2), oriented toward vertex node_index, and does
%   not divide by volume.
%
%   zef_stiffness_matrix consumes these vectors and divides the product
%   ∇̂ψ_i · (σ ∇̂ψ_j) by 9V, which restores ∫ ∇ψ_i · (σ ∇ψ_j) dV because
%   each missing factor of 3V appears twice (3×3) while the remaining V
%   is the integration measure. Do not treat the output as a physical
%   gradient without that conversion.
%
%   Contrast with zef_tetra_gradient_field, which does divide by volume
%   (using a 1/6 cross product) and therefore returns true ∇ψ at tetra
%   centroids. That operator is used by TES lead-field assembly, not by
%   the stiffness matrix.
%
%   gradients = zef_volume_gradient(nodes, tetrahedra, node_index)
%
%   Inputs
%     nodes       - N-by-3 vertex coordinates (same unit as the mesh,
%                   typically millimetres).
%     tetrahedra  - T-by-4 1-based indices into nodes.
%     node_index  - local vertex 1, 2, 3, or 4. Selects which hat
%                   function is differentiated on every tetrahedron.
%
%   Output
%     gradients   - 3-by-T area vectors. Column t belongs to tetrahedra(t,:).
%                   Orientation points toward the selected vertex.
%
%   See also zef_stiffness_matrix, zef_tetra_gradient_field, zef_tetra_volume.

% Local vertex triples: row i is the face opposite local vertex i.
ind_m = [
    2 3 4 ;
    3 4 1 ;
    4 1 2 ;
    1 2 3
    ];

% Half the cross product of two face edges is the triangle area vector
% (magnitude = face area, direction = unoriented normal).
normals = 1/2 * cross(                          ...
    nodes(tetrahedra(:,ind_m(node_index,2)),:)' ...
    -                                           ...
    nodes(tetrahedra(:,ind_m(node_index,1)),:)' ...
    ,                                               ...
    nodes(tetrahedra(:,ind_m(node_index,3)),:)' ...
    -                                           ...
    nodes(tetrahedra(:,ind_m(node_index,1)),:)' ...
    );

% Flip any area vector that points away from the selected vertex so that
% the result has the same orientation as ∇ψ (increasing toward that vertex).
fixed_nodes = nodes(tetrahedra(:,node_index),:)';
other_nodes = nodes(tetrahedra(:,ind_m(node_index,1)),:)';
direction_vectors = fixed_nodes - other_nodes;

gradients = normals .* repmat(  ...
    sign(                       ...
    dot(                    ...
    normals             ...
    ,                       ...
    direction_vectors   ...
    )                       ...
    )                           ...
    ,                               ...
    3, 1                        ...
    );

end
