function zef_layout_source_tree(fig)
%ZEF_LAYOUT_SOURCE_TREE  Grid layout for the Source tree tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_open_source_tree, zef_ui_ready.

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
root.RowHeight = {'1.1x', '1.3x', 'fit', 76};
root.Padding = [12 12 12 12];
root.RowSpacing = 8;
try
    root.BackgroundColor = theme.color.bg;
    root.Scrollable = 'off';
catch
end

tree_row = uigridlayout(root, [2 2]);
tree_row.ColumnWidth = {'1x', 220};
tree_row.RowHeight = {22, '1x'};
tree_row.ColumnSpacing = 10;
tree_row.Padding = [0 0 0 0];
try
    tree_row.BackgroundColor = theme.color.bg;
catch
end
lab_tree = local_label(fig, 'Source tree');
local_put(tree_row, lab_tree, 1, 1);
tr = local_first(findall(fig, 'Type', 'uitree'));
local_put(tree_row, tr, 2, 1);

btns = uigridlayout(tree_row, [2 2]);
btns.Layout.Row = 2;
btns.Layout.Column = 2;
btns.RowHeight = {32, 32};
btns.ColumnWidth = {'1x', '1x'};
btns.RowSpacing = 6;
btns.ColumnSpacing = 6;
btns.Padding = [0 0 0 0];
try
    btns.BackgroundColor = theme.color.bg;
catch
end
local_put(btns, local_button(fig, 'Add node'), 1, 1);
local_put(btns, local_button(fig, 'Delete node'), 1, 2);
local_put(btns, local_button(fig, 'Add root'), 2, 1);
local_put(btns, local_button(fig, 'Reset tree'), 2, 2);

tbls = findall(fig, 'Type', 'uitable');
src_tbl = gobjects(0);
sig_tbl = gobjects(0);
if numel(tbls) >= 1
    src_tbl = tbls(1);
end
if numel(tbls) >= 2
    names = strings(numel(tbls), 1);
    for i = 1:numel(tbls)
        try
            names(i) = string(tbls(i).Tag);
        catch
            names(i) = "";
        end
    end
    src_i = find(contains(lower(names), 'source'), 1);
    sig_i = find(contains(lower(names), 'signal'), 1);
    if ~isempty(src_i)
        src_tbl = tbls(src_i);
    end
    if ~isempty(sig_i)
        sig_tbl = tbls(sig_i);
    elseif numel(tbls) >= 2
        if isempty(src_i)
            src_tbl = tbls(1);
            sig_tbl = tbls(2);
        else
            rest = setdiff(1:numel(tbls), src_i);
            sig_tbl = tbls(rest(1));
        end
    end
end

src = uigridlayout(root, [2 1]);
src.RowHeight = {22, '1x'};
src.Padding = [0 0 0 0];
src.RowSpacing = 4;
try
    src.BackgroundColor = theme.color.bg;
catch
end
local_put(src, local_label(fig, 'Source parameters'), 1, 1);
local_put(src, src_tbl, 2, 1);
try
    zef_ui_fit_table(src_tbl);
    src_tbl.ColumnWidth = {'1.6x', '1.2x'};
catch
end

sig = uigridlayout(root, [2 1]);
sig.RowHeight = {22, local_table_h(sig_tbl, 120)};
sig.Padding = [0 0 0 0];
sig.RowSpacing = 4;
try
    sig.BackgroundColor = theme.color.bg;
catch
end
local_put(sig, local_label(fig, 'Signal parameters'), 1, 1);
local_put(sig, sig_tbl, 2, 1);
try
    zef_ui_fit_table(sig_tbl);
    sig_tbl.ColumnWidth = {'1.6x', '1.2x'};
catch
end

act = uigridlayout(root, [2 2]);
act.RowHeight = {32, 32};
act.ColumnWidth = {'1x', '1x'};
act.RowSpacing = 6;
act.ColumnSpacing = 8;
act.Padding = [0 0 0 0];
try
    act.BackgroundColor = theme.color.bg;
catch
end
local_put(act, local_button(fig, 'Plot signal'), 1, 1);
local_put(act, local_button(fig, 'Simulate signal'), 1, 2);
local_put(act, local_button(fig, 'Plot source'), 2, 1);
local_put(act, local_button(fig, 'Simulate measurements'), 2, 2);

zef_ui_hide_orphans(fig);
zef_ui_apply_size(fig, 720, 720, 560, 600);
try
    fig.AutoResizeChildren = 'off';
catch
end

end

function ht = local_table_h(tbl, fallback)

ht = fallback;
if isempty(tbl) || ~(isgraphics(tbl(1)) && isvalid(tbl(1)))
    return
end
n = 0;
try
    n = size(tbl(1).Data, 1);
catch
end
ht = max(88, 34 + min(max(n, 1), 8) * 24 + 16);

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

function h = local_first(objs)

h = gobjects(0);
if ~isempty(objs)
    h = objs(1);
end

end

function h = local_label(fig, txt)

h = gobjects(0);
labs = findall(fig, 'Type', 'uilabel');
needle = lower(strtrim(regexprep(txt, ':$', '')));
for i = 1:numel(labs)
    try
        t = lower(strtrim(regexprep(char(string(labs(i).Text)), ':$', '')));
        if strcmp(t, needle) || strncmp(t, needle, numel(needle))
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
        if strcmp(t, needle) || contains(t, needle)
            h = btns(i);
            return
        end
    catch
    end
end

end
