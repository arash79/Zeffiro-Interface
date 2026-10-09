function zef_mark_sensor_graphic(graphic, sensors_visible, filtered_index)
%ZEF_MARK_SENSOR_GRAPHIC  Stamp a Figure-tool electrode glyph with its row.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   filtered_index is the row in the sensor list the plotter is drawing
%   (after visibility and clipping). sensors_visible maps that row back
%   to the project contact index. Strip-tool deletion reads UserData so
%   it can remove one lead's glyphs and leave every other electrode.
%
%   zef_mark_sensor_graphic(graphic, sensors_visible, filtered_index)
%
%   See also zef_sensor_draw_indices, zef_strip_tool_delete.

if isempty(graphic) || isempty(filtered_index)
    return
end
filtered_index = double(filtered_index(1));
if ~isscalar(filtered_index) || ~isfinite(filtered_index) || filtered_index ~= floor(filtered_index)
    return
end
if isempty(sensors_visible)
    sensor_index = filtered_index;
else
    sensors_visible = double(sensors_visible(:));
    if filtered_index < 1 || filtered_index > numel(sensors_visible)
        return
    end
    sensor_index = sensors_visible(filtered_index);
end
if isempty(sensor_index) || ~isscalar(sensor_index)
    return
end
for index = 1:numel(graphic)
    if isgraphics(graphic(index))
        graphic(index).UserData = struct('sensor_index', sensor_index);
    end
end
end
