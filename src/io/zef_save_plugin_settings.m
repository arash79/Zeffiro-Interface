%ZEF_SAVE_PLUGIN_SETTINGS  Persist plugin settings table to profile INI.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Copies zef.h_plugin_settings_table.Data into zef.plugin_cell, writes it
%   to profile/<zef.profile_name>/zeffiro_plugins.ini, and applies each row
%   to the corresponding zef field in the base workspace.
%
%   See also zef_save_system_settings, zef_plugin.

zef.plugin_cell = zef.h_plugin_settings_table.Data;
writecell(zef.plugin_cell,[zef.program_path '/profile/' zef.profile_name '/zeffiro_plugins.ini'],'FileType','text');
for zef_i = 1 : size(zef.h_plugin_settings_table.Data,1)
    evalin('base',['zef.' zef.h_plugin_settings_table.Data{zef_i,3} '= zef.h_plugin_settings_table.Data{zef_i,2};']);
end
