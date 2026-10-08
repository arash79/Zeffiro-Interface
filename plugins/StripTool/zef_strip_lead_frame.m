function local_points = zef_strip_lead_frame(strip_struct, world_points)
%ZEF_STRIP_LEAD_FRAME  Map world millimetres into the lead's generator frame.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inverse of zef_strip_coordinate_transform(..., 'reverse') for the lead
%   body only (no encapsulation shift). Local +z runs from the tip (z = 0)
%   along the shaft for strip_length. Local x and y are the generator's
%   radial coordinates, so hypot(x, y) is the distance to the lead axis
%   for an arbitrary orientation and roll.
%
%   local_points = zef_strip_lead_frame(strip_struct, world_points)
%
%   world_points is N×3. An empty input returns a 0×3 array.
%
%   See also zef_strip_coordinate_transform, zef_strip_lead_axes.

if nargin < 2 || isempty(world_points)
    local_points = zeros(0, 3);
    return
end
world_points = double(world_points);
if size(world_points, 2) ~= 3
    error('zef:StripFrame', 'World points must be N-by-3 millimetre coordinates.');
end

strip_struct = zef_strip_lead_axes(strip_struct);
tip = strip_struct.tip_point(:);
a = strip_struct.orientation_axis{1}(:);
nvec = strip_struct.orientation_axis_normal{1}(:);
r = strip_struct.rotation_axis{1}(:);
ang = strip_struct.strip_angle;
rot = strip_struct.rotation_angle{1};

centered = world_points - tip.';
comp = centered * [a, nvec, r];
ca = cos(ang);
sa = sin(ang);
cr = cos(rot);
sr = sin(rot);
R2 = [cr, sr, 0; -sr, cr, 0; 0, 0, 1];
R1 = [1, 0, 0; 0, ca, sa; 0, -sa, ca];
comp = comp * (R1 * R2).';
local_points = comp * [a, nvec, r].';

end
