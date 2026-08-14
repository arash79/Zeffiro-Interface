%ZEF_TOGGLE_LOCK_SENSOR_NAMES_ON  Sync Sensors name-table editability with lock_sensor_names_on.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click Sensors → **Lock on** (h_menu_lock_sensor_names_on).
%   MenuSelectedFcn flips lock_sensor_names_on then runs this script.
%   **Add sensor** / **Delete sensor(s)** also no-op while locked.
%
%   Script. Expects zef in the caller.
%
%     lock_sensor_names_on == 0: all columns editable; menu
%       "Toggle unlocked", black.
%     lock_sensor_names_on == 1: all columns read-only except column 3
%       (Visible); menu "Toggle locked", red.
%
%   See also zef_add_sensor_name, zef_delete_sensors.

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
