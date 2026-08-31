function h = zef_ui_anchor(zef)
%ZEF_UI_ANCHOR  Figure used to position secondary Zeffiro windows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Prefers the unified main window when it exists; otherwise the menu
%   tool figure (including when that figure is hidden).
%
%   h = zef_ui_anchor
%   h = zef_ui_anchor(zef)
%
%   See also zef_window_visible, zef_tool_start.

h = [];
if nargin < 1 || isempty(zef)
    try
        zef = evalin('base', 'zef');
    catch
        zef = struct();
    end
end
if ~isstruct(zef)
    return
end
if isfield(zef, 'h_zeffiro') && local_ok(zef.h_zeffiro) ...
        && zef_ui_is_unified(zef.h_zeffiro)
    h = zef.h_zeffiro;
    return
end
if isfield(zef, 'h_zeffiro_menu') && local_ok(zef.h_zeffiro_menu)
    h = zef.h_zeffiro_menu;
end

end

function tf = local_ok(h)

tf = false;
try
    tf = ~isempty(h) && isgraphics(h) && isvalid(h);
catch
end

end
