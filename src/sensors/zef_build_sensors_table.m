function zef = zef_build_sensors_table(zef)
%ZEF_BUILD_SENSORS_TABLE  Populate segmentation-tool sensor table rows from zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds one row per zef.sensor_tags entry. Column layout must match
%   zef_update / zef_load / the Segmentation-tool uitable:
%     1 Index, 2 Name, 3 Modality, 4 On, 5 Visible, 6 Tags (names_visible),
%     7 Points nonempty, 8 Directions nonempty.
%   A 7-column table (Tags omitted) lets zef_update treat the leftover
%   default set name "Sensors 1" and Visible=0 as source of truth and
%   write them onto a newly prepended tag.
%
%   zef = zef_build_sensors_table(zef)
%   zef_build_sensors_table          % nargout 0 → assignin base
%
%   See also zef_create_sensors, zef_update.

if nargin == 0
    zef = evalin('base','zef');
end

if not(isfield(zef,'sensor_tags')) || not(iscell(zef.sensor_tags))
    zef.sensor_tags = {};
end

table_data = cell(length(zef.sensor_tags), 8);
for zef_i = 1 : length(zef.sensor_tags)
    tag = zef.sensor_tags{zef_i};
    table_data{zef_i,1} = zef_i;
    table_data{zef_i,2} = eval(['zef.' tag '_name']);
    table_data{zef_i,3} = eval(['zef.' tag '_imaging_method_name']);
    table_data{zef_i,4} = local_flag(eval(['zef.' tag '_on']));
    table_data{zef_i,5} = local_flag(eval(['zef.' tag '_visible']));
    table_data{zef_i,6} = local_flag(eval(['zef.' tag '_names_visible']));
    table_data{zef_i,7} = eval(['not(isempty(zef.' tag '_points))']);
    table_data{zef_i,8} = eval(['not(isempty(zef.' tag '_directions))']);
end

if isfield(zef,'h_sensors_table') && isvalid(zef.h_sensors_table)
    original_callback = zef.h_sensors_table.CellEditCallback;
    zef.h_sensors_table.CellEditCallback = '';
    zef.h_sensors_table.Data = table_data;
    zef.h_sensors_table.CellEditCallback = original_callback;
end

if nargout == 0
    assignin('base','zef',zef);
end

end

function tf = local_flag(v)
if isempty(v)
    tf = false;
else
    tf = logical(v(1));
end
end
