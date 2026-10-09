function strip_struct = zef_create_strip(strip_struct)
%ZEF_CREATE_STRIP  Two cylinders (strip + encapsulation) aligned to orientation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   strip_struct = zef_create_strip(strip_struct)
%
%   zef_get_strip_parameters, then the shaft surface and the
%   encapsulation cylinder. Models 4 and 5 use zef_strip_disc_surface
%   so each physical site is a face of the shaft. Models 1–3 keep
%   zef_simple_cylinder_generator. Shifts z so the strip sits on
%   [0,length]. Fills rotation_axis/angle from orientation_axis vs
%   [0;0;1]. Does not embed into zef compartments
%   (zef_strip_tool_embed).
%
%   See also zef_get_strip_parameters, zef_strip_disc_surface, zef_strip_tool_embed.

strip_struct = zef_get_strip_parameters(strip_struct);
if ismember(strip_struct.strip_model, [4 5])
    [triangles{1}, points{1}] = zef_strip_disc_surface(strip_struct);
else
    [triangles{1}, points{1}] = zef_simple_cylinder_generator(strip_struct.strip_radius,strip_struct.strip_n_sectors,strip_struct.strip_length);
end
[triangles{2}, points{2}] = zef_simple_cylinder_generator(strip_struct.strip_radius+strip_struct.encapsulation_thickness,strip_struct.strip_n_sectors,strip_struct.encapsulation_length+2*strip_struct.encapsulation_thickness);
points{1}(:,3) = points{1}(:,3) + strip_struct.strip_length/2;
points{2}(:,3) = points{2}(:,3) + strip_struct.strip_length/2 - strip_struct.encapsulation_thickness;
strip_struct.points = points;
strip_struct.triangles = triangles;

for i = 1 : 2
    % Shared with the burr-hole frame so the cylinder stays concentric
    % with this lead, including a shaft aimed along -z (cross([0;0;1], axis)
    % is then zero and the historical 1/norm would be NaN).
    strip_struct = zef_strip_orient_body(strip_struct, i);
end

end
