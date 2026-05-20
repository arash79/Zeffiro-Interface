% --- Zeffiro documentation header ---
% function zef_delete_sensors — Function zef delete sensors.
%
% Purpose:
%   Function zef delete sensors.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_sensors_name_table (read)
%   zef.lock_sensor_names_on (read)
%   zef.sensors_selected (read)
%
% Calls (project):
%   zef_delete_sensors
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_delete_sensors` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_delete_sensors


if not(evalin('base','zef.lock_sensor_names_on'))

    table_data = evalin('base','zef.h_sensors_name_table.Data');
    sensors_selected = evalin('base','zef.sensors_selected');

    for i = 1 : length(sensors_selected)
        evalin('base',['zef.h_sensors_name_table.Data{' num2str(table_data{sensors_selected(i),1}) '} = NaN;'])
    end

    evalin('base','run(''zef_update_sensors_name_table'')');

end

end
