%ZEF_TOGGLE_LOCK_SENSOR_SETS_ON  Sync sensor-set **On** editability with lock_sensor_sets_on.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click Sensor sets → **Lock on** (h_menu_lock_sensor_sets_on).
%   MenuSelectedFcn flips lock_sensor_sets_on then runs this script.
%
%   Script. Expects zef in the caller.
%
%     lock_sensor_sets_on == 0: all columns editable; menu
%       "Toggle 'On' unlocked", black.
%     lock_sensor_sets_on == 1: all columns stay editable except column 4
%       (**On**), which is read-only; menu "Toggle 'On' locked", red.
%
%   See also zef_delete_sensor_sets, zef_add_sensors.

if isequal(zef.lock_sensor_sets_on,0)
    zef.h_sensors_table.ColumnEditable = logical(ones(1,size(zef.h_sensors_table.Data,2)));
    zef.h_menu_lock_sensor_sets_on.Text = 'Toggle ''On'' unlocked';
    zef.h_menu_lock_sensor_sets_on.ForegroundColor = [0 0 0];
elseif isequal(zef.lock_sensor_sets_on,1)
    zef.h_sensors_table.ColumnEditable = logical(ones(1,size(zef.h_sensors_table.Data,2)));
    zef.h_sensors_table.ColumnEditable(4) = logical(0);
    zef.h_menu_lock_sensor_sets_on.Text = 'Toggle ''On'' locked';
    zef.h_menu_lock_sensor_sets_on.ForegroundColor = [1 0 0];
end
