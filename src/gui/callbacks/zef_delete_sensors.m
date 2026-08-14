function zef_delete_sensors
%ZEF_DELETE_SENSORS  Drop selected rows from the Sensors name table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click the Sensors UITable → **Delete sensor(s)**
%   (h_menu_delete_sensors; MenuSelectedFcn "zef_delete_sensors;").
%   Rows come from zef.sensors_selected (set by
%   zef_sensors_name_table_selection). Does nothing when
%   lock_sensor_names_on is true.
%
%   Function with no arguments. Reads/writes zef via evalin('base',...).
%
%   For each selected row, column 1 (Index) of that row is used as a
%   linear index into h_sensors_name_table.Data and that cell is set to
%   NaN. zef_update_sensors_name_table then drops NaN-index rows and
%   rebuilds <current_sensors>_points / _name_list / profile arrays.
%
%   See also zef_add_sensor_name, zef_sensors_name_table_selection.

if not(evalin('base','zef.lock_sensor_names_on'))

    table_data = evalin('base','zef.h_sensors_name_table.Data');
    sensors_selected = evalin('base','zef.sensors_selected');

    for i = 1 : length(sensors_selected)
        % Column 1 Index as linear index → NaN delete flag for zef_update_sensors_name_table.
        evalin('base',['zef.h_sensors_name_table.Data{' num2str(table_data{sensors_selected(i),1}) '} = NaN;'])
    end

    evalin('base','run(''zef_update_sensors_name_table'')');

end

end
