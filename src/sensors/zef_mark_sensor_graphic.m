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
%   A graphics object is stamped with dot assignment. A numeric handle
%   (from storing trisurf/surf in a double array) is stamped with set.
%   The root handle 0 is ignored: isgraphics(0) is true.
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
payload = struct('sensor_index', sensor_index);
for index = 1:numel(graphic)
    item = graphic(index);
    % h = zeros(...) then h(i) = trisurf/surf stores a numeric handle.
    % isgraphics accepts that double, and also accepts 0 (the root).
    % Dot assignment only works on a graphics object; set() accepts the
    % numeric handle. Never stamp the root.
    if isnumeric(item)
        if isempty(item) || ~isscalar(item) || item == 0 || ~isgraphics(item)
            continue
        end
        set(item, 'UserData', payload);
    elseif isgraphics(item)
        item.UserData = payload;
    end
end
end
