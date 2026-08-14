function [d] = zef_distance_to_resection(points, mesh_points, mesh_edges)
%ZEF_DISTANCE_TO_RESECTION  0 inside a triangle mesh, else knnsearch (duplicate).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   d = zef_distance_to_resection(points, mesh_points, mesh_edges)
%
%   Always three arguments (no two-arg knnsearch-only form). Same as
%   src/auxiliary/zef_distance_to_resection three-arg path. Prefer that
%   copy for new code.
%
%   See also zef_insideGMM.

d=nan(size(points,1),1);
inside_index=zef_tetra_in_compartment(mesh_points, mesh_edges, points);
not_inside=setdiff(1:size(points, 1), inside_index);
d(inside_index)=0;
[~, d(not_inside)]=knnsearch(mesh_points, points(not_inside,:));

end
