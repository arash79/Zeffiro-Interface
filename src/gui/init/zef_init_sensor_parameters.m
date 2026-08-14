%ZEF_INIT_SENSOR_PARAMETERS  Load h_parameters_table for the selected sensor (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Required: zef.current_sensor_name (row index) and
%   zef.current_sensors. Columns written: Parameter name, Value.
%   Imaging method cell{1}: X/Y/Z-coordinate (points 1:3).
%   cell{2}: plus X/Y/Z-direction (directions 1:3).
%   cell{3}: plus X/Y/Z-gradient (directions 4:6).
%   Then enabled Sensors parameter-profile rows. Sets
%   current_parameters='sensor' so zef_update_parameters knows the map.
%
%   See also zef_update_parameters, zef_init_sensors_parameter_profile.
zef.aux_data_1 = cell(0);
zef_i = evalin('base','zef.current_sensor_name');

zef_init_sensors_parameter_profile;

if ismember(evalin('base',['zef.'  zef.current_sensors '_imaging_method_name']),evalin('base',['zef.imaging_method_cell{1}']))
    zef.aux_data_2 = {
        {'X-coordinate','points','1'}
        {'Y-coordinate','points','2'}
        {'Z-coordinate','points','3'}};

elseif ismember(evalin('base',['zef.'  zef.current_sensors '_imaging_method_name']),evalin('base',['zef.imaging_method_cell{2}']))

    zef.aux_data_2 = {
        {'X-coordinate','points','1'}
        {'Y-coordinate','points','2'}
        {'Z-coordinate','points','3'}
        {'X-direction','directions','1'}
        {'Y-direction','directions','2'}
        {'Z-direction','directions','3'}};

elseif ismember(evalin('base',['zef.'  zef.current_sensors '_imaging_method_name']),evalin('base',['zef.imaging_method_cell{3}']));

    zef.aux_data_2 = {
        {'X-coordinate','points','1'}
        {'Y-coordinate','points','2'}
        {'Z-coordinate','points','3'}
        {'X-direction','directions','1'}
        {'Y-direction','directions','2'}
        {'Z-direction','directions','3'}
        {'X-gradient','directions','4'}
        {'Y-gradient','directions','5'}
        {'Z-gradient','directions','6'}};
end

for zef_j = 1 : size(zef.parameter_profile,1)

    if isequal(zef.parameter_profile{zef_j,8},'Sensors') && isequal(zef.parameter_profile{zef_j,6},'On') && isequal(zef.parameter_profile{zef_j,7},'On')
        zef.aux_data_2{size(zef.aux_data_2,1)+1} = {zef.parameter_profile{zef_j,1},zef.parameter_profile{zef_j,2},'1'};
    end

end

for zef_j = 1 : length(zef.aux_data_2)

    zef.aux_data_1{zef_j,1} = zef.aux_data_2{zef_j}{1};
    zef.aux_data_1{zef_j,2} = evalin('base',['zef.' zef.current_sensors '_' zef.aux_data_2{zef_j}{2} '(' num2str(zef_i) ',' zef.aux_data_2{zef_j}{3} ')']);

end

zef.h_parameters_table.Data = zef.aux_data_1;

zef.current_parameters = 'sensor';

zef = rmfield(zef,{'aux_data_1','aux_data_2'});
clear zef_i zef_j;
