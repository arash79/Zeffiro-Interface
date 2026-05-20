function M = zef_surface_scalar_matrix_FGn(nodes,tetra,g_i_ind,n_ind,scalar_field)
% --- Zeffiro documentation header ---
% zef_surface_scalar_matrix_FGn — Zef surface scalar matrix FGn.
%
% Purpose:
%   Zef surface scalar matrix FGn.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   g_i_ind
%   n_ind
%   scalar_field
%
% Outputs:
%   M
%
% Calls (project):
%   zef_barycentric_weighting
%   zef_surface_scalar_matrix_Dn
%   zef_surface_scalar_matrix_FGn
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_surface_scalar_matrix_FGn(nodes, tetra, g_i_ind, n_ind, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

weighting = zef_barycentric_weighting('surface_FG');
M = zef_surface_scalar_matrix_Dn(nodes, tetra, g_i_ind, n_ind, scalar_field, weighting);

end
