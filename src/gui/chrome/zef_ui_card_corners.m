function zef_ui_card_corners(h_fig, rect, theme, radius)
%ZEF_UI_CARD_CORNERS  Round the four corners of a workspace rectangle.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sibling uipanels cannot sit under uiaxes, so the workspace card is
%   assembled from white tabs/axes/lists plus these 12 px corner caps
%   that overlap only the tab strip and status strip.
%
%   zef_ui_card_corners(h_fig, [x y w h], theme, radius)
%
%   See also zef_ui_roundrect, zef_ui_card.

if nargin < 2 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
if nargin < 3 || isempty(theme)
    theme = zef_ui_theme();
end
if nargin < 4 || isempty(radius)
    radius = 10;
    try
        radius = theme.space.cardRadius;
    catch
    end
end
rect = double(rect(:).');
if numel(rect) < 4
    return
end
try
    prev = getappdata(h_fig, 'ZefCardRect');
    if isequal(prev, 8 * round(rect / 8))
        return
    end
catch
end
x = rect(1);
y = rect(2);
w = rect(3);
h = rect(4);
r = max(8, min(round(radius), 14));
if w < 2 * r || h < 2 * r
    return
end

rgb = zef_ui_roundrect(2 * r + 4, 2 * r + 4, r, theme.color.panel, ...
    theme.color.border, theme.color.bg);
tl = rgb(1:r, 1:r, :);
tr = rgb(1:r, end - r + 1:end, :);
bl = rgb(end - r + 1:end, 1:r, :);
br = rgb(end - r + 1:end, end - r + 1:end, :);
specs = { ...
    'zef_card_c_tl', [x, y + h - r, r, r], tl; ...
    'zef_card_c_tr', [x + w - r, y + h - r, r, r], tr; ...
    'zef_card_c_bl', [x, y, r, r], bl; ...
    'zef_card_c_br', [x + w - r, y, r, r], br};
for i = 1:size(specs, 1)
    local_place(h_fig, specs{i, 1}, specs{i, 2}, specs{i, 3}, theme);
end
edge_c = theme.color.border;
edges = { ...
    'zef_card_e_l', [x, y + r, 1, max(1, h - 2 * r)]; ...
    'zef_card_e_r', [x + w - 1, y + r, 1, max(1, h - 2 * r)]; ...
    'zef_card_e_b', [x + r, y, max(1, w - 2 * r), 1]; ...
    'zef_card_e_t', [x + r, y + h - 1, max(1, w - 2 * r), 1]};
for i = 1:size(edges, 1)
    local_place_edge(h_fig, edges{i, 1}, edges{i, 2}, edge_c, theme);
end
try
    setappdata(h_fig, 'ZefCardRect', 8 * round(rect / 8));
catch
end

end

function local_place(h_fig, tag, pos, cdata, theme)

h = findall(h_fig, 'Tag', tag, 'Type', 'uicontrol');
if ~isempty(h)
    h = h(1);
end
if isempty(h) || ~isvalid(h)
    h = uicontrol('Style', 'pushbutton', 'Parent', h_fig, 'Units', 'pixels', ...
        'String', '', 'Enable', 'inactive', 'Tag', tag, ...
        'BackgroundColor', theme.color.bg);
    try
        h.HitTest = 'off';
    catch
    end
end
h.Units = 'pixels';
try
    cur = double(h.Position);
    if numel(cur) < 4 || max(abs(cur(:) - pos(:))) >= 0.51
        h.Position = pos;
    end
catch
    h.Position = pos;
end
try
    prev = getappdata(h, 'ZefCornerKey');
    if ~isequal(prev, size(cdata))
        h.CData = cdata;
        setappdata(h, 'ZefCornerKey', size(cdata));
    end
catch
    h.CData = cdata;
end

end

function local_place_edge(h_fig, tag, pos, edge_c, theme) %#ok<INUSD>

h = findall(h_fig, 'Tag', tag, 'Type', 'uicontrol');
if ~isempty(h)
    h = h(1);
end
if isempty(h) || ~isvalid(h)
    h = uicontrol('Style', 'text', 'Parent', h_fig, 'Units', 'pixels', ...
        'String', '', 'Enable', 'inactive', 'Tag', tag, ...
        'BackgroundColor', edge_c);
    try
        h.HitTest = 'off';
    catch
    end
end
h.Units = 'pixels';
try
    cur = double(h.Position);
    if numel(cur) < 4 || max(abs(cur(:) - pos(:))) >= 0.51
        h.Position = pos;
    end
catch
    h.Position = pos;
end
h.BackgroundColor = edge_c;

end
