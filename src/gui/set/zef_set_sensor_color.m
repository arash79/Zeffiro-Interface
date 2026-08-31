function zef_set_sensor_color
%ZEF_SET_SENSOR_COLOR  Figure-tool **Sensors:** list ButtonDownFcn.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. uisetcolor; list indices match rows of current_sensors
%   _points / _color_table (same order zef_sensor_list_items used).
%
%   See also zef_update_fig_details, zef_sensor_list_items.

color_vec = uisetcolor;
item_ind_1 = zef_colored_list('value', evalin('base','zef.h_sensor_visible_color'));
if isempty(item_ind_1) || isequal(color_vec, 0)
    return
end
current_sensors = evalin('base','zef.current_sensors');
points = evalin('base', ['zef.' current_sensors '_points']);
n_pts = size(points, 1);

for zef_k = 1 : length(item_ind_1)
    item_ind_2 = item_ind_1(zef_k);
    if item_ind_2 < 1 || item_ind_2 > n_pts
        continue
    end
    evalin('base',['zef.' current_sensors '_color_table(' num2str(item_ind_2) ',:) = [' num2str(color_vec) '];']);
end
end
