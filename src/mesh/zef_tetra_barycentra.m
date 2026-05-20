function barycentra = zef_tetra_barycentra(nodes, tetrahedra)
% --- Zeffiro documentation header ---
% zef_tetra_barycentra — Zef tetra barycentra.
%
% Purpose:
%   Zef tetra barycentra.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetrahedra
%
% Outputs:
%   barycentra
%
% Calls (project):
%   zef_tetra_barycentra
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[barycentra] = zef_tetra_barycentra(nodes, tetrahedra)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    nodes (:,3) double {mustBeNonNan}
    tetrahedra (:,4) double {mustBeInteger, mustBePositive}
end

barycentra = 1 / 4 * ( ...
    nodes(tetrahedra(:,1),:) ...
    + ...
    nodes(tetrahedra(:,2),:) ...
    + ...
    nodes(tetrahedra(:,3),:) ...
    + ...
    nodes(tetrahedra(:,4),:) ...
    );
end
