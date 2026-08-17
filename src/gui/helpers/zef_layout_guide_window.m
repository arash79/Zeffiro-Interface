function zef_layout_guide_window(fig)
%ZEF_LAYOUT_GUIDE_WINDOW  Polish a traditional figure() tool window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   GUIDE windows already use normalized Positions, so they scale with
%   the figure. Theme colors are applied here; the window is not grown.
%   A modest resize floor keeps the layout usable without opening large.
%
%   See also zef_ui_ready, zef_ui_apply_theme.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    zef_ui_bind_min_size(fig, 360, 280);
    return
end

theme = zef_ui_theme();
try
    fig.Color = theme.color.bg;
catch
end
try
    fig.Resize = 'on';
    fig.AutoResizeChildren = 'off';
catch
end

ctrls = findall(fig, 'Type', 'uicontrol');
for i = 1:numel(ctrls)
    try
        u = ctrls(i).Units;
        ctrls(i).Units = 'pixels';
        h = ctrls(i).Position(4);
        ctrls(i).FontName = theme.font.name;
        if strcmpi(char(ctrls(i).Style), 'slider') && h < theme.space.sliderH
            pos = ctrls(i).Position;
            extra = theme.space.sliderH - pos(4);
            pos(2) = pos(2) - extra / 2;
            pos(4) = theme.space.sliderH;
            ctrls(i).Position = pos;
            h = pos(4);
        end
        if h >= 22
            ctrls(i).FontUnits = 'pixels';
            ctrls(i).FontSize = min(theme.font.size, max(10, h - 10));
        end
        ctrls(i).Units = u;
    catch
    end
end

try
    panels = findall(fig, 'Type', 'uipanel');
    for i = 1:numel(panels)
        panels(i).BackgroundColor = theme.color.panel;
        panels(i).ForegroundColor = theme.color.text;
        panels(i).FontName = theme.font.name;
        panels(i).FontSize = theme.font.sizeSmall;
    end
catch
end

zef_ui_bind_min_size(fig, 360, 280);
setappdata(fig, 'ZefUiReady', true);

name = '';
try
    name = char(fig.Name);
catch
end
lname = lower(name);
if contains(lname, 'parcellation')
    zef_ui_apply_size(fig, 480, 640, 420, 520);
elseif ~isappdata(fig, 'ZefMinSize')
    zef_ui_bind_min_size(fig, 360, 280);
end

end
