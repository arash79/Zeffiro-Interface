function M = zef_volume_scalar_matrix_FF(nodes, tetra, scalar_field)
% --- Zeffiro documentation header ---
% zef_volume_scalar_matrix_FF — Zef volume scalar matrix FF.
%
% Purpose:
%   Zef volume scalar matrix FF.
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
%   zef_volume_scalar_matrix
%   zef_volume_scalar_matrix_FF
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_volume_scalar_matrix_FF(nodes, tetra, scalar_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

weighting = zef_barycentric_weighting('FF');
M = zef_volume_scalar_matrix(nodes, tetra, scalar_field, weighting);

end
