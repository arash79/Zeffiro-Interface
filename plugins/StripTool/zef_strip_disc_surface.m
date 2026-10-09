function [T, P] = zef_strip_disc_surface(strip_struct)
%ZEF_STRIP_DISC_SURFACE  Closed DiSC shaft with lithographic contact disks.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [T, P] = zef_strip_disc_surface(strip_struct)
%
%   Lateral surface plus end caps, axis along z, centered on
%   [-length/2, length/2] so zef_create_strip can shift the tip to 0.
%   strip_n_sectors tessellates the insulator only. Every physical
%   site from zef_strip_disc_lattice, including amplifier-inactive
%   DiSC-64 sites, is a flush disk on the cylinder. The disk is a
%   circle in the unwrapped (arc length, z) plane. The parameter cut
%   sits in the largest angular gap so it does not split a disk.
%
%   See also zef_create_strip, zef_strip_disc_lattice, zef_strip_disc_patch.

radius = double(strip_struct.strip_radius);
length_mm = double(strip_struct.strip_length);
if ~isscalar(radius) || ~isfinite(radius) || radius <= 0
    error('zef:DiscSurface', 'DiSC shaft radius must be a positive length.');
end
if ~isscalar(length_mm) || ~isfinite(length_mm) || length_mm <= 0
    error('zef:DiscSurface', 'DiSC shaft length must be a positive length.');
end

n_sectors = max(3, round(double(strip_struct.strip_n_sectors)));
lattice = zef_strip_disc_lattice(strip_struct.strip_model, radius);
contact_radius = lattice.contact_radius;
if contact_radius >= radius
    error('zef:DiscSurface', ...
        'DiSC contact radius must be smaller than the shaft radius.');
end
theta_cut = local_seam(lattice.angle);
dtheta = 2 * pi / n_sectors;
theta = theta_cut + (0:n_sectors - 1)' * dtheta;
n_axial = max(2, ceil(length_mm / (radius * dtheta)));
z_line = linspace(-length_mm / 2, length_mm / 2, n_axial)';

