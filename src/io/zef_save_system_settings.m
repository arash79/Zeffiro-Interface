%ZEF_SAVE_SYSTEM_SETTINGS  Persist system settings table to profile INI.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Writes zef.h_system_settings_table.Data to
%   profile/zeffiro_interface.ini under zef.program_path, then copies each
%   row's value onto the matching zef field in the base workspace via
%   evalin.
%
%   See also zef_save_plugin_settings, zef_apply_system_settings.

writecell(zef.h_system_settings_table.Data,[zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
for zef_i = 1 : size(zef.h_system_settings_table.Data,1)
    evalin('base',['zef.' zef.h_system_settings_table.Data{zef_i,3} '= zef.h_system_settings_table.Data{zef_i,2};']);
end
