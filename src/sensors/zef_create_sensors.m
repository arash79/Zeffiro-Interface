function zef = zef_create_sensors(zef,sensor_tag,field_cell_update)
%ZEF_CREATE_SENSORS  Ensure default fields exist for one sensor tag.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Initializes missing zef.<tag>_* sensor fields (points, directions,
%   imaging method name, electrode geometry defaults, get_functions, etc.)
%   and prepends sensor_tag to zef.sensor_tags when new. Sets
%   zef.current_sensors for legacy tags 's' and 's1'.
%
%   zef = zef_create_sensors(zef, sensor_tag)
%   zef = zef_create_sensors(zef, sensor_tag, field_cell_update)
%
%   Inputs
%     zef               - session struct.
%     sensor_tag        - short tag (e.g. 's1').
%     field_cell_update - optional {{name, expr}, ...} field overrides.
%
%   Output
%     zef - session with sensor fields defined.
%
%   See also zef_build_sensors_table, zef_fix_sensors_get_functions_array_size.

if isequal(sensor_tag,'s') || isequal(sensor_tag,'s1')
    eval(['zef.current_sensors =''' sensor_tag ''';']);
end
zef_struct_name = 'zef';
if nargin == 2
    field_cell_update = cell(0);
end

field_cell_default =  {{'on', '1'}
    {'color', '[0.1 0.1 0.1]'}
    {'visible', '0'   }
    {'directions', '[]' }
    {'points'  , '[]'  }
    {'merge'  , '0'  }
    {'invert'  , '0'  }
    {'name'    , ['[''Sensors ''  num2str(length(' zef_struct_name '.sensor_tags) + 1)]'] }
    {'scaling'  , '1'   }
    {'zx_rotation', '0' }
    {'yz_rotation', '0' }
    {'xy_rotation', '0' }
    {'z_correction', '0'}
    {'y_correction', '0'}
    {'x_correction', '0'}
    {'affine_transform','{[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]}'}
    {'transform_name','{''Transform 1''}'}
    {'imaging_method_name',['''' eval([zef_struct_name '.imaging_method_cell{' zef_struct_name '.imaging_method}' ]) '''']}
    {'name_list','[]'}
    {'visible_list','[]'}
    {'names_visible','1'}
    {'color_table','[]'}
    {'electrode_impedance', '2000'}
    {'electrode_inner_radius', '2'}
    {'electrode_outer_radius', '5'}
{'get_functions','cell(0)'}
 {'electrode_surface_index','1'}};

for i = 1 : length(field_cell_default)

    if eval(['not(isfield(' zef_struct_name ',''' sensor_tag '_' field_cell_default{i}{1} '''));']) 
    eval([zef_struct_name '.' sensor_tag '_' field_cell_default{i}{1} '=' field_cell_default{i}{2} ';' ]);
    end
end

for i = 1 : length(field_cell_update)

    eval([zef_struct_name '.' sensor_tag '_' field_cell_update{i}{1} '=[' field_cell_update{i}{2} '];' ]);

end

if eval(['not(ismember(''' sensor_tag ''', ' zef_struct_name '.sensor_tags));'])
eval([zef_struct_name '.sensor_tags = ['''  sensor_tag ''', ' zef_struct_name '.sensor_tags];']);
end

end
