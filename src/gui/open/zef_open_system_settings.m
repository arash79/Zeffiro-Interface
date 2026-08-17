%ZEF_OPEN_SYSTEM_SETTINGS  Settings → **System settings (zeffiro_interface.ini)**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of h_menu_system_settings (no zef_update).
%   Instantiates zef_system_settings, loads profile/zeffiro_interface.ini
%   into h_system_settings_table. **Save** → zef_save_system_settings;
%   **Apply** → save then zef_apply_system_settings. Add/delete row
%   menus use zef.system_settings_selected from
%   zef_system_settings_table_selection. Closing does not save.
%
%   See also zef_save_system_settings, zef_menu_tool.
zef_data = zef_system_settings;
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end

set(zef.h_system_settings_table,'CellSelectionCallback',@zef_system_settings_table_selection);

zef.ini_cell = readcell([zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
zef.h_system_settings_table.Data = zef.ini_cell;
zef = rmfield(zef,'ini_cell');
zef.h_system_settings_save.ButtonPushedFcn = 'zef_save_system_settings;';
zef.h_system_settings_apply.ButtonPushedFcn = 'zef_save_system_settings;zef_apply_system_settings;';
set(zef.h_system_settings_table,'columnformat',{'char','char','char',{'number','string'}})

set(zef.h_menu_system_settings_table_add,'MenuSelectedFcn','zef.h_system_settings_table.Data{end+1,1} = []; zef.h_system_settings_table.Data = [zef.h_system_settings_table.Data(1:zef.system_settings_selected(1),:) ; zef.h_system_settings_table.Data(end,:) ; zef.h_system_settings_table.Data(zef.system_settings_selected(1)+1:end-1,:)];');
set(zef.h_menu_system_settings_table_delete,'MenuSelectedFcn','zef.h_system_settings_table.Data = zef.h_system_settings_table.Data(find(not(ismember([1:size(zef.h_system_settings_table.Data,1)],zef.system_settings_selected))),:);');

zef.h_system_settings.Name = 'ZEFFIRO Interface: System settings';
zef_ui_ready(zef.h_system_settings);

set(zef.h_system_settings,'DeleteFcn','zef_closereq;');
