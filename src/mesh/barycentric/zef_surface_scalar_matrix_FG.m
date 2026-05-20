function M = zef_surface_scalar_matrix_FG(nodes,tetra,g_i_ind,scalar_field)
% --- Zeffiro documentation header ---
% zef_surface_scalar_matrix_FG — Zef surface scalar matrix FG.
%
% Purpose:
%   Zef surface scalar matrix FG.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   g_i_ind
%   scalar_field
%
% Outputs:
%   M
%
% Calls (project):
%   zef_barycentric_weighting
%   zef_surface_scalar_matrix_D
%   zef_surface_scalar_matrix_FG
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_surface_scalar_matrix_FG(nodes, tetra, g_i_ind, scalar_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

weighting = zef_barycentric_weighting('surface_FG');
M = zef_surface_scalar_matrix_D(nodes, tetra, g_i_ind, scalar_field, weighting);

end
