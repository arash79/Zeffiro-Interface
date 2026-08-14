function zef_sensors_name_table_selection(hObject,eventdata,handles)
%ZEF_SENSORS_NAME_TABLE_SELECTION  CellSelectionCallback for the Sensors name UITable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_segmentation_tool onto h_sensors_name_table.
%   evalin('base',...).
%
%   First selected row → zef.current_sensor_name (1-based). Then
%   zef_init_sensor_parameters fills the parameters table for that
%   sensor. Unique selected row indices go to zef.sensors_selected for
%   **Delete sensor(s)**.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_delete_sensors, zef_add_sensor_name.

sensors_selected = eventdata.Indices(1);

evalin('base', ['zef.current_sensor_name = ' num2str(sensors_selected) ';']);
evalin('base','run(''zef_init_sensor_parameters'')');

sensors_selected = eventdata.Indices(:,1);
sensors_selected = unique(sensors_selected);
sensors_selected = sensors_selected(:)';
evalin('base',['zef.sensors_selected =[' num2str(sensors_selected) '];']);

end
