% --- Zeffiro documentation header ---
% if isvalid(zef — If isvalid(zef.
%
% Purpose:
%   If isvalid(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.clear_axes1 (read, write)
%   zef.current_log_file (read, write)
%   zef.font_size (read)
%   zef.h_zeffiro_menu (read)
%   zef.zeffiro_restart_time (read, write)
%   zef.zeffiro_task_id (read, write)
%
% Calls (project):
%   zef_update
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isvalid(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if isvalid(zef.h_zeffiro_menu)
    set(zef.h_zeffiro_menu,'DeleteFcn','');


end

zef.current_log_file = zef.h_zeffiro_menu.ZefCurrentLogFile;
zef.zeffiro_task_id = zef.h_zeffiro_menu.ZefTaskId;
zef.zeffiro_restart_time = zef.h_zeffiro_menu.ZefRestartTime;
delete(zef.h_zeffiro_menu);

zef_menu_tool;

zef = zef_update(zef);

set(findobj(zef.h_zeffiro_menu.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_zeffiro_menu.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef.clear_axes1 = 0;
