function [d] = zef_distance_to_resection(points, mesh_points, mesh_edges)
% --- Zeffiro documentation header ---
% zef_distance_to_resection — Zef distance to resection.
%
% Purpose:
%   Zef distance to resection.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   points
%   mesh_points
%   mesh_edges
%
% Outputs:
%   d
%
% Calls (project):
%   zef_distance_to_resection
%   zef_tetra_in_compartment
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[d] = zef_distance_to_resection(points, mesh_points, mesh_edges)` with project root and `src` on the path.
% --- End Zeffiro documentation header


d=nan(size(points,1),1);
inside_index=zef_tetra_in_compartment(mesh_points, mesh_edges, points);
not_inside=setdiff(1:size(points, 1), inside_index);
d(inside_index)=0;
[~, d(not_inside)]=knnsearch(mesh_points, points(not_inside,:));

end
