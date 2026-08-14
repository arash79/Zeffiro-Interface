%ZEF_REMOVE_SYSTEM_FIELDS  Strip machine/session fields from zef_data before save.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script used by project save. Reads profile/zeffiro_interface.ini column 3
%   as system field names, unions a hard-coded list (gpu_count, start_mode,
%   path_cell, …), and rmfield's those keys from zef_data. save_file and
%   save_file_path are kept. Temporary zef.fields_to_be_removed is removed.
%
%   Workspace
%     zef       - session; program_path required.
%     zef_data  - struct that will be written to the .mat project.
%
%   See also zef_save.
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
