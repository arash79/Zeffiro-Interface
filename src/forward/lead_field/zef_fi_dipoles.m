function [stensil, signs, source_moments, source_directions, source_locations, n_of_adj_tetra] = zef_fi_dipoles( ...
    nodes      ...
    ,              ...
    tetrahedra ...
    ,              ...
    brain_ind  ...
    )
%ZEF_FI_DIPOLES  Face-interior dipole stencils for H(div) sources.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds pairs of brain tetrahedra that share a face. Each pair defines a
%   face-interior dipole: location at the midpoint of the two opposite
%   vertices, direction along that segment, moment equal to the segment
%   length. Interior occupancy (four brain-face neighbours) is computed
%   separately in zef_lead_field_matrix without building G_fi.
%
%   [stensil, signs, source_moments, source_directions, source_locations, n_of_adj_tetra] = ...
%       zef_fi_dipoles(nodes, tetrahedra, brain_ind)
%
%   Input
%     nodes       - [n_nodes × 3]
%     tetrahedra  - [n_tet × 4]
%     brain_ind   - tetra indices treated as source-capable
%
%   Output
%     stensil            - sparse [n_pairs × n_tet], ones on the two tets of each pair
%     signs              - sparse [n_nodes × n_pairs], ±1/moment at the two vertices
%     source_moments     - [n_pairs × 1] edge lengths
%     source_directions  - [n_pairs × 3] unit vectors
%     source_locations   - [n_pairs × 3] midpoints
%     n_of_adj_tetra     - n_pairs
%
%   See also zef_fi_shared_faces, zef_ew_dipoles, zef_lead_field_matrix.


% Matrix sizes

n_of_nodes = size(nodes, 1);
n_of_tetra = size(tetrahedra, 1);

% Shared faces among brain tetrahedra: one unique-key pass over all 4
% faces per tet, then pair the two incidences of each interior face.
% Equivalent to the previous 6 sortrows of opposite-face combinations;
% neighbour tet sets and opposite-vertex node pairs are the same.

% Shared faces among brain tetrahedra. Faces with one incidence are
% brain-boundary; more than two incidences are non-manifold and skipped.
sorted_tetra_faces = zef_fi_shared_faces(tetrahedra, brain_ind);

% Set node pairs that share a face.

tetra_end_1_ind = sub2ind(size(tetrahedra), sorted_tetra_faces(:,1), sorted_tetra_faces(:,3));
tetra_end_1 = nodes(tetrahedra(tetra_end_1_ind),:);

tetra_end_2_ind = sub2ind(size(tetrahedra), sorted_tetra_faces(:,2), sorted_tetra_faces(:,4));
tetra_end_2 = nodes(tetrahedra(tetra_end_2_ind),:);

% FI source locations, moments and directions

source_directions = (tetra_end_2 - tetra_end_1);
source_moments = zef_L2_norm(source_directions, 2);
source_directions = source_directions ./ repmat(source_moments, 1, 3);
source_locations = (1/2) * (tetra_end_1 + tetra_end_2);

% Dipole sign matrix G. Maps rows(node indices)moments and their negatives to each end of
% the node pairs that form the FI dipoles.

n_of_adj_tetra = size(sorted_tetra_faces,1);

signs = sparse(                                                 ...
    [tetrahedra(tetra_end_1_ind) ; tetrahedra(tetra_end_2_ind)] ...
    ,                                                               ...
    repmat([1:n_of_adj_tetra]', 2, 1)                           ...
    ,                                                               ...
    [1./source_moments(:) ; -1./source_moments(:)]              ...
    ,                                                               ...
    n_of_nodes                                                  ...
    ,                                                               ...
    n_of_adj_tetra                                              ...
    );

% Dipole arrangement stensil T.

stensil = sparse(                                       ...
    repmat([1:n_of_adj_tetra]', 2, 1)                   ...
    ,                                                       ...
    [sorted_tetra_faces(:,1) ; sorted_tetra_faces(:,2)] ...
    ,                                                       ...
    ones(2*n_of_adj_tetra, 1)                           ...
    ,                                                       ...
    n_of_adj_tetra                                      ...
    ,                                                       ...
    n_of_tetra                                          ...
    );

end
