function [nodes, triangles] = zef_triangulate_surface(X, Y, Z, varargin)
% --- Zeffiro documentation header ---
% zef_triangulate_surface — Zef triangulate surface.
%
% Purpose:
%   Zef triangulate surface.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   X
%   Y
%   Z
%   varargin
%
% Outputs:
%   nodes
%   triangles
%
% Calls (project):
%   zef_triangulate_surface
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[nodes, triangles]] = zef_triangulate_surface(X, Y, Z, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


max_faces = 0;
if not(isempty(varargin))
    max_faces = varargin{1};
end

patch_data = surf2patch(X,Y,Z,'triangles');
if max_faces > 0
    patch_data = reducepatch(patch_data,max_faces);
end
nodes = patch_data.vertices;
triangles = patch_data.faces;

end
