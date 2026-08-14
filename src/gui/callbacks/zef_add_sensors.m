%ZEF_ADD_SENSORS  Append a sensor-set row (new tag sN) to the Segmentation sensors table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   A sensor set is one modality list (EEG electrodes, MEG coils, …) with
%   its own points/directions. Right-click the Sensor sets UITable →
%   **Add sensor set** (h_menu_add_sensor_sets; MenuSelectedFcn in
%   zef_menu_tool is the string "zef_add_sensors;").
%
%   Script (not a function). Mutates zef in the caller workspace.
%
%   What it does
%     1. zef_create_sensors(zef, 's'+N) with N = length(sensor_tags)+1.
%        That prepends the tag to zef.sensor_tags and fills zef.<tag>_*
%        defaults (on, name "Sensors N", empty points/directions,
%        identity affine, imaging_method_name from zef.imaging_method).
%     2. Clears zef.aux_field_1.
%     3. zef_build_sensors_table rebuilds h_sensors_table.Data.
%
%   The new set has no sensors until you right-click the Sensors table →
%   **Add sensor**, or Import → Import electrodes.
%
%   Scripting: with zef in the workspace, run zef_add_sensors (no output).
%
%   See also zef_delete_sensor_sets, zef_create_sensors, zef_add_sensor_name.

zef = zef_create_sensors(zef,['s' num2str(length(zef.sensor_tags) + 1)]);
zef.aux_field_1 = cell(0);
zef_build_sensors_table;
