%ZEF_REOPEN_MENU_TOOL  Rebuild the menu bar without firing zef_close_all.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Only first-party caller: zef_reset_windows
%   (**Window → Reset windows**). Needs zef in the caller workspace.
%
%   The live menu's DeleteFcn is zef_close_all, so this file blanks
%   DeleteFcn before delete(zef.h_zeffiro_menu). Copies the dynamic
%   properties ZefCurrentLogFile, ZefTaskId, and ZefRestartTime onto
%   zef.current_log_file / zef.zeffiro_task_id / zef.zeffiro_restart_time
%   so zef_menu_tool can rewrite ZefTaskId and ZefRestartTime on the new
%   handle. ZefCurrentLogFile itself is attached later by zef_start_log,
%   not by zef_menu_tool. Then zef_update, pixel font_size on children,
%   and zef.clear_axes1 = 0 (zef_figure_tool skips deleting an existing
%   colorbar when this flag is 0, then sets it back to 1).
%
%   See also zef_reset_windows, zef_menu_tool, zef_start_log.

if isvalid(zef.h_zeffiro_menu)
    set(zef.h_zeffiro_menu,'DeleteFcn','');


end

zef.current_log_file = zef.h_zeffiro_menu.ZefCurrentLogFile;
zef.zeffiro_task_id = zef.h_zeffiro_menu.ZefTaskId;
zef.zeffiro_restart_time = zef.h_zeffiro_menu.ZefRestartTime;
delete(zef.h_zeffiro_menu);

zef_menu_tool;

zef = zef_update(zef);

zef_ui_ready(zef.h_zeffiro_menu);

zef.clear_axes1 = 0;
