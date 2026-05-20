% --- Zeffiro documentation header ---
% if not(isempty(zef.zeffiro_current_size)); zef.zeffiro_current_size{str2num(get(gcf,'Tag'))} = zef_change_size_function(gcf,zef — If not(isempty(zef.zeffiro current size)); zef.zeffiro current size{str2num(get(gcf,'Tag'))} = zef change size function(gcf,zef.
%
% Purpose:
%   If not(isempty(zef.zeffiro current size)); zef.zeffiro current size{str2num(get(gcf,'Tag'))} = zef change size function(gcf,zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isempty(zef.zeffiro_current_size)); zef.zeffiro_current_size{str2num(get(gcf,'Tag'))} = zef_change_size_function(gcf,zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if not(isempty(zef.zeffiro_current_size)); zef.zeffiro_current_size{str2num(get(gcf,'Tag'))} = zef_change_size_function(gcf,zef.zeffiro_current_size{str2num(get(gcf,'Tag'))},[],{'Colorbar','image_details'}); end;
