function [tetra, domain_labels] = zef_unique_tetra(tetra, domain_labels)
%ZEF_UNIQUE_TETRA  Drop duplicate tetrahedra regardless of local vertex order.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Two tetrahedra that list the same four nodes in a different order are
%   treated as one element: each row is sorted, then unique(...,'rows')
%   keeps the first occurrence. Matching rows of domain_labels are kept so
%   tissue IDs stay aligned with the reduced tetra array.
%
%   This is a mesh-cleanup helper in src/mesh. The current first-party
%   tree does not call it from other files; use it when merging or
%   converting meshes that may contain repeated tets.
%
%   [tetra, domain_labels] = zef_unique_tetra(tetra, domain_labels)
%
%   Inputs
%     tetra          - T-by-4 1-based node indices.
%     domain_labels  - T-by-P labels (usually T-by-1 tissue IDs). Must have
%                      one row per tetrahedron.
%
%   Outputs
%     tetra, domain_labels  - subset of rows, same columns, unique tets.
%
%   Notes
%     unique keeps the first sorted row it sees, so the surviving orientation
%     (and therefore the sign of the volume) is that of the first duplicate.
%     Callers that require positive volumes should run zef_tetra_turn (or
%     equivalent) afterwards.
%
%   See also zef_mesh_refinement, unique.

% Sort each tet's four vertex indices so (1 2 3 4) and (4 3 2 1) collide.
[~, I] = unique(sort(tetra,2),'rows');
tetra = tetra(I,:);
domain_labels = domain_labels(I,:);

end
