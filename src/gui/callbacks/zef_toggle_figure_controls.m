function zef_toggle_figure_controls
%ZEF_TOGGLE_FIGURE_CONTROLS  Show or hide the Figure-tool sidebar.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure tool button **Toggle controls**. Flips the toggle button
%   UserData between 1 (sidebar shown) and 2 (sidebar hidden), then
%   relayouts the window so the axes fill the freed space.
%
%   See also zef_figure_tool_layout, zef_figure_tool.

h_fig = [];
try
    h_fig = evalin('base', 'zef.h_zeffiro');
catch
end
if isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    h_fig = gcf;
end

tgb = findall(h_fig, 'Tag', 'togglecontrolsbutton');
if isempty(tgb)
    return
end
tgb = tgb(1);
toggle_status = tgb.UserData;
if isempty(toggle_status) || isequal(toggle_status, 1)
    tgb.UserData = 2;
else
    tgb.UserData = 1;
end

zef_figure_tool_layout(h_fig);

end
