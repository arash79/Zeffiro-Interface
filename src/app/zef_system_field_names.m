function names = zef_system_field_names(zef, candidates)
%ZEF_SYSTEM_FIELD_NAMES  Machine and session fields excluded from projects.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   names = zef_system_field_names(zef)
%   names = zef_system_field_names(zef, candidates)
%
%   The list is column 3 of profile/zeffiro_interface.ini, without
%   save_file and save_file_path, plus a fixed set (gpu_count,
%   start_mode, path_cell, ui_color_mode, and the rest). When candidates
%   is given, names that start with github_updater_ are included too.
%   zef_remove_system_fields deletes these keys. zef_session_shell_names
%   keeps them on the live session during a project switch.
%
%   See also zef_remove_system_fields, zef_session_shell_names.

arguments
    zef (1,1) struct
    candidates = {}
end

if isstring(candidates)
    candidates = cellstr(candidates);
end
candidates = candidates(:);

fixed = { ...
    'gpu_count'; 'compartment_activity'; 'start_mode'; 'colormap_cell'; ...
    'path_cell'; 'use_display'; 'current_version'; 'matfile_object'; ...
    'zeffiro_restart'; 'verbose_mode'; 'use_waitbar'; 'zeffiro_task_id'; ...
    'use_github'; 'ui_color_mode'; 'sensors_table_synced'};

ini_cell = zef_read_profile_cell([zef.program_path '/profile/zeffiro_interface.ini']);
from_profile = setdiff(ini_cell(:,3), {'save_file', 'save_file_path'});
names = [from_profile(:); fixed];

if ~isempty(candidates)
    extras = candidates(startsWith(string(candidates), "github_updater_"));
    names = [names; cellstr(extras)];
end

end
