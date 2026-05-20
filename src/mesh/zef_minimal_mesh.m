function [nodes_new, triangles_new, nodes_ind, triangles_ind] = zef_minimal_mesh(nodes, triangles)
% --- Zeffiro documentation header ---
% zef_minimal_mesh — Zef minimal mesh.
%
% Purpose:
%   Zef minimal mesh.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   triangles
%
% Outputs:
%   nodes_new
%   triangles_new
%   nodes_ind
%   triangles_ind
%
% Calls (project):
%   zef_minimal_mesh
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[nodes_new, triangles_new, nodes_ind]] = zef_minimal_mesh(nodes, triangles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if size(triangles,1) >= 0.01*size(nodes,1)
    triangles_new = triangles;
    nodes_new = nodes;
    nodes_ind = [1:size(nodes,1)]';
    triangles_ind = [1:size(triangles,1)]';
else
    [nodes_ind,~,triangles_ind] = unique(triangles);
    nodes_new = nodes(nodes_ind,:);
    triangles_new = reshape(triangles_ind, size(triangles));
end

end
