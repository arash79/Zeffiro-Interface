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
%   zef_get_strip_parameters then zef_simple_cylinder_generator twice
%   (strip_radius vs radius+encapsulation_thickness). Shifts z so the
%   strip sits on [0,length]. Fills rotation_axis/angle from
%   orientation_axis vs [0;0;1]. Does not embed into zef compartments
%   (zef_strip_tool_embed).
%
%   See also zef_get_strip_parameters, zef_strip_tool_embed.

strip_struct = zef_get_strip_parameters(strip_struct);
[triangles{1}, points{1}] = zef_simple_cylinder_generator(strip_struct.strip_radius,strip_struct.strip_n_sectors,strip_struct.strip_length);
[triangles{2}, points{2}] = zef_simple_cylinder_generator(strip_struct.strip_radius+strip_struct.encapsulation_thickness,strip_struct.strip_n_sectors,strip_struct.encapsulation_length+2*strip_struct.encapsulation_thickness);
points{1}(:,3) = points{1}(:,3) + strip_struct.strip_length/2;
points{2}(:,3) = points{2}(:,3) + strip_struct.strip_length/2 - strip_struct.encapsulation_thickness;
strip_struct.points = points;
strip_struct.triangles = triangles;

for i = 1 : 2

    strip_struct.orientation_axis{i} = 1/norm(strip_struct.orientation_axis{i})*strip_struct.orientation_axis{i};

    strip_struct.rotation_angle{i} = acos(dot([0 ; 0 ; 1], strip_struct.orientation_axis{i}));
    if strip_struct.rotation_angle{i} > 0
    strip_struct.rotation_axis{i} = cross([0 ; 0 ; 1], strip_struct.orientation_axis{i});
    else 
    strip_struct.rotation_axis{i} = [1; 0 ; 0];
    end
    strip_struct.rotation_axis{i} = 1/norm(strip_struct.rotation_axis{i})*strip_struct.rotation_axis{i};
    strip_struct.orientation_axis_normal{i} = cross(strip_struct.rotation_axis{i}, strip_struct.orientation_axis{i});
   
end

end
