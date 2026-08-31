%ZEF_RESET_WINDOWS  Recreate the five default tools (Window → Reset windows).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of **Window → Reset windows**. Re-runs
%   zef_segmentation_tool, zef_reopen_menu_tool, deletes the Figure tool
%   (clears DeleteFcn first so it does not auto-reopen), then zef_figure_tool,
%   zef_mesh_tool, zef_mesh_visualization_tool, zef_update. Positions come
%   from those constructors / zef_window_manager, not from a saved layout.

zef_segmentation_tool;
zef_reopen_menu_tool;
zef.h_zeffiro.CloseRequestFcn = 'closereq;';
zef.h_zeffiro.DeleteFcn = '';
delete(zef.h_zeffiro);
zef_figure_tool;
zef_mesh_tool;
zef_mesh_visualization_tool;
zef = zef_update(zef);
try
    zef_ui_shell('hide_companions', zef);
    zef_ui_shell('hide_menu', zef);
    zef_ui_shell('raise_figure');
catch
end
