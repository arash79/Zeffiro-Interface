function zef_ui_card(panel, theme, radius)
%ZEF_UI_CARD  Paint a traditional uipanel as a rounded sample-style card.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sets BorderType to none, matches the figure background, and keeps a
%   bottom-stacked zef_card_bg uicontrol whose CData is a rounded rect.
%   Call after Position is set. Content must keep ~radius px of padding
%   so it does not cover the corners.
%
%   zef_ui_card(panel)
%   zef_ui_card(panel, theme)
%   zef_ui_card(panel, theme, radius)
%
%   See also zef_ui_roundrect, zef_ui_theme.

if nargin < 1 || isempty(panel) || ~isgraphics(panel) || ~isvalid(panel)
    return
end
if nargin < 2 || isempty(theme)
    theme = zef_ui_theme();
end
if nargin < 3 || isempty(radius)
    radius = 10;
    try
        radius = theme.space.cardRadius;
    catch
    end
end

try
    panel.BorderType = 'none';
catch
end
try
    panel.HighlightColor = theme.color.bg;
    panel.ForegroundColor = theme.color.bg;
catch
end
panel.BackgroundColor = theme.color.bg;
panel.Units = 'pixels';
p = panel.Position;
w = max(8, 8 * round(round(p(3)) / 8));
h = max(8, 8 * round(round(p(4)) / 8));

bg = [];
try
    if isappdata(panel, 'ZefCardBg')
        bg = getappdata(panel, 'ZefCardBg');
    end
catch
end
if isempty(bg) || ~isvalid(bg)
    try
        bg = findall(panel, 'Tag', 'zef_card_bg', 'Type', 'uicontrol');
        if ~isempty(bg)
            bg = bg(1);
        end
    catch
    end
end
if isempty(bg) || ~isvalid(bg)
    bg = uicontrol('Style', 'pushbutton', 'Parent', panel, 'Units', 'pixels', ...
        'String', '', 'Enable', 'inactive', 'Tag', 'zef_card_bg', ...
        'BackgroundColor', theme.color.bg);
    try
        bg.HitTest = 'off';
    catch
    end
end
try
    setappdata(panel, 'ZefCardBg', bg);
catch
end
bg.Units = 'pixels';
key = [w, h, round(radius * 10), round(theme.color.panel * 1000), ...
    round(theme.color.bg * 1000), round(theme.color.border * 1000)];
prev = [];
try
    prev = getappdata(panel, 'ZefCardKey');
catch
end
if isequal(prev, key)
    try
        bg.Position = [0, 0, max(8, round(p(3))), max(8, round(p(4)))];
    catch
    end
    return
end
try
    setappdata(panel, 'ZefCardKey', key);
catch
end
bg.Position = [0, 0, max(8, round(p(3))), max(8, round(p(4)))];
bg.BackgroundColor = theme.color.bg;
try
    bg.CData = zef_ui_roundrect(w, h, radius, theme.color.panel, ...
        theme.color.border, theme.color.bg);
    bg.String = '';
catch
end
try
    if ~isappdata(bg, 'ZefCardStacked')
        uistack(bg, 'bottom');
        setappdata(bg, 'ZefCardStacked', true);
    end
catch
end

end
