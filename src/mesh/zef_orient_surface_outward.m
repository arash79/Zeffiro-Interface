function triangles = zef_orient_surface_outward(points, triangles)
%ZEF_ORIENT_SURFACE_OUTWARD  Wind closed components for the solid-angle test.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The solid-angle test in zef_point_in_compartment sums
%   (centroid - node) · area / r^3 and keeps nodes where that sum exceeds
%   4π * meshing_threshold. For one closed surface the sum is positive
%   inside only when the area vectors point outward.
%
%   A compartment mesh can also be a shell: an outer wall plus a separate
%   inner wall. Forcing every component outward makes the cavity count as
%   inside, so the whole hole is labeled as that compartment. Nesting
%   fixes the sign. A component whose interior sits inside a strictly
%   larger component is one level deeper. Even depth (the outer solid)
%   points outward. Odd depth (a cavity) points inward, and the two
%   contributions cancel inside the hole. Open patches are left unchanged.
%
%   triangles = zef_orient_surface_outward(points, triangles)

if isempty(triangles) || isempty(points) || size(triangles, 1) < 4
    return
end

triangles = double(triangles);
points = double(points);
n_faces = size(triangles, 1);
components = local_components(triangles, n_faces);
n_components = max(components);
component_list = (1:n_components)';
closed = false(n_components, 1);
volume = zeros(n_components, 1);
interior = zeros(n_components, 3);
reliable = false(n_components, 1);
bbox_min = inf(n_components, 3);
bbox_max = -inf(n_components, 3);

for component = component_list'
    faces = find(components == component);
    component_triangles = triangles(faces, :);
    if local_boundary_count(component_triangles) > 0
        continue
    end
    closed(component) = true;
    volume(component) = local_signed_volume(points, component_triangles);
    member = unique(component_triangles(:));
    bbox_min(component, :) = min(points(member, :), [], 1);
    bbox_max(component, :) = max(points(member, :), [], 1);
    [interior(component, :), reliable(component)] = local_interior_point( ...
        points, component_triangles);
end

depth = zeros(n_components, 1);
for child = component_list'
    if ~closed(child) || ~reliable(child)
        continue
    end
    for parent = component_list'
        if parent == child || ~closed(parent) || ~reliable(parent)
            continue
        end
        if abs(volume(parent)) <= abs(volume(child))
            continue
        end
        if any(interior(child, :) < bbox_min(parent, :) - 1e-8) || ...
                any(interior(child, :) > bbox_max(parent, :) + 1e-8)
            continue
        end
        parent_faces = components == parent;
        if abs(local_solid_fraction(points, triangles(parent_faces, :), interior(child, :))) > 0.5
            depth(child) = depth(child) + 1;
        end
    end
end

for component = component_list'
    if ~closed(component) || volume(component) == 0
        continue
    end
    desired_sign = 1 - 2 * mod(depth(component), 2);
    if sign(volume(component)) ~= desired_sign
        faces = components == component;
        triangles(faces, :) = triangles(faces, [1 3 2]);
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

function [point, reliable] = local_interior_point(points, triangles)

member = unique(triangles(:));
centroid = mean(points(member, :), 1);
if abs(local_solid_fraction(points, triangles, centroid)) > 0.5
    point = centroid;
    reliable = true;
    return
end

v1 = points(triangles(:, 1), :);
areas = cross(points(triangles(:, 2), :) - v1, points(triangles(:, 3), :) - v1, 2);
area_norm = sqrt(sum(areas .^ 2, 2));
[~, index] = max(area_norm);
if area_norm(index) <= 1e-12
    point = centroid;
    reliable = false;
    return
end
normal = areas(index, :) / area_norm(index);
origin = (points(triangles(index, 1), :) + points(triangles(index, 2), :) + ...
    points(triangles(index, 3), :)) / 3;
% A fraction of the triangle's size stays inside a thin wall. A fixed
% millimetre step walks through a sub-millimetre shell.
step = max(1e-6, 0.05 * sqrt(area_norm(index)));
candidates = [origin - step * normal; origin + step * normal];
strength = zeros(2, 1);
for side = 1:2
    strength(side) = abs(local_solid_fraction(points, triangles, candidates(side, :)));
end
[best, pick] = max(strength);
point = candidates(pick, :);
reliable = best > 0.5;

end

function fraction = local_solid_fraction(points, triangles, query)

centroids = (points(triangles(:, 1), :) + points(triangles(:, 2), :) + points(triangles(:, 3), :)) / 3;
areas = cross(points(triangles(:, 2), :) - points(triangles(:, 1), :), ...
    points(triangles(:, 3), :) - points(triangles(:, 1), :), 2) / 2;
offset = centroids - query(:).';
radius = max(sqrt(sum(offset .^ 2, 2)), 1e-12);
fraction = sum(sum(offset .* areas, 2) ./ (radius .^ 3)) / (4 * pi);

end
