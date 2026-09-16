%ZEF_OPEN_INIT_PROFILE  Settings → **Pre-settings profile**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of h_menu_init_profile. Instantiates
%   zef_init_profile, loads profile/<name>/zeffiro_init.ini (or existing
%   zef.init_profile). Table columns: …, value, zef field, type
%   {number, string, evaluate}. **Save** writecell; **Apply** writecell
%   then zef_apply_init_profile (which runs zef_init_init_profile).
%   CellSelectionCallback zef_init_profile_table_selection. Closing does
%   not save.
%
%   See also zef_init_init_profile, zef_apply_init_profile.
zef_data = zef_init_profile;
zef_assign_data;

if isempty(zef.init_profile)
    zef.init_profile = zef_read_profile_cell([zef.program_path '/profile/' zef.profile_name '/zeffiro_init.ini']);
end
zef.h_init_profile_table.Data = zef.init_profile;

set(zef.h_init_profile_table,'CellSelectionCallback',@zef_init_profile_table_selection);

set(zef.h_init_profile_save,'ButtonPushedFcn','zef.init_profile = zef.h_init_profile_table.Data;writecell(zef.h_init_profile_table.Data,[zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_init.ini''],''filetype'',''text'',''delimiter'','','');');
set(zef.h_init_profile_apply,'ButtonPushedFcn','zef.init_profile = zef.h_init_profile_table.Data;writecell(zef.h_init_profile_table.Data,[zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_init.ini''],''filetype'',''text'',''delimiter'','','');zef_apply_init_profile;');

set(zef.h_init_profile_update_from_profile,'ButtonPushedFcn','zef.init_profile = zef_read_profile_cell([zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_init.ini'']);zef.h_init_profile_table.Data = zef.init_profile;');

set(zef.h_init_profile_table,'columnformat',{'char','char','char',{'number','string','evaluate'}});

set(zef.h_menu_init_profile_add,'MenuSelectedFcn','zef.h_init_profile_table.Data{end+1,1} = []; zef.h_init_profile_table.Data = [zef.h_init_profile_table.Data(1:zef.init_profile_selected(1),:) ; zef.h_init_profile_table.Data(end,:) ; zef.h_init_profile_table.Data(zef.init_profile_selected(1)+1:end-1,:)];');

set(zef.h_menu_init_profile_delete,'MenuSelectedFcn','zef.h_init_profile_table.Data = zef.h_init_profile_table.Data(find(not(ismember([1:size(zef.h_init_profile_table.Data,1)],zef.init_profile_selected))),:);');

zef.h_init_profile.Name = 'ZEFFIRO Interface: Initialization profile';
set(zef.h_init_profile,'DeleteFcn','zef_closereq;');
zef_ui_ready(zef.h_init_profile);
