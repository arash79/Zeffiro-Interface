function v = zef_volume_scalar_vector_F(nodes, tetra, scalar_field)
% --- Zeffiro documentation header ---
% zef_volume_scalar_vector_F — Zef volume scalar vector F.
%
% Purpose:
%   Zef volume scalar vector F.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   scalar_field
%
% Outputs:
%   v
%
% Calls (project):
%   zef_volume_barycentric
%   zef_volume_scalar_vector_F
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[v] = zef_volume_scalar_vector_F(nodes, tetra, scalar_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

N = size(nodes,1);

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

weight_param = 1/4;

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

v = zeros(N,1);

for i = 1 : 4

    v_part = sparse(tetra(:,i),ones(size(tetra,1),1),weight_param.*scalar_field.*volume,N,1);
    v = v + full(v_part);

end

end
