function zef_sensors_table_selection(hObject,eventdata,handles)
%ZEF_SENSORS_TABLE_SELECTION  CellSelectionCallback for the Sensor sets UITable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_segmentation_tool onto h_sensors_table. Unlike the
%   compartment table, sensor-set rows match zef.sensor_tags in the same
%   order (zef_build_sensors_table). evalin('base',...).
%
%   Sets zef.current_sensors and zef.current_tag to sensor_tags{row},
%   zef.imaging_method from imaging_method_cell vs that set's
%   _imaging_method_name, clears h_parameters_table, then run zef_update,
%   zef_init_transform, zef_init_sensors_name_table. Unique selected row
%   indices go to zef.sensor_sets_selected for **Delete sensor set(s)**.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_delete_sensor_sets, zef_add_sensors.

sensors_selected = eventdata.Indices(1);
sensor_tags = evalin('base','zef.sensor_tags');

imaging_method_cell = evalin('base', ['zef.imaging_method_cell']);

imaging_method_name = evalin('base', ['zef.' sensor_tags{sensors_selected} '_imaging_method_name']);
imaging_method = find(ismember(imaging_method_cell,imaging_method_name),1);
current_tag = sensor_tags{sensors_selected};

evalin('base', ['zef.current_sensors = ''' current_tag ''';']);
evalin('base', ['zef.current_tag = ''' current_tag ''';']);

evalin('base', ['zef.imaging_method = ''' imaging_method ''';']);
evalin('base','zef.h_parameters_table.Data = [];');

% if evalin('base','zef.use_cem') && evalin('base','isequal(zef.imaging_method,1)')
%     if size(evalin('base',['zef.' current_tag '_points']),2)==3
%     sensors_aux = evalin('base',['zef.' current_tag '_points']);
%     sensors_aux = [sensors_aux zeros(size(sensors_aux,1),3) ];
%     if not(evalin('base','zef.use_depth_electrodes'))
%       sensors_aux(:,5) = 1;
%     end
%     sensors_aux(:,6) = evalin('base','zef.default_impedance_value');
%     evalin('base',['zef.' current_tag '_points = reshape([' num2str(sensors_aux(:)') '],' num2str(size(sensors_aux,1)) ',' num2str(size(sensors_aux,2)) ');'])
%     end
% end

evalin('base','run(''zef_update'')');
evalin('base','run(''zef_init_transform'')');
evalin('base','run(''zef_init_sensors_name_table'')');

sensor_sets_selected = eventdata.Indices(:,1);
sensor_sets_selected = unique(sensor_sets_selected);
sensor_sets_selected = sensor_sets_selected(:)';
evalin('base',['zef.sensor_sets_selected =[' num2str(sensor_sets_selected) '];']);

end
