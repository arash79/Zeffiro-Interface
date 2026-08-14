%ZEF_INIT_SENSORS  Reset sensor sets to the default tag 's' (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Clears sensor_tags, sets current_sensors and current_tag to
%   's', and calls zef_create_sensors(zef,'s'). Does not fill UITables
%   (see zef_init_sensors_name_table / zef_init_sensors_table).
%
%   See also zef_create_sensors, zef_init_sensors_name_table.
zef.sensor_tags = cell(0);
zef.current_sensors = 's';
zef.current_tag = 's';
zef = zef_create_sensors(zef,'s');
