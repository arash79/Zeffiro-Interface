function [nodes, triangles] = zef_create_sphere(radius, centre_point, n_faces)
%ZEF_CREATE_SPHERE  Closed triangular sphere at a given centre and radius.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds a unit sphere from MATLAB sphere samples, tetrahedralizes the
%   point cloud, extracts the convex hull with freeBoundary, then
%   reducepatch-decimates in three stages down to about n_faces. The
%   unit mesh is scaled by radius and translated by centre_point.
%
%   This is a geometric primitive in src/mesh. The current first-party
%   tree does not call it from other files; zef_triangulate_surface is
%   the related helper for structured surf grids (sphere, ellipsoid,
%   meshgrid) and is a different code path.
%
%   [nodes, triangles] = zef_create_sphere(radius, centre_point, n_faces)
%
%   Inputs
%     radius        - scalar sphere radius in the same length unit as the
%                     rest of the project (typically millimetres).
%     centre_point  - 1-by-3 Cartesian centre.
%     n_faces       - target triangle count for the last reducepatch step.
%                     The initial sample density is ceil(sqrt(8*n_faces)).
%
%   Outputs
%     nodes      - V-by-3 vertices on the sphere surface.
%     triangles  - F-by-3 1-based faces. F is near n_faces, not exact.
%
%   Notes
%     warning off/on wraps reducepatch because MATLAB may warn about
%     coincident vertices during the intermediate patch objects.
%
%   See also zef_triangulate_surface, sphere, reducepatch.

warning off;
% Dense latitude/longitude samples so the convex hull has enough faces
% to decimate toward n_faces without collapsing topology.
[x, y, z] = sphere(ceil(sqrt(8*n_faces)));
tr = delaunayTriangulation([x(:) y(:) z(:)]);
fe = freeBoundary(tr);
p = reducepatch(patch('Faces',fe,'Vertices',tr.Points),4*n_faces);
p = reducepatch(patch('Faces',p.faces,'Vertices',p.vertices),2*n_faces);
p = reducepatch(patch('Faces',p.faces,'Vertices',p.vertices),n_faces);
warning on;
nodes = p.vertices;
triangles = p.faces;

nodes(:,1) = radius*nodes(:,1) + centre_point(1);
nodes(:,2) = radius*nodes(:,2) + centre_point(2);
nodes(:,3) = radius*nodes(:,3) + centre_point(3);

end
