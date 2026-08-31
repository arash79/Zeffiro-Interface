function [d] = zef_distance_to_resection(points, mesh_points, mesh_triangles)
%ZEF_DISTANCE_TO_RESECTION  knnsearch to resection points; 0 if inside a mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   d = zef_distance_to_resection(points, mesh_points)
%   d = zef_distance_to_resection(points, mesh_points, mesh_triangles)
%
%   Two arguments: knnsearch(mesh_points, points). Three: points inside
%   the triangle mesh (zef_tetra_in_compartment) get d=0; others knnsearch.
%   Used by the epilepsy study helper zef_show_results_focal_epilepsy.
%
%   See also zef_tetra_in_compartment.

if nargin == 2
    [~, d]=knnsearch(mesh_points, points);
else
    d=nan(size(points,1),1);
    inside_index=zef_tetra_in_compartment(mesh_points, mesh_triangles, points);
    not_inside=setdiff(1:size(points, 1), inside_index);
    d(inside_index)=0;
    [~, d(not_inside)]=knnsearch(mesh_points, points(not_inside,:));
end

end
