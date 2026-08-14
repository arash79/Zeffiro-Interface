%ZEF_BUILD_SENSORS_TABLE  Populate segmentation-tool sensor table rows from zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds zef.aux_field_1 with index, name, imaging method, on/visible
%   flags, and non-empty points/directions indicators for each
%   zef.sensor_tags entry, then assigns zef.h_sensors_table.Data.
%
%   See also zef_create_sensors, zef_update.

for zef_i = 1 : length(zef.sensor_tags)
    zef.aux_field_1{zef_i,1} = zef_i;
    zef.aux_field_1{zef_i,2} = eval(['zef.' zef.sensor_tags{zef_i} '_name']);
    zef.aux_field_1{zef_i,3} = eval(['zef.' zef.sensor_tags{zef_i} '_imaging_method_name']);
    zef.aux_field_1{zef_i,4} = eval(['zef.' zef.sensor_tags{zef_i} '_on']);
    zef.aux_field_1{zef_i,5} = eval(['zef.' zef.sensor_tags{zef_i} '_visible']);
    zef.aux_field_1{zef_i,6} = eval(['not(isempty(zef.' zef.sensor_tags{zef_i} '_points))']);
    zef.aux_field_1{zef_i,7} = eval(['not(isempty(zef.' zef.sensor_tags{zef_i} '_directions))']);
end
zef.h_sensors_table.Data = zef.aux_field_1;
