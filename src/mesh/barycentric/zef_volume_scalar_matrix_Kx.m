function M = zef_volume_scalar_matrix_Kx(nodes, tetra, h, x, u_field, volume, b_coord)
% --- Zeffiro documentation header ---
% zef_volume_scalar_matrix_Kx — Zef volume scalar matrix Kx.
%
% Purpose:
%   Zef volume scalar matrix Kx.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetra
%   h
%   x
%   u_field
%   volume
%   b_coord
%
% Outputs:
%   M
%
% Calls (project):
%   zef_barycentric_weighting
%   zef_volume_barycentric
%   zef_volume_scalar_matrix_Kx
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[M] = zef_volume_scalar_matrix_Kx(nodes, tetra, h, x, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

det = [];

if nargin < 6
    for i = 1:4
        [b_coord,det] = zef_volume_barycentric(nodes,tetra,h);
        volume = abs(det)/6;
        b_coord_h{i} = b_coord(:,h);

        if h > 1
            [b_coord,~] = zef_volume_barycentric(nodes,tetra,h,det);
            volume = abs(det)/6;
            b_coord_h{i} = b_coord(:,h);
        end
    end
end

weight_param = zef_barycentric_weighting('FF');
b_coord_h = b_coord(:,h);

for i = 1 : 4
    for j = 1 : 4
        if i == j
            entry_vec = b_cood_h{i}.*volume*weight_param(1).*x(tetra(:,j));
        else
            entry_vec = b_cood_h{i}.*volume*weight_param(2).*x(tetra(:,j));
        end
    end
end

end
