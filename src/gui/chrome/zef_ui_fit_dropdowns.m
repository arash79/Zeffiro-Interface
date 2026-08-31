function zef_ui_fit_dropdowns(fig)
%ZEF_UI_FIT_DROPDOWNS  Widen dropdowns whose text does not fit.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Grows uidropdown controls so the current value (and the longest item)
%   is readable. Controls stay in place; they expand into unused space
%   to the right, then the left, and never overlap a neighboring widget.
%
%   zef_ui_fit_dropdowns(fig)
%
%   See also zef_layout_guide_window.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
try
    tag = char(fig.Tag);
    name = char(fig.Name);
    if strcmp(tag, 'figure_tool') || (contains(name, 'Figure tool') ...
            && ~contains(name, 'axes popup'))
        return
    end
catch
end
fw = 0;
try
    orig = fig.Units;
    fig.Units = 'pixels';
    fw = fig.Position(3);
    fig.Units = orig;
catch
    return
end
if fw < 200
    return
end

objs = findall(fig, 'Type', 'uidropdown');
cap = min(400, max(180, round(0.58 * fw)));
for i = 1:numel(objs)
    try
        local_fit_one(objs(i), fig, fw, cap);
    catch
    end
end
try
    local_widen_trailing(fig, fw, cap);
catch
end
try
    local_fit_grid_columns(fig);
catch
end

end

function local_fit_one(obj, fig, fw, cap)

if isempty(obj) || ~isgraphics(obj) || ~isvalid(obj)
    return
end
vis = 'on';
try
    vis = char(obj.Visible);
catch
end
if strcmpi(vis, 'off')
    return
end
try
    pr = obj.Parent;
    if isgraphics(pr) && isvalid(pr) && strcmpi(char(pr.Type), 'uigridlayout')
        return
    end
catch
end
try
    if isprop(obj, 'Units')
        obj.Units = 'pixels';
    end
    p = obj.Position;
catch
    return
end
if numel(p) < 4 || p(3) < 28 || p(4) < 16
    return
end

need = p(3);
try
    if isprop(obj, 'Items')
        items = obj.Items;
        for k = 1:numel(items)
            need = max(need, 32 + round(7.0 * numel(char(string(items{k})))));
        end
    end
catch
end
try
    if isprop(obj, 'Value') && (ischar(obj.Value) || isstring(obj.Value) ...
            || isnumeric(obj.Value))
        val = obj.Value;
        if isnumeric(val) && isprop(obj, 'Items') && ~isempty(obj.Items)
            idx = double(val);
            if idx >= 1 && idx <= numel(obj.Items)
                val = obj.Items{idx};
            end
        end
        need = max(need, 32 + round(7.0 * numel(char(string(val)))));
    end
catch
end
need = min(need, cap);
if need <= p(3) + 6
    return
end

gp = p;
try
    gp = getpixelposition(obj, true);
catch
end
room_right = local_clearance(obj, fig, gp, 1, fw);
room_left = local_clearance(obj, fig, gp, -1, fw);
extra = need - p(3);
grow_right = min(extra, max(0, room_right));
grow_left = min(extra - grow_right, max(0, room_left));
if grow_right + grow_left < 4
    return
end
p(1) = p(1) - grow_left;
p(3) = p(3) + grow_right + grow_left;
obj.Position = p;

end

function room = local_clearance(obj, fig, gp, direction, fw)

margin = 6;
if direction > 0
    room = fw - (gp(1) + gp(3)) - margin;
else
    room = gp(1) - margin;
end
ctrls = [findall(fig, 'Type', 'uidropdown'); findall(fig, 'Type', 'uibutton'); ...
    findall(fig, 'Type', 'uieditfield'); ...
    findall(fig, 'Type', 'uinumericeditfield'); findall(fig, 'Type', 'uispinner'); ...
    findall(fig, 'Type', 'uicheckbox'); findall(fig, 'Type', 'uipanel')];
