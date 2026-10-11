function [nodes, tetra, domain_labels, distance_vec, report] = zef_refine_small_features(zef, nodes, tetra, domain_labels, distance_vec, mesh_res)
%ZEF_REFINE_SMALL_FEATURES  Split tets that cannot resolve a thin feature.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef.mesh_resolution is the uniform lattice spacing. A compartment
%   thinner than about two cells never receives a tetrahedron, because a
%   cell is labeled by the outermost compartment among its vertices. This
%   pass estimates that thickness from inward rays (stopping at an inner
%   surface, so a shell is not confused with the diameter of its outer
%   wall) and, separately, a finer triangle population on the same
%   surface (electrode disks, not a handful of sliver edges).
%
%   Only tetrahedra near those samples are split, via zef_mesh_refinement.
%   Regions whose surfaces are coarser than the requested spacing stay on
%   the original lattice. At most four splits are applied, and the target
%   is never finer than mesh_resolution/16; a feature below that floor is
%   reported instead of being refined without limit.
%
%   [nodes, tetra, domain_labels, distance_vec, report] = ...
%       zef_refine_small_features(zef, nodes, tetra, domain_labels, distance_vec, mesh_res)
%
%   domain_labels are still the pre-split labels. The caller relabels.

report = struct('refined', false, 'passes', 0, 'unresolved', false, ...
    'message', '', 'min_target', mesh_res);
if isempty(tetra) || ~isscalar(mesh_res) || ~isfinite(mesh_res) || mesh_res <= 0
    return
end
if ~isfield(zef, 'reuna_p') || isempty(zef.reuna_p)
    return
end

[sample_points, sample_h, sample_radius, limited] = local_samples(zef, mesh_res);
if limited
    report.unresolved = true;
    report.message = sprintf(['A surface feature is finer than %.4g mm, ', ...
        'the smallest spacing this pass will generate from a %.4g mm lattice.'], ...
        mesh_res / 16, mesh_res);
end
if isempty(sample_points)
    return
end
report.min_target = min(sample_h);
max_marked = 200000;
max_passes = 4;

for pass = 1:max_passes
    longest = local_longest_edge(nodes, tetra);
    mark = local_mark(nodes, tetra, longest, sample_points, sample_h, sample_radius);
    if ~any(mark)
        break
    end
    if nnz(mark) > max_marked
        report.unresolved = true;
        report.message = sprintf(['Feature refinement marked %d tetrahedra, ', ...
            'above the %d cap, so the finest requested spacing was not applied everywhere.'], ...
            nnz(mark), max_marked);
        ratio = longest ./ local_requirement(nodes, tetra, sample_points, sample_h, sample_radius);
        ratio(~mark) = -inf;
        [~, order] = sort(ratio, 'descend');
        mark(:) = false;
        mark(order(1:max_marked)) = true;
    end
    refine_index = find(mark);
    [nodes, tetra, domain_labels, distance_vec] = zef_mesh_refinement( ...
        zef, nodes, tetra, domain_labels, distance_vec, 0, refine_index);
    report.refined = true;
    report.passes = pass;
end

if local_any_violation(nodes, tetra, sample_points, sample_h, sample_radius)
    report.unresolved = true;
    if isempty(report.message)
        report.message = sprintf(['After %d refinement passes some tetrahedra are still ', ...
            'coarser than the spacing required by a nearby feature (smallest target %.4g mm).'], ...
            max_passes, report.min_target);
    end
end

end

function [points, target, radius, limited] = local_samples(zef, mesh_res)

points = zeros(0, 3);
target = zeros(0, 1);
radius = zeros(0, 1);
limited = false;
floor_h = mesh_res / 16;
n_surfaces = numel(zef.reuna_p);

for surface = 1:n_surfaces
    surface_points = zef.reuna_p{surface};
    surface_triangles = zef.reuna_t{surface};
    if isempty(surface_points) || isempty(surface_triangles) || size(surface_triangles, 1) < 4
        continue
    end
    surface_triangles = double(surface_triangles);
    [edge_points, edge_h, edge_limited] = local_edge_samples( ...
        surface_points, surface_triangles, mesh_res, floor_h);
    limited = limited || edge_limited;
    inner = cell(1, max(0, surface - 1));
    for previous = 1:surface - 1
        inner{previous} = struct('points', zef.reuna_p{previous}, ...
            'triangles', double(zef.reuna_t{previous}));
    end
    [thick_points, thick_h] = local_thickness_samples( ...
        surface_points, surface_triangles, inner, mesh_res, floor_h);
    if ~isempty(edge_points)
        points = [points; edge_points]; %#ok<AGROW>
        target = [target; edge_h]; %#ok<AGROW>
        radius = [radius; 4 * edge_h]; %#ok<AGROW>
    end
    if ~isempty(thick_points)
        points = [points; thick_points]; %#ok<AGROW>
        target = [target; thick_h]; %#ok<AGROW>
        radius = [radius; max(2 * thick_h, mesh_res)]; %#ok<AGROW>
    end
