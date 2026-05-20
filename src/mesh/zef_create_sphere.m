function [nodes, triangles] = zef_create_sphere(radius, centre_point, n_faces)
% --- Zeffiro documentation header ---
% zef_create_sphere — Zef create sphere.
%
% Purpose:
%   Zef create sphere.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   radius
%   centre_point
%   n_faces
%
% Outputs:
%   nodes
%   triangles
%
% Calls (project):
%   zef_create_sphere
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[nodes, triangles]] = zef_create_sphere(radius, centre_point, n_faces)` with project root and `src` on the path.
% --- End Zeffiro documentation header


warning off;
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
