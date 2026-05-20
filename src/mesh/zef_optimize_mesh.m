function [nodes, tetra] = zef_optimize_mesh(nodes,tetra)
% --- Zeffiro documentation header ---
% zef_optimize_mesh — Zef optimize mesh.
%
% Purpose:
%   Zef optimize mesh.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%
% Outputs:
%   nodes
%   tetra
%
% Zef fields (observed):
%   zef.mesh_optimization_parameter (read)
%
% Calls (project):
%   zef_optimize_mesh
%   zef_tetra_turn
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[[nodes, tetra]] = zef_optimize_mesh(nodes, tetra)` with project root and `src` on the path.
% --- End Zeffiro documentation header


nodes_old = nodes;
tetra_old = tetra;

[tetra, optimizer_flag] = zef_tetra_turn(zef, nodes, tetra, evalin('base','zef.mesh_optimization_parameter'));

if optimizer_flag == -1
    nodes = nodes_old;
    tetra = tetra_old;
    errordlg('Mesh optimization failed.');
    return;

end
