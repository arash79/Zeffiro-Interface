function gradients = zef_volume_gradient(nodes, tetrahedra, node_index)
% --- Zeffiro documentation header ---
% zef_volume_gradient — Zef volume gradient.
%
% Purpose:
%   Zef volume gradient.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   nodes
%   tetrahedra
%   node_index
%
% Outputs:
%   gradients
%
% Calls (project):
%   zef_volume_gradient
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[gradients] = zef_volume_gradient(nodes, tetrahedra, node_index)` with project root and `src` on the path.
% --- End Zeffiro documentation header

ind_m = [
    2 3 4 ;
    3 4 1 ;
    4 1 2 ;
    1 2 3
    ];

% Cross products between the direction vectors that determine the faces of
% the tetrahedra. Results in the surface normals of the faces.

normals = 1/2 * cross(                          ...
    nodes(tetrahedra(:,ind_m(node_index,2)),:)' ...
    -                                           ...
    nodes(tetrahedra(:,ind_m(node_index,1)),:)' ...
    ,                                               ...
    nodes(tetrahedra(:,ind_m(node_index,3)),:)' ...
    -                                           ...
    nodes(tetrahedra(:,ind_m(node_index,1)),:)' ...
    );

% Dot products between the face normals and the direction vectors between
% a fixed node and other nodes in a tetrahedron.

fixed_nodes = nodes(tetrahedra(:,node_index),:)';
other_nodes = nodes(tetrahedra(:,ind_m(node_index,1)),:)';
direction_vectors = fixed_nodes - other_nodes;

gradients = normals .* repmat(  ...
    sign(                       ...
    dot(                    ...
    normals             ...
    ,                       ...
    direction_vectors   ...
    )                       ...
    )                           ...
    ,                               ...
    3, 1                        ...
    );

end
