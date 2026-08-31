function zef_layout_nse_tool(fig)
%ZEF_LAYOUT_NSE_TOOL  Scrollable host for the NSE App Designer window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The NSE app is a dense absolute-position form (native 1005 x 951).
%   This keeps that arrangement, unclips the right-column dropdowns,
%   and puts the controls in a scrollable panel so a shorter screen
%   does not hide the bottom row.
%
%   See also zef_ui_ready, zef_nse_tool_window.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    zef_ui_adapt_grid(fig);
    return
end

theme = zef_ui_theme();
try
    fig.SizeChangedFcn = '';
    fig.AutoResizeChildren = 'off';
    fig.Scrollable = 'off';
    fig.Units = 'pixels';
catch
end

kids = [];
try
    kids = allchild(fig);
catch
    return
end
keep = gobjects(0, 1);
max_r = 0;
max_t = 0;
for i = 1:numel(kids)
    k = kids(i);
    typ = '';
    try
        typ = lower(char(k.Type));
    catch
    end
    if any(strcmp(typ, {'uimenu', 'uicontextmenu'}))
        continue
    end
    keep(end+1, 1) = k; %#ok<AGROW>
    try
        k.Units = 'pixels';
        p = k.Position;
        max_r = max(max_r, p(1) + p(3));
        max_t = max(max_t, p(2) + p(4));
    catch
    end
end
if isempty(keep)
    return
end

content_w = max(1180, ceil(max_r) + 24);
content_h = max(951, ceil(max_t) + 36);

root = uigridlayout(fig, [1 1]);
root.Tag = 'zef_ui_root';
root.Padding = [0 0 0 0];
root.RowSpacing = 0;
root.ColumnSpacing = 0;
root.RowHeight = {content_h};
root.ColumnWidth = {content_w};
try
    root.Scrollable = 'on';
    root.BackgroundColor = theme.color.bg;
catch
end

inner = uipanel('Parent', root, ...
    'BorderType', 'none', ...
    'Tag', 'zef_nse_inner', ...
    'BackgroundColor', theme.color.bg, ...
    'AutoResizeChildren', 'off', ...
    'Units', 'pixels');
try
    inner.Layout.Row = 1;
    inner.Layout.Column = 1;
catch
end

for i = 1:numel(keep)
    try
        if isequal(keep(i), root) || isequal(keep(i), inner)
            continue
        end
        keep(i).Parent = inner;
    catch
    end
end

drawnow;
try
    local_widen_dropdowns(fig);
catch
end

max_r = 0;
max_t = 0;
ctrls = [findall(fig, 'Type', 'uidropdown'); findall(fig, 'Type', 'uilabel'); ...
    findall(fig, 'Type', 'uibutton'); findall(fig, 'Type', 'uieditfield'); ...
    findall(fig, 'Type', 'uinumericeditfield'); findall(fig, 'Type', 'uilistbox')];
for i = 1:numel(ctrls)
    try
        gp = getpixelposition(ctrls(i), true);
        max_r = max(max_r, gp(1) + gp(3));
        max_t = max(max_t, gp(2) + gp(4));
    catch
    end
end
content_w = max(1180, ceil(max_r) + 36);
content_h = max(951, ceil(max_t) + 36);
root.RowHeight = {content_h};
root.ColumnWidth = {content_w};

scr = get(groot, 'ScreenSize');
def_w = min(content_w, min(round(0.92 * scr(3)), scr(3) - 16));
def_h = min(content_h, min(round(0.92 * scr(4)), scr(4) - 48));
def_w = min(max(def_w, 1080), min(round(0.92 * scr(3)), scr(3) - 16));
def_h = max(760, def_h);
zef_ui_apply_size(fig, def_w, def_h, 1040, 720);
setappdata(fig, 'ZefNseContent', [content_w, content_h]);
try
    local_widen_dropdowns(fig);
catch
end

end

function local_widen_dropdowns(fig)

dds = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(dds)
    h = dds(i);
    try
        p = h.Position;
        if numel(p) < 4 || p(1) < 700
            continue
        end
        need = 300;
        try
            items = h.Items;
            for k = 1:numel(items)
                need = max(need, min(380, 32 + round(7.2 * numel(char(string(items{k}))))));
            end
        catch
        end
        p(3) = max(p(3), need);
        h.Position = p;
        try
            if isprop(h, 'Items') && ~isempty(h.Items)
                h.Tooltip = strjoin(string(h.Items), newline);
            end
        catch
        end
    catch
    end
end

end
