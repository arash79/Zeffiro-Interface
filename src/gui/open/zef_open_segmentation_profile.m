%ZEF_OPEN_SEGMENTATION_PROFILE  Settings → **Segmentation profile**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of h_menu_segmentation_profile. Instantiates
%   zef_segmentation_profile, loads profile/<name>/zeffiro_segmentation.ini.
%   **Save** writecell. Add/delete row and column menus. This INI is what
%   zef_init_compartments reads at project start. Closing does not save.
%
%   See also zef_init_compartments, zef_menu_tool.
zef_data = zef_segmentation_profile;
zef_assign_data;

zef.h_segmentation_profile_table.Data = readcell([zef.program_path '/profile/' zef.profile_name '/zeffiro_segmentation.ini'],'filetype','text','delimiter',',');

set(zef.h_segmentation_profile_table,'CellSelectionCallback',@zef_segmentation_profile_table_selection);

set(zef.h_segmentation_profile_save,'ButtonPushedFcn','writecell(zef.h_segmentation_profile_table.Data,[zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_segmentation.ini''],''filetype'',''text'',''delimiter'','','')');

set(zef.h_segmentation_profile_table,'columnformat',{'char','char',{'number','string'}});

set(zef.h_menu_segmentation_profile_table_add_row,'MenuSelectedFcn','zef.h_segmentation_profile_table.Data{end+1,1} = []; zef.h_segmentation_profile_table.Data = [zef.h_segmentation_profile_table.Data(1:zef.segmentation_profile_row_selected(1),:) ; zef.h_segmentation_profile_table.Data(end,:) ; zef.h_segmentation_profile_table.Data(zef.segmentation_profile_row_selected(1)+1:end-1,:)];');
set(zef.h_menu_segmentation_profile_table_add_column,'MenuSelectedFcn','zef.h_segmentation_profile_table.Data{1,end+1} = []; zef.h_segmentation_profile_table.Data = [zef.h_segmentation_profile_table.Data(:,1:zef.segmentation_profile_column_selected(1))  zef.h_segmentation_profile_table.Data(:,end)  zef.h_segmentation_profile_table.Data(:,zef.segmentation_profile_column_selected(1)+1:end-1)];');

set(zef.h_menu_segmentation_profile_table_delete_rows,'MenuSelectedFcn','zef.h_segmentation_profile_table.Data = zef.h_segmentation_profile_table.Data(find(not(ismember([1:size(zef.h_segmentation_profile_table.Data,2)],zef.segmentation_profile_row_selected))),:);');
set(zef.h_menu_segmentation_profile_table_delete_columns,'MenuSelectedFcn','zef.h_segmentation_profile_table.Data = zef.h_segmentation_profile_table.Data(:,find(not(ismember([1:size(zef.h_segmentation_profile_table.Data,2)],zef.segmentation_profile_column_selected))));');

set(findobj(zef.h_segmentation_profile.Children,'-property','FontSize'),'FontSize',zef.font_size);

set(zef.h_segmentation_profile,'AutoResizeChildren','off');
zef.segmentation_profile_current_size = get(zef.h_segmentation_profile,'Position');
zef.segmentation_profile_relative_size = zef_get_relative_size(zef.h_segmentation_profile);
set(zef.h_segmentation_profile,'SizeChangedFcn','zef.segmentation_profile_current_size = zef_change_size_function(zef.h_segmentation_profile,zef.segmentation_profile_current_size,zef.segmentation_profile_relative_size);');

zef.h_segmentation_profile.Name = 'ZEFFIRO Interface: Segmentation profile';

set(zef.h_segmentation_profile,'DeleteFcn','zef_closereq;');
