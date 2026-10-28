function zef_data = zef_remove_system_fields(zef, zef_data)
%ZEF_REMOVE_SYSTEM_FIELDS  Strip machine/session fields from zef_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by project save and project load. Removes the names from
%   zef_system_field_names (profile INI column 3, a fixed list, and
%   github_updater_* keys present on zef_data). save_file and
%   save_file_path are kept.
%
%   zef_data = zef_remove_system_fields(zef, zef_data)
%
%   Inputs
%     zef      - session; program_path required to locate the profile INI.
%     zef_data - struct that will be written to / was read from a .mat project.
%
%   See also zef_save, zef_load, zef_system_field_names.

arguments
    zef (1,1) struct
    zef_data (1,1) struct
end

system_fields = zef_system_field_names(zef, fieldnames(zef_data));
for i = 1:numel(system_fields)
    if isfield(zef_data, system_fields{i})
        zef_data = rmfield(zef_data, system_fields{i});
    end
end

end
