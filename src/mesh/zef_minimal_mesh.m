function [nodes_new, triangles_new, nodes_ind, triangles_ind] = zef_minimal_mesh(nodes, triangles)
%ZEF_MINIMAL_MESH  Drop unused vertices when a patch is sparse vs its node array.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   If F < 0.01 N, unique(triangles) becomes the kept vertex list and
%   faces are remapped. Otherwise the inputs are returned unchanged
%   (plotting path: most head surfaces are denser than that). Used by
%   zef_plot_meshes / zef_plot_volume / zef_print_meshes to shrink
%   patches before patch().
%
%   [nodes_new, triangles_new, nodes_ind, triangles_ind] = zef_minimal_mesh(nodes, triangles)
%
%   Inputs
%     nodes      - N×3.
%     triangles  - F×3 1-based indices into nodes (or any F×k index array;
%                  reshape uses size(triangles)).
%
%   Outputs
%     nodes_new, triangles_new - compacted or original.
%     nodes_ind      - indices into the original nodes of the kept vertices
%                      (1:N when the heuristic does not fire).
%     triangles_ind  - in the compact branch this is unique's third output
%                      (flattened remapped indices), not 1:F.
%
%   See also zef_plot_meshes, zef_surface_mesh.

if size(triangles,1) >= 0.01*size(nodes,1)
    triangles_new = triangles;
    nodes_new = nodes;
    nodes_ind = [1:size(nodes,1)]';
    triangles_ind = [1:size(triangles,1)]';
else
    [nodes_ind,~,triangles_ind] = unique(triangles);
    nodes_new = nodes(nodes_ind,:);
    triangles_new = reshape(triangles_ind, size(triangles));
end

end
