function zef_ui_card(panel, theme, radius)
%ZEF_UI_CARD  Paint a traditional uipanel as a rounded sample-style card.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sets BorderType to none, matches the figure background, and keeps a
%   bottom-stacked zef_card_bg axes whose image is a rounded rect.
%   Pushbutton CData is avoided: on macOS those controls keep a native
%   grey bezel that shows up as a shadow in the rounded corners.
%   Call after Position is set. Content must keep ~radius px of padding
%   so it does not cover the corners. The Figure workspace uses this
%   same layer: tabs, toolbar, and figure_view are children of
%   zef_shell_card and are inset by cardRadius.
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
try
    panel.BorderColor = theme.color.bg;
catch
end
panel.BackgroundColor = theme.color.bg;
panel.Units = 'pixels';
p = panel.Position;
w = max(8, round(p(3)));
h = max(8, round(p(4)));

edge_c = theme.color.border;
try
    edge_c = theme.color.cardEdge;
catch
end

bg = local_find_bg(panel);
prev_ax = local_current_axes(panel);
bg = local_ensure_layer(panel, bg, theme.color.bg);
key = [w, h, round(radius * 10), round(theme.color.panel * 1000), ...
    round(theme.color.bg * 1000), round(edge_c * 1000), 3];
prev = [];
try
    prev = getappdata(panel, 'ZefCardKey');
catch
end
if isequal(prev, key)
    has_im = false;
    try
        has_im = ~isempty(findall(bg, 'Type', 'image'));
    catch
    end
    if has_im
        local_place_layer(bg, [0, 0, w, h], [], theme.color.bg);
        local_restore_axes(panel, prev_ax);
        return
    end
end
try
    setappdata(panel, 'ZefCardKey', key);
catch
end
try
    rgb = zef_ui_roundrect(w, h, radius, theme.color.panel, ...
        edge_c, theme.color.bg);
catch
    rgb = [];
end
local_place_layer(bg, [0, 0, w, h], rgb, theme.color.bg);
try
    setappdata(panel, 'ZefCardBg', bg);
catch
end
try
    if ~isappdata(bg, 'ZefCardStacked')
        uistack(bg, 'bottom');
        setappdata(bg, 'ZefCardStacked', true);
    end
catch
end
local_restore_axes(panel, prev_ax);

end

function bg = local_find_bg(panel)

bg = [];
try
    if isappdata(panel, 'ZefCardBg')
        bg = getappdata(panel, 'ZefCardBg');
    end
catch
end
if ~isempty(bg) && isvalid(bg) && strcmpi(char(bg.Type), 'axes')
    return
end
found = gobjects(0);
try
    found = findall(panel, 'Tag', 'zef_card_bg');
catch
end
bg = [];
for i = 1:numel(found)
    if ~isvalid(found(i))
        continue
    end
    if strcmpi(char(found(i).Type), 'axes')
        bg = found(i);
    else
        try
            delete(found(i));
        catch
        end
    end
end

end

function bg = local_ensure_layer(panel, bg, outer)

if ~isempty(bg) && isvalid(bg) && strcmpi(char(bg.Type), 'axes')
    return
end
bg = axes('Parent', panel, 'Units', 'pixels', 'Tag', 'zef_card_bg', ...
    'HitTest', 'off', 'HandleVisibility', 'off', 'Box', 'off', ...
    'XTick', [], 'YTick', [], 'Color', outer, ...
    'Toolbar', [], 'Interactions', []);
try
    bg.PickableParts = 'none';
catch
end
try
    bg.XColor = 'none';
    bg.YColor = 'none';
catch
end
try
    bg.Title.String = '';
    bg.Title.Visible = 'off';
catch
end
try
    bg.PositionConstraint = 'innerposition';
catch
end
try
    bg.Visible = 'on';
catch
end

end

function local_place_layer(ax, pos, rgb, outer)

if isempty(ax) || ~isvalid(ax)
    return
end
ax.Units = 'pixels';
try
    ax.PositionConstraint = 'innerposition';
catch
end
try
    ax.Position = pos;
catch
end
try
    ax.InnerPosition = pos;
catch
end
try
    ax.LooseInset = [0 0 0 0];
catch
end
try
    ax.Color = outer;
catch
end
if isempty(rgb)
    return
end
[hh, ww, ~] = size(rgb);
try
    ax.XLim = [0.5, ww + 0.5];
    ax.YLim = [0.5, hh + 0.5];
    ax.YDir = 'reverse';
    ax.XTick = [];
    ax.YTick = [];
catch
end
im = [];
try
    im = findall(ax, 'Type', 'image');
    if ~isempty(im)
        im = im(1);
    end
catch
end
if isempty(im) || ~isvalid(im)
    image('Parent', ax, 'CData', rgb, 'HitTest', 'off', ...
        'XData', [1 ww], 'YData', [1 hh]);
else
    im.CData = rgb;
    im.XData = [1 ww];
    im.YData = [1 hh];
end

end

function ax = local_current_axes(panel)

ax = [];
try
    fig = ancestor(panel, 'figure');
    ax = get(fig, 'CurrentAxes');
catch
end

end

function local_restore_axes(panel, ax)

if isempty(ax) || ~isvalid(ax)
    return
end
try
    fig = ancestor(panel, 'figure');
    set(fig, 'CurrentAxes', ax);
catch
end

end
