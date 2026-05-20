% --- Zeffiro documentation header ---
% for zef_i = 1 : length(zef — For zef i = 1 : length(zef.
%
% Purpose:
%   For zef i = 1 : length(zef.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Zef fields (observed):
%   zef.aux_field_1 (read)
%   zef.h_sensors_table (read)
%   zef.sensor_tags (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `for zef_i = 1 : length(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
