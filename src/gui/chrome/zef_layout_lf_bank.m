function zef_layout_lf_bank(fig)
%ZEF_LAYOUT_LF_BANK  Grid layout for the Multi lead field tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_lf_bank_tool, zef_ui_ready.

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

root = uigridlayout(fig, [4 1]);
root.Tag = 'zef_ui_root';
root.RowHeight = {'1x', 36, 36, 36};
root.Padding = [12 12 12 12];
root.RowSpacing = 8;
try
    root.BackgroundColor = theme.color.bg;
    root.Scrollable = 'off';
catch
end

lst = local_h('h_lf_item_list');
if isempty(lst)
    lst = local_first([findall(fig, 'Type', 'uilistbox'); ...
        findall(fig, 'Type', 'uitable')]);
end
local_put(root, lst, 1, 1);

r2 = local_grid(root, [1 4], theme);
r2.ColumnWidth = {128, 128, 'fit', '1x'};
r2.ColumnSpacing = 8;
r2.Padding = [0 0 0 0];
local_put(r2, local_h('h_add_lf_item'), 1, 1);
del = local_h('h_delete_selected');
if isempty(del)
    del = local_button(fig, 'Delete');
end
local_put(r2, del, 1, 2);
local_put(r2, local_label(fig, 'Tag:'), 1, 3);
local_put(r2, local_h('h_lf_tag'), 1, 4);

r3 = local_grid(root, [1 4], theme);
r3.ColumnWidth = {180, 180, 'fit', '1x'};
r3.ColumnSpacing = 8;
r3.Padding = [0 0 0 0];
um = local_h('h_lf_bank_update_measurements');
if isempty(um)
    um = local_button(fig, 'Update measurements');
end
un = local_h('h_lf_bank_update_noise_data');
if isempty(un)
    un = local_button(fig, 'Update noise');
end
local_put(r3, um, 1, 1);
local_put(r3, un, 1, 2);
local_put(r3, local_label(fig, 'Scaling'), 1, 3);
local_put(r3, local_h('h_lf_bank_scaling_factor'), 1, 4);

r4 = local_grid(root, [1 6], theme);
r4.ColumnWidth = {'1x', 168, '1x', 148, 148, '1x'};
r4.ColumnSpacing = 8;
r4.Padding = [0 0 0 0];
mg = local_h('h_merge_lead_fields');
if isempty(mg)
    mg = local_button(fig, 'Merge lead fields');
end
local_put(r4, mg, 1, 2);
norm = local_h('h_lf_normalization');
if isempty(norm)
    norm = local_first(findall(fig, 'Type', 'uidropdown'));
end
local_put(r4, norm, 1, 3);
cmp = local_h('h_lf_bank_compute_lead_fields');
if isempty(cmp)
    cmp = local_button(fig, 'Compute lead fields');
end
mk = local_h('h_lf_bank_make_all');
if isempty(mk)
    mk = local_button(fig, 'Make all');
end
local_put(r4, cmp, 1, 4);
local_put(r4, mk, 1, 5);
try
    setappdata(cmp, 'ZefPrimary', true);
catch
end

zef_ui_hide_orphans(fig);
zef_ui_apply_size(fig, 920, 400, 760, 340);
try
    fig.AutoResizeChildren = 'off';
catch
end

end

function g = local_grid(parent, sz, theme)

g = uigridlayout(parent, sz);
try
    g.BackgroundColor = theme.color.bg;
catch
end

end

function local_put(parent, h, row, col)

if isempty(h) || ~isgraphics(h(1)) || ~isvalid(h(1))
    return
end
h = h(1);
try
    h.Parent = parent;
    h.Layout.Row = row;
    h.Layout.Column = col;
catch
    try
        h.Layout = matlab.ui.layout.GridLayoutOptions('Row', row, 'Column', col);
    catch
    end
end

end

function h = local_h(name)

h = gobjects(0);
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, name) && isgraphics(zef.(name))
        h = zef.(name);
    end
catch
end

end

function h = local_label(fig, txt)

h = gobjects(0);
labs = findall(fig, 'Type', 'uilabel');
needle = lower(strtrim(txt));
for i = 1:numel(labs)
    try
        t = lower(strtrim(char(string(labs(i).Text))));
        if contains(t, needle)
            h = labs(i);
            return
        end
    catch
    end
end

end

function h = local_button(fig, txt)

h = gobjects(0);
btns = [findall(fig, 'Type', 'uibutton'); findall(fig, 'Style', 'pushbutton')];
needle = lower(strtrim(txt));
for i = 1:numel(btns)
    try
        if isprop(btns(i), 'Text')
            t = lower(strtrim(char(string(btns(i).Text))));
        else
            t = lower(strtrim(char(string(btns(i).String))));
        end
        if contains(t, needle)
            h = btns(i);
            return
        end
    catch
    end
end

end

function h = local_first(objs)

h = gobjects(0);
if isempty(objs)
    return
end
h = objs(1);

end
