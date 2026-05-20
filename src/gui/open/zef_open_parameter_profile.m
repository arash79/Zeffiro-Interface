% --- Zeffiro documentation header ---
% zef_data = zef_parameter_profile; — Zef data = zef parameter profile;.
%
% Purpose:
%   Zef data = zef parameter profile;.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_menu_parameter_profile_table_add (read)
%   zef.h_menu_parameter_profile_table_delete (read)
%   zef.h_parameter_profile (read)
%   zef.h_parameter_profile_apply (read)
%   zef.h_parameter_profile_from_project (read)
%   zef.h_parameter_profile_save (read)
%   zef.h_parameter_profile_table (read)
%   zef.parameter_profile (read)
%   zef.parameter_profile_current_size (read, write)
%   zef.parameter_profile_relative_size (read, write)
%   zef.parameter_profile_selected (read)
%   zef.profile_name (read)
%   zef.program_path (read)
%
% Calls (project):
%   zef_apply_parameter_profile
%   zef_change_size_function
%   zef_get_relative_size
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef_data = zef_parameter_profile;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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

set(findobj(zef.h_parameter_profile.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef.h_parameter_profile.Name = 'ZEFFIRO Interface: Parameter profile';

set(zef.h_parameter_profile,'AutoResizeChildren','off');
zef.parameter_profile_current_size = get(zef.h_parameter_profile,'Position');
zef.parameter_profile_relative_size = zef_get_relative_size(zef.h_parameter_profile);
set(zef.h_parameter_profile,'SizeChangedFcn','zef.parameter_profile_current_size = zef_change_size_function(zef.h_parameter_profile,zef.parameter_profile_current_size,zef.parameter_profile_relative_size);');

set(zef.h_parameter_profile,'DeleteFcn','zef_closereq;');