end

end

function [origins, target] = local_thickness_samples(points, triangles, inner, mesh_res, floor_h)

origins = zeros(0, 3);
target = zeros(0, 1);
probe = local_probe_index(size(triangles, 1), 24);
[hit, origins_probe] = local_probe_thickness(points, triangles, inner, probe);
if numel(hit) < 8
    return
end
ordered = sort(hit);
typical = ordered(max(1, round(0.2 * numel(ordered))));
thin = hit < 1.8 * mesh_res;
if typical < 1.8 * mesh_res || nnz(thin) >= 0.25 * numel(hit)
    area = local_area(points, triangles);
    spacing = max(min(hit), mesh_res);
    n_probe = min(400, max(numel(probe), ceil(area / spacing ^ 2)));
    probe = local_probe_index(size(triangles, 1), n_probe);
    [hit, origins_probe] = local_probe_thickness(points, triangles, inner, probe);
end
keep = isfinite(hit) & hit < 1.8 * mesh_res & hit > 0;
if ~any(keep)
    return
end
origins = origins_probe(keep, :);
target = max(hit(keep) / 2, floor_h);

end

function [hit, origins] = local_probe_thickness(points, triangles, inner, probe)

n_probe = numel(probe);
hit = inf(n_probe, 1);
origins = zeros(n_probe, 3);
edge_lengths = local_edge_lengths(points, triangles);
edge_lengths = sort(edge_lengths(edge_lengths > 0));
if isempty(edge_lengths)
    minimum_t = 1e-3;
else
    % Skip hits on the source triangle and its immediate neighbors. A real
    % opposite wall sits farther than about half a typical edge.
    minimum_t = max(1e-3, 0.5 * edge_lengths(max(1, round(0.5 * numel(edge_lengths)))));
end
for sample = 1:n_probe
    triangle = triangles(probe(sample), :);
    v1 = points(triangle(1), :);
    edge_1 = points(triangle(2), :) - v1;
    edge_2 = points(triangle(3), :) - v1;
    normal = cross(edge_1, edge_2);
    length_normal = norm(normal);
    if length_normal <= 1e-12
        continue
    end
    inward = -normal / length_normal;
    origin = (v1 + points(triangle(2), :) + points(triangle(3), :)) / 3;
    origins(sample, :) = origin;
    distance = local_ray(origin, inward, points, triangles, minimum_t);
    for previous = 1:numel(inner)
        if isempty(inner{previous}.triangles)
            continue
        end
        distance = min(distance, local_ray(origin, inward, ...
            inner{previous}.points, inner{previous}.triangles, minimum_t));
    end
    hit(sample) = distance;
end
finite_hit = isfinite(hit);
hit = hit(finite_hit);
origins = origins(finite_hit, :);

end

function index = local_probe_index(n_triangles, n_probe)

n_probe = min(n_triangles, max(1, round(n_probe)));
index = unique(round(linspace(1, n_triangles, n_probe)), 'stable');

end

function area = local_area(points, triangles)

edge_1 = points(triangles(:, 2), :) - points(triangles(:, 1), :);
edge_2 = points(triangles(:, 3), :) - points(triangles(:, 1), :);
area = sum(vecnorm(cross(edge_1, edge_2, 2), 2, 2)) / 2;

end

function [points_out, target, limited] = local_edge_samples(points, triangles, mesh_res, floor_h)

points_out = zeros(0, 3);
target = zeros(0, 1);
limited = false;
lengths = local_edge_lengths(points, triangles);
ordered = sort(lengths);
median_length = ordered(max(1, round(0.5 * numel(ordered))));
tenth = ordered(max(1, round(0.1 * numel(ordered))));
if tenth >= 0.5 * median_length || tenth >= mesh_res
    return
end
desired = max(tenth, 0.5 * median_length);
if desired < floor_h
    limited = true;
