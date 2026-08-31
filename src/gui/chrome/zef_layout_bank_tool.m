function zef_layout_bank_tool(fig)
%ZEF_LAYOUT_BANK_TOOL  Stretchy two-table layout for LF / reconstruction banks.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   See also zef_ui_ready, LeadFieldProcessingTool_start,
%   zef_reconstructionTool_start.

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

local_restore_noise_labels(fig);

name = '';
try
    name = lower(char(fig.Name));
catch
end
is_rec = contains(name, 'reconstruction');

root = uigridlayout(fig, [7 1]);
root.Tag = 'zef_ui_root';
root.RowHeight = {22, 92, 36, 22, '1x', 36, 44};
root.Padding = [16 16 16 16];
root.RowSpacing = 8;
try
    root.BackgroundColor = theme.color.bg;
    root.Scrollable = 'off';
catch
end

tbls = findall(fig, 'Type', 'uitable');
cur_tbl = gobjects(0);
bank_tbl = gobjects(0);
if numel(tbls) >= 1
    ys = zeros(numel(tbls), 1);
    hs = zeros(numel(tbls), 1);
    for i = 1:numel(tbls)
        try
            gp = getpixelposition(tbls(i), true);
            ys(i) = gp(2);
            hs(i) = gp(4);
        catch
        end
    end
    [~, yo] = sort(ys, 'descend');
    cur_tbl = tbls(yo(1));
    if numel(tbls) >= 2
        bank_tbl = tbls(yo(2));
        if hs(yo(2)) < hs(yo(1)) * 0.7
            cur_tbl = tbls(yo(2));
            bank_tbl = tbls(yo(1));
        end
    end
end

cur_lab = local_label(fig, 'Current');
if isempty(cur_lab)
    cur_lab = local_label(fig, 'Current leadfield');
end
if isempty(cur_lab)
    cur_lab = local_label(fig, 'Current reconstruction');
end
saved_lab = local_label(fig, 'Saved');
local_put(root, cur_lab, 1, 1);
local_put(root, cur_tbl, 2, 1);
try
    zef_ui_fit_table(cur_tbl);
catch
end

cur_row = uigridlayout(root, [1 4]);
cur_row.ColumnWidth = {'fit', 'fit', 'fit', 'fit'};
cur_row.Padding = [0 0 0 0];
cur_row.ColumnSpacing = 8;
try
    cur_row.BackgroundColor = theme.color.bg;
catch
end
local_put(cur_row, local_button(fig, 'Add'), 1, 1);
local_put(cur_row, local_button(fig, 'replace'), 1, 2);
local_put(cur_row, local_button(fig, 'refresh'), 1, 3);
imp = local_button(fig, 'Import');
if ~isempty(imp)
    local_put(cur_row, imp, 1, 4);
end

local_put(root, saved_lab, 4, 1);
local_put(root, bank_tbl, 5, 1);
try
    zef_ui_fit_table(bank_tbl);
catch
end

del_row = uigridlayout(root, [1 2]);
del_row.ColumnWidth = {'fit', '1x'};
del_row.Padding = [0 0 0 0];
try
    del_row.BackgroundColor = theme.color.bg;
catch
end
local_put(del_row, local_button(fig, 'delete'), 1, 1);

foot = uigridlayout(root, [1 8]);
foot.ColumnWidth = {'fit', 'fit', 'fit', 88, 'fit', 88, '1x', 'fit'};
foot.Padding = [0 0 0 0];
foot.ColumnSpacing = 8;
try
    foot.BackgroundColor = theme.color.bg;
catch
end
if is_rec
    local_put(foot, local_label(fig, 'Function'), 1, 1);
    dds = findall(fig, 'Type', 'uidropdown');
    if ~isempty(dds)
        local_put(foot, dds(1), 1, 2);
    end
    local_put(foot, local_button(fig, 'Apply transformation'), 1, 8);
else
    local_put(foot, local_button(fig, 'loadTra'), 1, 1);
    local_put(foot, local_button(fig, 'Mag2Grad'), 1, 2);
    ns = local_label(fig, 'Noise start');
    if isempty(ns)
        ns = local_label(fig, 'Noise st');
    end
    local_put(foot, ns, 1, 3);
    sp = findall(fig, 'Type', 'uispinner');
    if numel(sp) >= 1
        local_put(foot, local_first_spinner(sp, 'start'), 1, 4);
    end
    ne = local_label(fig, 'Noise end');
    local_put(foot, ne, 1, 5);
    if numel(sp) >= 2
        local_put(foot, local_first_spinner(sp, 'end'), 1, 6);
    end
    local_put(foot, local_button(fig, 'Combine'), 1, 8);
end

zef_ui_hide_orphans(fig);
if is_rec
    zef_ui_apply_size(fig, 900, 520, 720, 420);
else
    zef_ui_apply_size(fig, 920, 540, 760, 440);
end
try
    fig.AutoResizeChildren = 'off';
catch
end

end

function local_restore_noise_labels(fig)

labs = findall(fig, 'Type', 'uilabel');
for i = 1:numel(labs)
    try
        t = strtrim(char(string(labs(i).Text)));
        tl = lower(t);
        if strcmp(tl, 'noise st') || strcmp(tl, 'noise st:') ...
                || strncmp(tl, 'noise st', 8) && ~contains(tl, 'start') ...
                && ~contains(tl, 'end')
            labs(i).Text = 'Noise start:';
        end
        labs(i).WordWrap = 'off';
    catch
    end
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

function h = local_first_spinner(sp, which)

h = gobjects(0);
if isempty(sp)
    return
end
for i = 1:numel(sp)
    tg = '';
    try
        tg = lower(char(string(sp(i).Tag)));
    catch
    end
    if contains(tg, which)
        h = sp(i);
        return
    end
end
if strcmp(which, 'start')
    h = sp(1);
elseif numel(sp) >= 2
    h = sp(2);
else
    h = sp(1);
end

end

function h = local_button(fig, txt)

h = gobjects(0);
btns = findall(fig, 'Type', 'uibutton');
needle = lower(strtrim(txt));
for i = 1:numel(btns)
    try
        t = lower(strtrim(char(string(btns(i).Text))));
        if strcmp(t, needle)
            h = btns(i);
            return
        end
    catch
    end
end
for i = 1:numel(btns)
    try
        t = lower(strtrim(char(string(btns(i).Text))));
        if contains(t, needle)
            h = btns(i);
            return
        end
    catch
    end
end

end
