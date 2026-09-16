%ZEF_OPEN_PLUGIN_SETTINGS  Settings → **Plugin settings**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of h_menu_plugin_settings. Instantiates
%   zef_plugin_settings, loads profile/<name>/zeffiro_plugins.ini into
%   h_plugin_settings_table when plugin_cell is empty. **Save** →
%   zef_save_plugin_settings; **Apply** → save then zef_plugin (rebuilds
%   plugin menus). Closing does not save.
%
%   See also zef_save_plugin_settings, zef_menu_tool.
zef_data = zef_plugin_settings;
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end

set(zef.h_plugin_settings_table,'CellSelectionCallback',@zef_plugin_settings_table_selection);
if isempty(zef.plugin_cell)
    zef.plugin_cell = zef_read_profile_cell([zef.program_path '/profile/' zef.profile_name '/zeffiro_plugins.ini']);
end

zef.h_plugin_settings_table.Data = zef.plugin_cell;
zef.h_plugin_settings_save.ButtonPushedFcn = 'zef_save_plugin_settings;';
zef.h_plugin_settings_apply.ButtonPushedFcn = 'zef_save_plugin_settings;zef_plugin;';
set(zef.h_plugin_settings_table,'columnformat',{'char','char','char'})

set(zef.h_plugin_settings_update_from_profile,'ButtonPushedFcn','zef.h_plugin_settings_table.Data=zef_read_profile_cell([zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_plugins.ini'']);zef.plugin_cell=zef.h_plugin_settings_table.Data;');
set(zef.h_menu_plugin_settings_table_add,'MenuSelectedFcn','zef.h_plugin_settings_table.Data{end+1,1} = char(0); zef.h_plugin_settings_table.Data = [zef.h_plugin_settings_table.Data(1:zef.plugin_settings_selected(1),:) ; zef.h_plugin_settings_table.Data(end,:) ; zef.h_plugin_settings_table.Data(zef.plugin_settings_selected(1)+1:end-1,:)];');
set(zef.h_menu_plugin_settings_table_delete,'MenuSelectedFcn','zef.h_plugin_settings_table.Data = zef.h_plugin_settings_table.Data(find(not(ismember([1:size(zef.h_plugin_settings_table.Data,1)],zef.plugin_settings_selected))),:);');

zef.h_plugin_settings.Name = 'ZEFFIRO Interface: Plugin settings';
set(zef.h_plugin_settings,'DeleteFcn','zef_closereq;');
zef_ui_ready(zef.h_plugin_settings);
