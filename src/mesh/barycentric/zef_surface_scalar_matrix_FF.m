function M = zef_surface_scalar_matrix_FF(nodes,tetra,scalar_field)
% --- Zeffiro documentation header ---
% zef_surface_scalar_matrix_FF — Zef surface scalar matrix FF.
%
% Purpose:
%   Zef surface scalar matrix FF.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   scalar_field
%
% Outputs:
%   M
%
% Calls (project):
%   zef_barycentric_weighting
%   zef_surface_scalar_matrix
%   zef_surface_scalar_matrix_FF
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_surface_scalar_matrix_FF(nodes, tetra, scalar_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

weighting = zef_barycentric_weighting('surface_FF');
M = zef_surface_scalar_matrix(nodes, tetra, scalar_field, weighting);

end
