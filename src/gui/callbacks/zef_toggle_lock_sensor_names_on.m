% --- Zeffiro documentation header ---
% if isequal(zef — If isequal(zef.
%
% Purpose:
%   If isequal(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_menu_lock_sensor_names_on (read)
%   zef.h_sensors_name_table (read)
%   zef.lock_sensor_names_on (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isequal(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if isequal(zef.lock_sensor_names_on,0)
    zef.h_sensors_name_table.ColumnEditable = logical(ones(1,size(zef.h_sensors_name_table.Data,2)));
    zef.h_menu_lock_sensor_names_on.Text = 'Toggle unlocked';
    zef.h_menu_lock_sensor_names_on.ForegroundColor = [0 0 0];
elseif isequal(zef.lock_sensor_names_on,1)
    zef.h_sensors_name_table.ColumnEditable = logical(zeros(1,size(zef.h_sensors_name_table.Data,2)));
    zef.h_sensors_name_table.ColumnEditable(3) = logical(1);
    zef.h_menu_lock_sensor_names_on.Text = 'Toggle locked';
    zef.h_menu_lock_sensor_names_on.ForegroundColor = [1 0 0];
end
