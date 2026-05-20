function M = zef_volume_scalar_matrix_GG(nodes,tetra,g_i_ind,g_j_ind,scalar_field)
% --- Zeffiro documentation header ---
% zef_volume_scalar_matrix_GG — Zef volume scalar matrix GG.
%
% Purpose:
%   Zef volume scalar matrix GG.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   g_i_ind
%   g_j_ind
%   scalar_field
%
% Outputs:
%   M
%
% Calls (project):
%   zef_barycentric_weighting
%   zef_volume_scalar_matrix_DD
%   zef_volume_scalar_matrix_GG
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_volume_scalar_matrix_GG(nodes, tetra, g_i_ind, g_j_ind, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

weighting = zef_barycentric_weighting('GG');
M = zef_volume_scalar_matrix_DD(nodes,tetra,g_i_ind,g_j_ind,scalar_field,weighting);

end