end
target_h = max(desired, floor_h);
n_vertices = size(points, 1);
shortest = inf(n_vertices, 1);
pairs = [1 2; 2 3; 3 1];
for edge = 1:3
    first = triangles(:, pairs(edge, 1));
    second = triangles(:, pairs(edge, 2));
    length_edge = vecnorm(points(first, :) - points(second, :), 2, 2);
    shortest = min(shortest, accumarray(first, length_edge, [n_vertices, 1], @min, inf));
    shortest = min(shortest, accumarray(second, length_edge, [n_vertices, 1], @min, inf));
end
fine = find(shortest < 0.5 * median_length);
if numel(fine) < 12
    return
end
if numel(fine) > 2000
    fine = fine(round(linspace(1, numel(fine), 2000)));
end
points_out = points(fine, :);
target = repmat(target_h, numel(fine), 1);

end

function lengths = local_edge_lengths(points, triangles)

pairs = [1 2; 2 3; 3 1];
lengths = zeros(size(triangles, 1) * 3, 1);
for edge = 1:3
    first = triangles(:, pairs(edge, 1));
    second = triangles(:, pairs(edge, 2));
    lengths((edge - 1) * size(triangles, 1) + (1:size(triangles, 1))) = ...
        vecnorm(points(first, :) - points(second, :), 2, 2);
end

end

function distance = local_ray(origin, direction, points, triangles, minimum_t)

distance = inf;
if isempty(triangles)
    return
end
chunk = 8000;
n_triangles = size(triangles, 1);
for start = 1:chunk:n_triangles
    selection = start:min(start + chunk - 1, n_triangles);
    tri = triangles(selection, :);
    v0 = points(tri(:, 1), :);
    v1 = points(tri(:, 2), :);
    v2 = points(tri(:, 3), :);
    edge_1 = v1 - v0;
    edge_2 = v2 - v0;
    pvec = cross(repmat(direction, numel(selection), 1), edge_2, 2);
    determinant = sum(edge_1 .* pvec, 2);
    valid = abs(determinant) > 1e-12;
    inverse = zeros(size(determinant));
    inverse(valid) = 1 ./ determinant(valid);
    tvec = origin - v0;
    u = sum(tvec .* pvec, 2) .* inverse;
    qvec = cross(tvec, edge_1, 2);
    v = sum(repmat(direction, numel(selection), 1) .* qvec, 2) .* inverse;
    t = sum(edge_2 .* qvec, 2) .* inverse;
    hit = valid & u >= 0 & v >= 0 & (u + v) <= 1 & t > minimum_t;
    if any(hit)
        distance = min(distance, min(t(hit)));
    end
end

end

function longest = local_longest_edge(nodes, tetra)

pairs = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
longest = zeros(size(tetra, 1), 1);
for edge = 1:size(pairs, 1)
    length_edge = vecnorm(nodes(tetra(:, pairs(edge, 1)), :) - nodes(tetra(:, pairs(edge, 2)), :), 2, 2);
    longest = max(longest, length_edge);
end

end

function mark = local_mark(nodes, tetra, longest, sample_points, sample_h, sample_radius)

mark = false(size(tetra, 1), 1);
neighbors = local_neighbors(nodes, tetra, sample_points, sample_radius);
if isempty(neighbors)
    return
end
for sample = 1:numel(neighbors)
    near = neighbors{sample};
    if isempty(near)
        continue
    end
    near = near(longest(near) > 1.5 * sample_h(sample));
    mark(near) = true;
end

end

function requirement = local_requirement(nodes, tetra, sample_points, sample_h, sample_radius)

requirement = inf(size(tetra, 1), 1);
neighbors = local_neighbors(nodes, tetra, sample_points, sample_radius);
for sample = 1:numel(neighbors)
    near = neighbors{sample};
    requirement(near) = min(requirement(near), sample_h(sample));
end

end

function neighbors = local_neighbors(nodes, tetra, sample_points, sample_radius)

neighbors = {};
if isempty(sample_points)
    return
end
sample_radius = sample_radius(:);
centroids = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) + ...
    nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;
[neighbors, distances] = rangesearch(centroids, sample_points, max(sample_radius));
for sample = 1:numel(neighbors)
    neighbors{sample} = neighbors{sample}(distances{sample} <= sample_radius(sample));
end

end

function violated = local_any_violation(nodes, tetra, sample_points, sample_h, sample_radius)

longest = local_longest_edge(nodes, tetra);
mark = local_mark(nodes, tetra, longest, sample_points, sample_h, sample_radius);
violated = any(mark);

end
