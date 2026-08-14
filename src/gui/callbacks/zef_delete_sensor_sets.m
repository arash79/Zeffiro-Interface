function zef = zef_delete_sensor_sets(zef)
%ZEF_DELETE_SENSOR_SETS  Drop selected *inactive* sensor-set table rows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click Sensor sets → **Delete sensor set(s)**
%   (h_menu_delete_sensor_sets; MenuSelectedFcn "zef_delete_sensor_sets;").
%   Rows come from zef.sensor_sets_selected (set by
%   zef_sensors_table_selection). Only rows with column 4 **On** false
%   are flagged. zef_delete_all_compartments also calls this after
%   turning every set off.
%
%   zef = zef_delete_sensor_sets(zef)
%   zef_delete_sensor_sets          % nargout 0 → assignin base
%
%   Input
%     zef  - session. Omitted → evalin('base','zef').
%
%   For each selected inactive row, column 1 (Index) is used as a linear
%   index into h_sensors_table.Data and that cell is set to NaN.
%   zef_update then rmfields zef.<tag>_* for those tags.
%
%   See also zef_add_sensors, zef_sensors_table_selection, zef_update.

if nargin == 0
    zef = evalin('base','zef');
end

table_data = eval('zef.h_sensors_table.Data');
sensor_sets_selected = eval('zef.sensor_sets_selected');

for i = 1 : length(sensor_sets_selected)
    if not(table_data{sensor_sets_selected(i),4})
        % Column 4 On must be false; column 1 Index → NaN delete flag.
        eval(['zef.h_sensors_table.Data{' num2str(table_data{sensor_sets_selected(i),1}) '} = NaN;'])
    end
end

zef = zef_update(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