n_grid = n_sectors * n_axial;
grid_sector = mod((0:n_grid - 1)', n_sectors) + 1;
grid_axial = floor((0:n_grid - 1)' / n_sectors) + 1;
P_grid = [radius * cos(theta(grid_sector)), ...
    radius * sin(theta(grid_sector)), ...
    z_line(grid_axial)];

[centers, fits] = local_centers(lattice, radius, length_mm);
inside = false(n_grid, 1);
for contact = find(fits)'
    % A small margin keeps shaft vertices out of the disk polygon. The
    % contact query still uses the true lithographic radius.
    dtheta = atan2(sin(theta(grid_sector) - lattice.angle(contact)), ...
        cos(theta(grid_sector) - lattice.angle(contact)));
    arc_here = radius * dtheta;
    dz = z_line(grid_axial) - centers(contact, 3);
    inside = inside | (arc_here .^ 2 + dz .^ 2) <= (1.02 * contact_radius) ^ 2;
end
end_ring = grid_axial == 1 | grid_axial == n_axial;
seam_column = grid_sector == 1;
keep_grid = ~(inside & ~end_ring & ~seam_column);

kept_sector = grid_sector(keep_grid);
kept_axial = grid_axial(keep_grid);
P = P_grid(keep_grid, :);
n_kept = size(P, 1);

[disk_xyz, disk_theta, disk_z] = local_disks(lattice, ...
    radius, length_mm, contact_radius, fits);
disk_theta = theta_cut + mod(disk_theta - theta_cut, 2 * pi);
if any(disk_theta <= theta_cut | disk_theta >= theta_cut + 2 * pi)
    error('zef:DiscSurface', ...
        'A DiSC contact crosses the shaft parameter seam.');
end
P = [P; disk_xyz];
n_disk = size(disk_xyz, 1);

left = find(kept_sector == 1);
n_seam = numel(left);
seam_theta = theta(kept_sector(left)) + 2 * pi;
seam_z = z_line(kept_axial(left));

arc = radius * [theta(kept_sector); disk_theta; seam_theta];
height = [z_line(kept_axial); disk_z; seam_z];
if any(~isfinite(arc)) || any(~isfinite(height))
    error('zef:DiscSurface', 'DiSC surface parameters are not finite.');
end

% Force each disk boundary so a nearby shaft vertex cannot cut the site.
spec = local_disk_spec();
n_boundary = spec(end, 2);
n_per = 1 + sum(spec(:, 2));
n_fit = size(disk_xyz, 1) / n_per;
if n_fit ~= floor(n_fit)
    error('zef:DiscSurface', 'DiSC contact samples are not a whole number of disks.');
end
constraints = zeros(n_fit * n_boundary, 2);
for disk = 1:n_fit
    boundary = n_kept + (disk - 1) * n_per + (n_per - n_boundary + 1:n_per);
    nxt = [boundary(2:end), boundary(1)];
    constraints((disk - 1) * n_boundary + (1:n_boundary), :) = [boundary(:), nxt(:)];
end
if isempty(constraints)
    dt = delaunayTriangulation(arc, height);
else
    dt = delaunayTriangulation([arc, height], constraints);
end
tri = dt.ConnectivityList;
lookup = 1:(n_kept + n_disk + n_seam);
lookup(n_kept + n_disk + (1:n_seam)) = left;
tri = lookup(tri);
degenerate = tri(:, 1) == tri(:, 2) | tri(:, 1) == tri(:, 3) | tri(:, 2) == tri(:, 3);
tri = tri(~degenerate, :);
tri = local_orient_lateral(tri, P);
[~, first] = unique(sort(tri, 2), 'rows', 'stable');
tri = tri(first, :);

bottom = find(kept_axial == 1);
top = find(kept_axial == n_axial);
if numel(bottom) ~= n_sectors || numel(top) ~= n_sectors
    error('zef:DiscSurface', 'DiSC end rings lost a shaft sector.');
end
if ~isequal(kept_sector(bottom), (1:n_sectors)') || ~isequal(kept_sector(top), (1:n_sectors)')
    error('zef:DiscSurface', 'DiSC end rings are not in sector order.');
end

bottom_center = size(P, 1) + 1;
top_center = size(P, 1) + 2;
P = [P; 0, 0, z_line(1); 0, 0, z_line(end)];
cap_bottom = zeros(n_sectors, 3);
cap_top = zeros(n_sectors, 3);
for sector = 1:n_sectors
    nxt = mod(sector, n_sectors) + 1;
    cap_bottom(sector, :) = [bottom_center, bottom(nxt), bottom(sector)];
    cap_top(sector, :) = [top_center, top(sector), top(nxt)];
end

T = [tri; cap_bottom; cap_top];
signed_volume = sum(dot(P(T(:, 1), :), ...
    cross(P(T(:, 2), :), P(T(:, 3), :), 2), 2)) / 6;
if signed_volume < 0
    T = T(:, [1 3 2]);
end

end

function theta_cut = local_seam(angle)

angle = mod(double(angle(:)), 2 * pi);
angle = unique(round(angle, 8));
angle = sort(angle);
if numel(angle) < 2
    theta_cut = 0;
    return
end
gaps = [diff(angle); angle(1) + 2 * pi - angle(end)];
[~, which] = max(gaps);
if which < numel(angle)
    theta_cut = angle(which) + 0.5 * gaps(which);
else
    theta_cut = angle(end) + 0.5 * gaps(end);
end
theta_cut = mod(theta_cut, 2 * pi);

end

function [centers, fits] = local_centers(lattice, radius, length_mm)

n_contacts = lattice.n_physical;
centers = zeros(n_contacts, 3);
fits = false(n_contacts, 1);
for contact = 1:n_contacts
    z_center = lattice.z_center(contact);
    z_local = z_center - length_mm / 2;
    [x_center, y_center] = pol2cart(lattice.angle(contact), radius);
    centers(contact, :) = [x_center, y_center, z_local];
    fits(contact) = z_center - lattice.contact_radius >= -1e-9 ...
        && z_center + lattice.contact_radius <= length_mm + 1e-9;
end

end

function [xyz, theta, z_local] = local_disks(lattice, radius, length_mm, contact_radius, fits)

spec = local_disk_spec();
n_per = 1 + sum(spec(:, 2));
n_fit = nnz(fits);
xyz = zeros(n_fit * n_per, 3);
theta = zeros(n_fit * n_per, 1);
z_local = zeros(n_fit * n_per, 1);
cursor = 0;
for contact = find(fits)'
    angle = lattice.angle(contact);
    z_center = lattice.z_center(contact) - length_mm / 2;
    [th, zz] = local_disk_samples(angle, z_center, radius, contact_radius, spec);
    n_here = numel(th);
    xyz(cursor + (1:n_here), :) = [radius * cos(th), radius * sin(th), zz];
    theta(cursor + (1:n_here)) = th;
    z_local(cursor + (1:n_here)) = zz;
    cursor = cursor + n_here;
end
xyz = xyz(1:cursor, :);
theta = theta(1:cursor);
z_local = z_local(1:cursor);

end

function spec = local_disk_spec

spec = [0.30, 6; 0.62, 10; 1 - 1e-8, 18];

end

function [theta, z_local] = local_disk_samples(theta_center, z_center, radius, contact_radius, spec)

n_pts = 1 + sum(spec(:, 2));
theta = zeros(n_pts, 1);
z_local = zeros(n_pts, 1);
theta(1) = theta_center;
z_local(1) = z_center;
cursor = 1;
for ring = 1:size(spec, 1)
    fraction = spec(ring, 1);
    n_ring = spec(ring, 2);
    alpha = (0:n_ring - 1)' * (2 * pi / n_ring);
    if mod(ring, 2) == 0
        alpha = alpha + pi / n_ring;
    end
    arc_length = fraction * contact_radius * cos(alpha);
    dz = fraction * contact_radius * sin(alpha);
    dtheta = arc_length / radius;
    theta(cursor + (1:n_ring)) = theta_center + dtheta;
    z_local(cursor + (1:n_ring)) = z_center + dz;
    cursor = cursor + n_ring;
end

end

function tri = local_orient_lateral(tri, points)

edge_1 = points(tri(:, 2), :) - points(tri(:, 1), :);
edge_2 = points(tri(:, 3), :) - points(tri(:, 1), :);
normal = cross(edge_1, edge_2, 2);
area_2 = sum(normal .^ 2, 2);
tri = tri(area_2 > 1e-20, :);
edge_1 = points(tri(:, 2), :) - points(tri(:, 1), :);
edge_2 = points(tri(:, 3), :) - points(tri(:, 1), :);
normal = cross(edge_1, edge_2, 2);
mid = (points(tri(:, 1), :) + points(tri(:, 2), :) + points(tri(:, 3), :)) / 3;
inward = normal(:, 1) .* mid(:, 1) + normal(:, 2) .* mid(:, 2) < 0;
tri(inward, [2 3]) = tri(inward, [3 2]);

end
