% --- Zeffiro documentation header ---
% set(gcf,'AutoResizeChildren','off'); — Set(gcf,'Auto Resize Children','off');.
%
% Purpose:
%   Set(gcf,'Auto Resize Children','off');.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.zeffiro_current_size (read)
%
% Calls (project):
%   zef_change_size_function
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `set(gcf,'AutoResizeChildren','off');` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

set(gcf,'AutoResizeChildren','off');
zef.zeffiro_current_size{zef_fig_num} = get(gcf,'Position');
set(gcf,'Tag',num2str(zef_fig_num));
set(gcf,'SizeChangedFcn','zef.zeffiro_current_size{str2num(get(gcf,''Tag''))} = zef_change_size_function(gcf,zef.zeffiro_current_size{str2num(get(gcf,''Tag''))},[],{''Colorbar'',''image_details''});');
