function zef_data = zef_remove_system_fields(zef, zef_data)
%ZEF_REMOVE_SYSTEM_FIELDS  Strip machine/session fields from zef_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by project save and project load. Reads profile/zeffiro_interface.ini
%   column 3 as system field names, unions a hard-coded list (gpu_count,
%   start_mode, path_cell, …), and rmfield's those keys from zef_data.
%   save_file and save_file_path are kept.
%
%   zef_data = zef_remove_system_fields(zef, zef_data)
%
%   Inputs
%     zef      - session; program_path required to locate the profile INI.
%     zef_data - struct that will be written to / was read from a .mat project.
%
%   See also zef_save, zef_load.

arguments
    zef (1,1) struct
    zef_data (1,1) struct
end

fields_to_be_removed = {'gpu_count','compartment_activity','start_mode','colormap_cell','path_cell','use_display','current_version','matfile_object','zeffiro_restart','verbose_mode','use_waitbar','zeffiro_task_id','use_github'};

ini_cell = readcell([zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
system_fields = ini_cell(:,3);
system_fields = setdiff(system_fields,{'save_file','save_file_path'});
system_fields = [system_fields; fields_to_be_removed'];
fn = fieldnames(zef_data);
github_leftovers = fn(startsWith(fn, 'github_updater_'));
system_fields = [system_fields; github_leftovers];
for i = 1:length(system_fields)
    if isfield(zef_data, system_fields{i})
        zef_data = rmfield(zef_data, system_fields{i});
    end
end

end
