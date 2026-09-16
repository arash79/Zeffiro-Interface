function zef_toggle_figure_controls
%ZEF_TOGGLE_FIGURE_CONTROLS  Show or hide the Figure-tool sidebar.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Shared by the sidebar **Toggle controls** button and the toolbar
%   sliders icon. One figure-level flag is the source of truth. The
%   toggle control itself is not part of the hidden sidebar group.
%
%   See also zef_figure_tool_layout, zef_figure_tool.

h_fig = [];
try
    h_fig = evalin('base', 'zef.h_zeffiro');
catch
end
if isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    try
        h_fig = gcbf;
    catch
        h_fig = [];
    end
end
if isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    h_fig = gcf;
end
if isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end

shown = local_controls_shown(h_fig);
local_set_controls_shown(h_fig, ~shown);
zef_figure_tool_layout(h_fig);

end

function shown = local_controls_shown(h_fig)

shown = true;
try
    if isappdata(h_fig, 'ZefFigureControlsVisible')
        v = getappdata(h_fig, 'ZefFigureControlsVisible');
        if ~isempty(v)
            shown = logical(v(1));
            return
        end
    end
catch
end
tgb = findall(h_fig, 'Tag', 'togglecontrolsbutton');
if ~isempty(tgb) && isvalid(tgb(1)) && isequal(tgb(1).UserData, 2)
    shown = false;
end

end

function local_set_controls_shown(h_fig, shown)

shown = logical(shown);
try
    setappdata(h_fig, 'ZefFigureControlsVisible', shown);
catch
end
tgb = findall(h_fig, 'Tag', 'togglecontrolsbutton');
if ~isempty(tgb) && isvalid(tgb(1))
    tgb(1).UserData = 1 + double(~shown);
end
sl = findall(h_fig, 'Tag', 'zef_tool_sliders');
if ~isempty(sl) && isvalid(sl(1))
    sl(1).UserData = double(~shown);
end

end

