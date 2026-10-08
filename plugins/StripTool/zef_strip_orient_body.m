function strip_struct = zef_strip_orient_body(strip_struct, body)
%ZEF_STRIP_ORIENT_BODY  Unit lead axis and the rotation used by the strip transform.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Fills orientation_axis, rotation_angle, rotation_axis, and
%   orientation_axis_normal for one body (1 = lead, 2 = encapsulation).
%   The formulas match the historical zef_create_strip construction: the
%   generator's +z is carried onto the unit orientation. When the shaft
%   points along -z, cross([0;0;1], axis) vanishes; the rotation axis is
%   then +x and the angle is pi, which still maps +z to -z.
%
%   strip_struct = zef_strip_orient_body(strip_struct, body)
%
%   See also zef_create_strip, zef_strip_lead_frame.

if nargin < 2 || isempty(body)
    body = 1;
end
body = body(1);
if ~isfield(strip_struct, 'orientation_axis') || numel(strip_struct.orientation_axis) < body
    error('zef:StripOrientation', ...
        'Strip body %d has no orientation axis.', body);
end
ax = double(strip_struct.orientation_axis{body});
ax = ax(:);
if numel(ax) ~= 3 || ~all(isfinite(ax)) || norm(ax) == 0
    error('zef:StripOrientation', ...
        'Strip body %d orientation must be a finite nonzero 3-vector.', body);
end
ax = ax / norm(ax);
cosine = dot([0; 0; 1], ax);
cosine = max(-1, min(1, cosine));
ang = acos(cosine);
r = cross([0; 0; 1], ax);
if norm(r) == 0
    r = [1; 0; 0];
else
    r = r / norm(r);
end
if ~(ang > 0)
    r = [1; 0; 0];
    ang = 0;
end
strip_struct.orientation_axis{body} = ax;
strip_struct.rotation_angle{body} = ang;
strip_struct.rotation_axis{body} = r;
strip_struct.orientation_axis_normal{body} = cross(r, ax);

end
