function [triangles, points] = zef_strip_burr_surface(strip_struct, radius_mm)
%ZEF_STRIP_BURR_SURFACE  Closed cylinder surface concentric with the lead.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Preview geometry only. The computational assignment uses the analytic
%   cylinder in zef_strip_burr_pick, not this triangulation. The surface
%   is the same length as the strip and is placed with the lead transform.
%   Radii below 0.05 mm are not tessellated (the generator's step would
%   collapse); the analytic test still accepts them.
%
%   [triangles, points] = zef_strip_burr_surface(strip_struct, radius_mm)
%
%   See also zef_strip_tool_plot, zef_simple_cylinder_generator.

triangles = zeros(0, 3);
points = zeros(0, 3);
if ~isscalar(radius_mm) || ~isfinite(double(radius_mm)) || double(radius_mm) < 0.05
    return
end
strip_struct = zef_strip_lead_axes(strip_struct);
length_mm = strip_struct.strip_length;
if ~isfinite(length_mm) || length_mm <= 0
    return
end
[triangles, points] = zef_simple_cylinder_generator(double(radius_mm), 18, length_mm);
points(:, 3) = points(:, 3) + length_mm / 2;
aux = strip_struct;
aux.encapsulation_on = 0;
aux.points = {points};
world = zef_strip_coordinate_transform(aux, 'forward');
points = world{1};

end
