% --- Zeffiro documentation header ---
% [zef.file,zef.file_path] = uigetfile('* — [zef.file,zef.file path] = uigetfile('*.
%
% Purpose:
%   [zef.file,zef.file path] = uigetfile('*.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.current_sensors (read)
%   zef.file (read)
%   zef.file_path (read)
%   zef.h_aux (read, write)
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef.file,zef.file_path] = uigetfile('*` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.file,zef.file_path] = uigetfile('*.dat');

if not(isequal(zef.file,0))

    zef.h_aux = fopen([zef.file_path '/' zef.file]);
    zef.aux_field = textscan(zef.h_aux,'%s');

    for zef_i = 1 : length(zef.aux_field{1})
        evalin('base',['zef.' zef.current_sensors '_name_list{' num2str(zef_i) '} = ''' zef.aux_field{1}{zef_i} ''';']);
    end

    zef_init_sensors_name_table;

end

zef = rmfield(zef,{'h_aux','aux_field'});

clear zef_i;
