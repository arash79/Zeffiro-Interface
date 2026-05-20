function window_handle = zef_window_visible(zef,window_handle)
% --- Zeffiro documentation header ---
% zef_window_visible — Zef window visible.
%
% Purpose:
%   Zef window visible.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   window_handle
%
% Outputs:
%   window_handle
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_zeffiro_menu (read)
%
% Calls (project):
%   zef_window_visible
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[window_handle] = zef_window_visible(zef, window_handle)` with project root and `src` on the path.
% --- End Zeffiro documentation header


window_handle.Position(1) = zef.h_zeffiro_menu.Position(1)+zef.h_zeffiro_menu.Position(3)-window_handle.Position(3);
window_handle.Position(2) = zef.h_zeffiro_menu.Position(2)+zef.h_zeffiro_menu.Position(4)-window_handle.Position(4);
window_handle.Visible = 'on';
set(findobj(window_handle.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(window_handle.Children,'-property','FontSize'),'FontSize',zef.font_size);

end
