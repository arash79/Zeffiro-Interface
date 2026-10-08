function strip_struct = zef_strip_lead_axes(strip_struct)
%ZEF_STRIP_LEAD_AXES  Lead radius and body-1 rotation, without building a mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_get_strip_parameters fills strip_radius from the lead model.
%   zef_strip_orient_body fills the same rotation fields zef_create_strip
%   uses for the lead, so a burr-hole cylinder shares the implanted shaft.
%   Encapsulation (body 2) is left untouched.
%
%   strip_struct = zef_strip_lead_axes(strip_struct)
%
%   See also zef_strip_orient_body, zef_create_strip, zef_strip_lead_frame.

if ~isfield(strip_struct, 'strip_model')
    strip_struct.strip_model = [];
end
strip_struct = zef_get_strip_parameters(strip_struct);
strip_struct = zef_strip_orient_body(strip_struct, 1);

if ~isfield(strip_struct, 'strip_angle') || isempty(strip_struct.strip_angle) ...
        || ~isscalar(strip_struct.strip_angle) || ~isfinite(double(strip_struct.strip_angle))
    strip_struct.strip_angle = 0;
else
    strip_struct.strip_angle = double(strip_struct.strip_angle);
end

if ~isfield(strip_struct, 'tip_point') || numel(strip_struct.tip_point) < 3
    error('zef:StripTip', ...
        'The lead tip must be a finite 3-vector in millimetres.');
end
tip = double(strip_struct.tip_point(:));
if numel(tip) ~= 3 || ~all(isfinite(tip))
    error('zef:StripTip', ...
        'The lead tip must be a finite 3-vector in millimetres.');
end
strip_struct.tip_point = tip;

if ~isfield(strip_struct, 'strip_length') || isempty(strip_struct.strip_length) ...
        || ~isscalar(strip_struct.strip_length) || ~isfinite(double(strip_struct.strip_length))
    error('zef:StripLength', ...
        'The strip length must be a finite length in millimetres.');
end
strip_struct.strip_length = double(strip_struct.strip_length);

end