for i = 1:numel(ctrls)
    sib = ctrls(i);
    if isempty(sib) || ~isgraphics(sib) || ~isvalid(sib) || isequal(sib, obj)
        continue
    end
    vis = 'on';
    try
        vis = char(sib.Visible);
    catch
    end
    if strcmpi(vis, 'off')
        continue
    end
    sgp = [];
    try
        sgp = getpixelposition(sib, true);
    catch
        continue
    end
    if numel(sgp) < 4
        continue
    end
    if sgp(2) + sgp(4) < gp(2) + 4 || sgp(2) > gp(2) + gp(4) - 4
        continue
    end
    if direction > 0 && sgp(1) >= gp(1) + gp(3) - 2
        room = min(room, sgp(1) - (gp(1) + gp(3)) - margin);
    elseif direction < 0 && sgp(1) + sgp(3) <= gp(1) + 2
        room = min(room, gp(1) - (sgp(1) + sgp(3)) - margin);
    end
end
room = max(0, room);

end

function local_widen_trailing(fig, fw, cap)

objs = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(objs)
    obj = objs(i);
    try
        pr = obj.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            continue
        end
        vis = char(obj.Visible);
        if strcmpi(vis, 'off')
            continue
        end
        if isprop(obj, 'Units')
            obj.Units = 'pixels';
        end
        p = obj.Position;
        gp = getpixelposition(obj, true);
        if numel(p) < 4 || gp(3) >= 200
            continue
        end
        if gp(1) + gp(3) < fw - 36
            continue
        end
        if local_hits_button(obj, fig)
            continue
        end
        new_w = min(cap, max(gp(3) + 90, 230));
        dx = (gp(1) + gp(3)) - (fw - 12);
        p(3) = p(3) + (new_w - gp(3));
        p(1) = p(1) - (new_w - gp(3)) - max(0, dx);
        p(1) = max(8, p(1));
        obj.Position = p;
    catch
    end
end

end

function tf = local_hits_button(obj, fig)

tf = false;
gp = getpixelposition(obj, true);
btns = findall(fig, 'Type', 'uibutton');
new_w = 230;
new_x = fw_safe(fig) - 12 - new_w;
trial = [new_x, gp(2), new_w, gp(4)];
for i = 1:numel(btns)
    try
        if strcmpi(char(btns(i).Visible), 'off')
            continue
        end
        bp = getpixelposition(btns(i), true);
        if trial(1) < bp(1) + bp(3) && trial(1) + trial(3) > bp(1) ...
                && trial(2) < bp(2) + bp(4) && trial(2) + trial(4) > bp(2)
            tf = true;
            return
        end
    catch
    end
end

end

function fw = fw_safe(fig)

fw = 800;
try
    u = fig.Units;
    fig.Units = 'pixels';
    fw = fig.Position(3);
    fig.Units = u;
catch
end

end

function local_fit_grid_columns(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    g = gs(i);
    if ~isvalid(g)
        continue
    end
    try
        cw = g.ColumnWidth;
    catch
        continue
    end
    if ~iscell(cw) || numel(cw) < 2
        continue
    end
    has_dd = false;
    try
        kids = g.Children;
        for k = 1:numel(kids)
            if isvalid(kids(k)) && contains(lower(class(kids(k))), 'dropdown')
                has_dd = true;
                break
            end
        end
    catch
        kids = gobjects(0);
    end
    if ~has_dd
        continue
    end
    if numel(cw) == 2
        cw = {'fit', '1x'};
    elseif numel(cw) == 4
        cw = {'fit', '1x', 'fit', '1x'};
    elseif numel(cw) == 6
        cw = {'fit', '1x', 'fit', '1x', 'fit', '1x'};
    else
        cw{end} = '1x';
    end
    try
        kids = g.Children;
        for k = 1:numel(kids)
            obj = kids(k);
            if ~isvalid(obj)
                continue
            end
            if ~contains(lower(class(obj)), 'dropdown')
                continue
            end
            need = 0;
            try
                items = obj.Items;
                for t = 1:numel(items)
                    need = max(need, 32 + round(7.0 * numel(char(string(items{t})))));
                end
            catch
            end
            if need < 1
                continue
            end
            col = 1;
            try
                col = obj.Layout.Column;
                if numel(col) > 1
                    col = col(end);
                end
            catch
            end
            if col >= 1 && col <= numel(cw) && isnumeric(cw{col})
                cw{col} = max(cw{col}, min(280, need));
            end
        end
    catch
    end
    try
        g.ColumnWidth = cw;
    catch
    end
end

end

