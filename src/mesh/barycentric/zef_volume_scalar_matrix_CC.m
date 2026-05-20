function M = zef_volume_scalar_matrix_CC(nodes, tetra, scalar_field)
% --- Zeffiro documentation header ---
% zef_volume_scalar_matrix_CC — Zef volume scalar matrix CC.
%
% Purpose:
%   Zef volume scalar matrix CC.
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
%   zef_volume_barycentric
%   zef_volume_scalar_matrix_CC
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_volume_scalar_matrix_CC(nodes, tetra, scalar_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

K = size(tetra,1);

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

aux_vec = scalar_field.*volume;

M = spdiags(aux_vec,0,K,K);

end
