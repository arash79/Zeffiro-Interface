function triangles = zef_orient_surface_outward(points, triangles)
%ZEF_ORIENT_SURFACE_OUTWARD  Wind each closed component so signed volume is positive.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The solid-angle test in zef_point_in_compartment sums
%   (centroid - node) · area / r^3 and keeps nodes where that sum exceeds
%   4π * meshing_threshold. For a closed surface this is positive inside
%   only when triangle area vectors point outward. Generators that emit
%   the opposite winding (and projects saved from them) otherwise label
%   every interior node as outside.
%
%   triangles = zef_orient_surface_outward(points, triangles)
%
%   Components are face-connected. A component is flipped when it has no
%   boundary edge and its signed volume is negative. Open patches are
%   left unchanged. This does not alter the solid-angle formula.

if isempty(triangles) || isempty(points) || size(triangles, 1) < 4
    return
end

triangles = double(triangles);
points = double(points);
n_faces = size(triangles, 1);
components = local_components(triangles, n_faces);
n_components = max(components);
if n_components > 400
    counts = accumarray(components(:), 1, [n_components, 1]);
    keep = find(counts >= 50);
else
    keep = (1:n_components)';
end

for component = keep(:)'
    faces = find(components == component);
    component_triangles = triangles(faces, :);
    if local_boundary_count(component_triangles) > 0
        continue
    end
    if local_signed_volume(points, component_triangles) < 0
        triangles(faces, :) = component_triangles(:, [1 3 2]);
    end
end

end

function components = local_components(triangles, n_faces)

edges = [triangles(:, [1 2]); triangles(:, [2 3]); triangles(:, [3 1])];
edges = sort(edges, 2);
face_id = repmat((1:n_faces)', 3, 1);
edges = sortrows([edges, face_id], [1 2]);
same = all(edges(1:end - 1, 1:2) == edges(2:end, 1:2), 2);
pair_first = [same; false];
pair_second = [false; same];
sources = edges(pair_first, 3);
targets = edges(pair_second, 3);
keep = sources ~= targets;
sources = sources(keep);
targets = targets(keep);
if isempty(sources)
    components = (1:n_faces)';
    return
end
components = conncomp(graph(sources, targets, [], n_faces))';

end

function count = local_boundary_count(triangles)

edges = [triangles(:, [1 2]); triangles(:, [2 3]); triangles(:, [3 1])];
edges = sort(edges, 2);
[~, ~, index] = unique(edges, 'rows');
counts = accumarray(index, 1);
count = nnz(counts == 1);

end

function volume = local_signed_volume(points, triangles)

v1 = points(triangles(:, 1), :);
v2 = points(triangles(:, 2), :);
v3 = points(triangles(:, 3), :);
volume = sum(dot(v1, cross(v2 - v1, v3 - v1, 2), 2)) / 6;

end
