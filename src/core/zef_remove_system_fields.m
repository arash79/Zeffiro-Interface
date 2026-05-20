% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Zef fields (observed):
%   zef.fields_to_be_removed (read)
%   zef.ini_cell (read, write)
%   zef.program_path (read)
%   zef.system_fields (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.fields_to_be_removed = {'gpu_count','compartment_activity','start_mode','colormap_cell','path_cell','use_display','current_version','matfile_object','zeffiro_restart','verbose_mode','use_waitbar','zeffiro_task_id'};

zef.ini_cell = readcell([zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
zef.system_fields = zef.ini_cell(:,3);
zef.system_fields = setdiff(zef.system_fields,{'save_file','save_file_path'});
zef.system_fields = [zef.system_fields; zef.fields_to_be_removed'];
for zef_i  =  1 : length(zef.system_fields)
    if isfield(zef_data,zef.system_fields{zef_i});
        zef_data = rmfield(zef_data,zef.system_fields{zef_i});
    end
end

zef = rmfield(zef,'fields_to_be_removed');
