function [nodes,triangles,interp_vec] = zef_triangular_mesh_refinement(nodes,triangles)
%ZEF_TRIANGULAR_MESH_REFINEMENT  4-to-1 split of every triangle (mid-edge nodes).
%
%   GPU-ToRRe / Zeffiro Interface.
%   Copyright © 2019- Sampsa Pursiainen & GPU-ToRRe Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Appends three midpoint blocks (edges 12, 23, 31), replaces each face
%   with four children (three corners + one midpoint triangle), then merges
%   coincident vertices with unique(round(nodes,15),'rows'). Called from
%   zef_set_surface_resolution when a compartment needs *more* faces than
%   it currently has (the downsample path uses reducepatch the other way).
%
%   [nodes, triangles, interp_vec] = zef_triangular_mesh_refinement(nodes, triangles)
%
%   Inputs
%     nodes      - N×3.
%     triangles  - F×3 1-based indices.
%
%   Outputs
%     nodes       - compacted vertices (midpoints included).
%     triangles   - (4F)×3 remapped into the compacted nodes.
%     interp_vec  - (4F)×1 parent face index (1:F repeated four times).
%                   Unused by zef_set_surface_resolution (two outputs).
%
%   See also zef_set_surface_resolution, zef_downsample_surfaces, zef_mesh_refinement.

eps_val = 15;

n_nodes = size(nodes,1);
n_triangles = size(triangles,1);

nodes = [nodes;
    (1/2)*(nodes(triangles(:,1),:) + nodes(triangles(:,2),:));
    (1/2)*(nodes(triangles(:,2),:) + nodes(triangles(:,3),:));
    (1/2)*(nodes(triangles(:,3),:) + nodes(triangles(:,1),:))];

interp_vec = [1:n_triangles]';
interp_vec = interp_vec(:,[1 1 1 1]);
interp_vec = interp_vec(:);

t_aux_1 = triangles(:,1);
t_aux_2 = triangles(:,2);
t_aux_3 = triangles(:,3);
% Midpoints occupy three contiguous blocks after the original N vertices.
t_aux_4 = n_nodes+[1:n_triangles]';
t_aux_5 = n_nodes+n_triangles+[1:n_triangles]';
t_aux_6 = n_nodes+2*n_triangles+[1:n_triangles]';

triangles = [t_aux_1 t_aux_4 t_aux_6 ;
    t_aux_4 t_aux_2 t_aux_5 ;
    t_aux_5 t_aux_3 t_aux_6;
    t_aux_4 t_aux_5 t_aux_6];

[~, unique_vec_2, unique_vec_3] = unique(round(nodes,eps_val),'rows');
nodes = nodes(unique_vec_2,:);
triangles = unique_vec_3(triangles);

end
