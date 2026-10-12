function drew = zef_plot_compartment_mesh(zef, compartment_tag, points, triangles, color, alpha)
%ZEF_PLOT_COMPARTMENT_MESH  Draw one compartment, with shaft contacts distinct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   drew = zef_plot_compartment_mesh(zef, compartment_tag, points, triangles, color, alpha)
%
%   A shaft body keeps the compartment colour. Active contact faces are
%   black and unwired DiSC sites are gray, using the triangles of this
%   mesh. Other compartments are a single surface. Draws into the
%   current axes. Does not write zef.
%
%   See also zef_strip_face_sets, zef_plot_meshes.

drew = false;
body = triangles;
active = zeros(0, 3);
inactive = zeros(0, 3);
if exist('zef_strip_face_sets', 'file') == 2
    [body, active, inactive] = zef_strip_face_sets(zef, compartment_tag, points, triangles);
end
drew = local_draw(points, body, color, alpha, 'surface') || drew;
drew = local_draw(points, active, [0 0 0], 1, 'strip contact') || drew;
drew = local_draw(points, inactive, [0.55 0.55 0.55], 1, 'strip contact inactive') || drew;
end

function drew = local_draw(points, triangles, color, alpha, tag)

drew = false;
if isempty(triangles) || isempty(points)
    return
end
[mesh_points, mesh_triangles] = zef_minimal_mesh(points, triangles);
if isempty(mesh_points)
    return
end
graphic = trimesh(mesh_triangles, mesh_points(:, 1), mesh_points(:, 2), mesh_points(:, 3), ...
    'EdgeColor', 'none', 'FaceColor', color);
set(graphic, 'Tag', tag, 'FaceAlpha', alpha);
drew = true;
end
