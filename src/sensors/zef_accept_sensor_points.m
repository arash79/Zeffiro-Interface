function zef = zef_accept_sensor_points(zef, tag)
%ZEF_ACCEPT_SENSOR_POINTS  Show a sensor set after the user imports coordinates.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Importing a point file is the decision that these contacts exist.
%   The factory "visible off, no contact flags" state is replaced with
%   one visible flag per point. An electrode set also shows index labels.
%   Stored names and coordinates are not edited.
%
%   zef = zef_accept_sensor_points(zef, tag)

if nargin < 2 || ~isstruct(zef) || isempty(tag)
    return
end
field = [tag '_points'];
if ~isfield(zef, field)
    return
end
n = size(zef.(field), 1);
if n < 1
    return
end
zef.([tag '_visible']) = 1;
zef.([tag '_visible_list']) = ones(n, 1);
if zef_sensor_set_is_electrodes(zef, tag)
    zef.([tag '_names_visible']) = 1;
end
if nargout == 0
    assignin('base', 'zef', zef);
end

end
