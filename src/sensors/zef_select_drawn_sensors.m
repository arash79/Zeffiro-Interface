function [sensors, sensors_name, sensors_color_table, sensors_get_functions, sensors_visible] = zef_select_drawn_sensors(zef, sensor_tag, sensors, sensors_get_functions)
%ZEF_SELECT_DRAWN_SENSORS  Apply contact visibility and canonical annotations.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   sensors_name is the figure annotation for each surviving row ("1", "2",
%   ... for an electrode set). sensors_visible holds the original row
%   indices so later clipping can subset it with the filtered arrays.
%
%   See also zef_sensor_contact_presentation, zef_sensor_draw_indices.

if nargin < 4 || isempty(sensors_get_functions)
    sensors_get_functions = {};
end
n = size(sensors, 1);
visible_list = [];
field = [sensor_tag '_visible_list'];
if isfield(zef, field)
    visible_list = zef.(field);
end
[~, sensors_name] = zef_sensor_contact_presentation(zef, sensor_tag, n);
sensors_visible = zef_sensor_draw_indices(visible_list, n);
color_field = [sensor_tag '_color_table'];
if isfield(zef, color_field)
    sensors_color_table = zef.(color_field);
else
    sensors_color_table = [];
end
if isempty(sensors_visible)
    if n > 0
        sensors = sensors([], :);
    end
    sensors_name = {};
    if ~isempty(sensors_color_table)
        sensors_color_table = sensors_color_table([], :);
    end
    sensors_get_functions = {};
    return
end
sensors = sensors(sensors_visible, :);
sensors_name = sensors_name(sensors_visible);
if ~isempty(sensors_color_table)
    n_color = size(sensors_color_table, 1);
    color_idx = sensors_visible(sensors_visible <= n_color);
    if numel(color_idx) == numel(sensors_visible)
        sensors_color_table = sensors_color_table(sensors_visible, :);
    end
end
if ~isempty(sensors_get_functions)
    sensors_get_functions = sensors_get_functions(sensors_visible);
end

end
