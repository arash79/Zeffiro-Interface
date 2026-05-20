function M = zef_volume_scalar_matrix_GCC(nodes, tetra, g_i_ind, scalar_field, weighting)
% --- Zeffiro documentation header ---
% zef_volume_scalar_matrix_GCC — Zef volume scalar matrix GCC.
%
% Purpose:
%   Zef volume scalar matrix GCC.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   g_i_ind
%   scalar_field
%   weighting
%
% Outputs:
%   M
%
% Calls (project):
%   zef_volume_barycentric
%   zef_volume_scalar_matrix_GCC
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_volume_scalar_matrix_GCC(nodes, tetra, g_i_ind, scalar_field, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

N = size(nodes,1);
K = size(tetra,1);

if nargin < 5
    weighting = 1;
end

if nargin < 4
    scalar_field = ones(size(tetra,1),1);
end

if length(weighting)==1
    weight_param = weighting([1 1]);
else
    weight_param = weighting;
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

aux_vec = scalar_field.*volume;

M = spalloc(N,N,0);

for i = 1 : 4

    [g_i] = zef_volume_barycentric(nodes,tetra,i,det);
    M_part =  sparse(tetra(:,i),aux_vec.*g_i(:,g_i_ind));
    M = M + M_part;
end
end
