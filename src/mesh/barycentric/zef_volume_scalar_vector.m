function v = zef_volume_scalar_vector(nodes, tetra, scalar_field, weighting)
% --- Zeffiro documentation header ---
% zef_volume_scalar_vector — Zef volume scalar vector.
%
% Purpose:
%   Zef volume scalar vector.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   scalar_field
%   weighting
%
% Outputs:
%   v
%
% Calls (project):
%   zef_volume_barycentric
%   zef_volume_scalar_vector
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[v] = zef_volume_scalar_vector(nodes, tetra, scalar_field, weighting)` with project root and `src` on the path.
% --- End Zeffiro documentation header

N = size(nodes,1);

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

if nargin < 4
    weight_param = 1;
else
    weight_param = weighting;
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

v = zeros(N,1);

for i = 1 : 4

    v_part = sparse(tetra(:,i),ones(size(tetra,1),1),weight_param.*scalar_field.*volume,N,1);
    v = v + full(v_part);

end

end
