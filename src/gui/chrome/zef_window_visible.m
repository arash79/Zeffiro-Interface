function window_handle = zef_window_visible(zef,window_handle)
%ZEF_WINDOW_VISIBLE  Show and raise a tool figure beside the menu bar.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Window → Segmentation / Mesh / Mesh visualization tool.
%   zef_window_manager('standalone') then align top-right to
%   h_zeffiro_menu, Visible='on', 'raise', apply zef.font_size.
%   If window_handle is h_zeffiro_window_main, also 'dock_menu'.
%
%   window_handle = zef_window_visible(zef, window_handle)
%
%   See also zef_window_manager, zef_menu_tool.
if isempty(window_handle) || ~isgraphics(window_handle) || ~isvalid(window_handle)
    return
end

zef_window_manager('standalone', window_handle);

anchor = [];
try
    anchor = zef_ui_anchor(zef);
catch
    if isfield(zef, 'h_zeffiro_menu') && isvalid(zef.h_zeffiro_menu)
        anchor = zef.h_zeffiro_menu;
    end
end
if ~isempty(anchor) && isvalid(anchor)
    window_handle.Position(1) = anchor.Position(1)+anchor.Position(3)-window_handle.Position(3);
    window_handle.Position(2) = anchor.Position(2)+anchor.Position(4)-window_handle.Position(4);
end
window_handle.Visible = 'on';
zef_window_manager('raise', window_handle);
already = false;
try
    already = isappdata(window_handle, 'ZefUiThemed') ...
        && isequal(getappdata(window_handle, 'ZefUiThemed'), true);
catch
end
if ~already
    zef_ui_apply_theme(window_handle);
    try
        zef_ui_polish_window(window_handle);
    catch
    end
end
try
    zef_ui_interact(window_handle);
catch
end

if isfield(zef, 'h_zeffiro_window_main') && isequal(window_handle, zef.h_zeffiro_window_main)
    zef_window_manager('dock_menu', zef);
end

end
