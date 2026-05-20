function M = zef_surface_scalar_matrix_FFn(nodes,tetra,n_ind,scalar_field)
% --- Zeffiro documentation header ---
% zef_surface_scalar_matrix_FFn — Zef surface scalar matrix FFn.
%
% Purpose:
%   Zef surface scalar matrix FFn.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   n_ind
%   scalar_field
%
% Outputs:
%   M
%
% Calls (project):
%   zef_barycentric_weighting
%   zef_surface_scalar_matrix_FFn
%   zef_surface_scalar_matrix_n
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_surface_scalar_matrix_FFn(nodes, tetra, n_ind, scalar_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

weighting = zef_barycentric_weighting('surface_FF');
M = zef_surface_scalar_matrix_n(nodes, tetra, n_ind, scalar_field, weighting);

end
