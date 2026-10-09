function [triangle_ind, center] = zef_strip_disc_patch(strip_struct, physical_index)
%ZEF_STRIP_DISC_PATCH  Triangles of one physical DiSC site.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [triangle_ind, center] = zef_strip_disc_patch(strip_struct, physical_index)
%
%   strip_struct.points{1} must already be in the cylinder frame
%   (tip at z = 0, axis +z, before strip_angle). A triangle belongs
%   to the site when all three vertices lie in the lithographic disk
%   after unwrapping: (R*dtheta)^2 + dz^2 <= contact_radius^2.
%   That is the planar circle carried onto the cylinder by arc
%   length, which is the wrap Shores et al. 2026 use
%   (theta = 2*pi*x_planar/circumference).
%
%   See also zef_strip_disc_lattice, zef_get_strip_contacts.

lattice = zef_strip_disc_lattice(strip_struct.strip_model, strip_struct.strip_radius);
physical_index = double(physical_index);
if ~isscalar(physical_index) || physical_index ~= floor(physical_index) ...
        || physical_index < 1 || physical_index > lattice.n_physical
    error('zef:DiscSite', ...
        'DiSC physical site %s is outside the %d sites.', ...
        mat2str(physical_index), lattice.n_physical);
end

angle = lattice.angle(physical_index);
z_center = lattice.z_center(physical_index);
center = [lattice.shaft_radius * cos(angle), ...
    lattice.shaft_radius * sin(angle), z_center];

points = strip_struct.points{1};
triangles = strip_struct.triangles{1};
if isempty(points) || isempty(triangles)
    triangle_ind = zeros(0, 1);
    return
end

dtheta = atan2(sin(atan2(points(:, 2), points(:, 1)) - angle), ...
    cos(atan2(points(:, 2), points(:, 1)) - angle));
arc = lattice.shaft_radius * dtheta;
dz = points(:, 3) - z_center;
radial = hypot(points(:, 1), points(:, 2));
inside = (arc .^ 2 + dz .^ 2) <= lattice.contact_radius ^ 2 ...
    & radial > 0.5 * lattice.shaft_radius;
point_ind = find(inside);
if isempty(point_ind)
    triangle_ind = zeros(0, 1);
    return
end
triangle_ind = find(sum(ismember(triangles, point_ind), 2) == 3);

end
