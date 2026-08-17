%ZEF_OPEN_PARAMETER_PROFILE  Settings → **Parameter profile**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of h_menu_parameter_profile. Instantiates
%   zef_parameter_profile, loads profile/<name>/zeffiro_parameters.ini
%   into the table. Columns: name, field, Scalar/String, default, …,
%   On/Off, On/Off, Segmentation/Sensors/Free-form. **Save** writecell
%   INI; **Apply** writecell then zef_apply_parameter_profile. Closing
%   does not save.
%
%   See also zef_init_parameter_profile, zef_menu_tool.
zef_data = zef_parameter_profile;
zef_assign_data;

zef.h_parameter_profile_table.Data = readcell([zef.program_path '/profile/' zef.profile_name '/zeffiro_parameters.ini'],'FileType','text','delimiter',',');

set(zef.h_parameter_profile_table,'CellSelectionCallback',@zef_parameter_profile_table_selection);

set(zef.h_parameter_profile_table,'columnformat',{'char','char',{'Scalar','String'},'char','char',{'On','Off'},{'On','Off'},{'Segmentation','Sensors', 'Free-form'}});

set(zef.h_parameter_profile_from_project,'ButtonPushedFcn','zef.h_parameter_profile_table.Data = zef.parameter_profile;');

set(zef.h_parameter_profile_apply,'ButtonPushedFcn','writecell(zef.h_parameter_profile_table.Data,[zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_parameters.ini''],''filetype'',''text'',''delimiter'','','');  zef = zef_apply_parameter_profile(zef)');

set(zef.h_parameter_profile_save,'ButtonPushedFcn','writecell(zef.h_parameter_profile_table.Data,[zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_parameters.ini''],''filetype'',''text'',''delimiter'','','')');

set(zef.h_menu_parameter_profile_table_add,'MenuSelectedFcn','zef.h_parameter_profile_table.Data{end+1,1} = ['''']; zef.h_parameter_profile_table.Data = [zef.h_parameter_profile_table.Data(1:zef.parameter_profile_selected(1),:) ; zef.h_parameter_profile_table.Data(end,:) ; zef.h_parameter_profile_table.Data(zef.parameter_profile_selected(1)+1:end-1,:)];');
set(zef.h_menu_parameter_profile_table_delete,'MenuSelectedFcn','zef.h_parameter_profile_table.Data = zef.h_parameter_profile_table.Data(find(not(ismember([1:size(zef.h_parameter_profile_table.Data,1)],zef.parameter_profile_selected))),:);');

zef.h_parameter_profile.Name = 'ZEFFIRO Interface: Parameter profile';
set(zef.h_parameter_profile,'DeleteFcn','zef_closereq;');
zef_ui_ready(zef.h_parameter_profile);
