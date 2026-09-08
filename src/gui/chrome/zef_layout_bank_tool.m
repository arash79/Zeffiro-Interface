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
    try
        if isappdata(fig, 'ZefBankLayoutV') && isequal(getappdata(fig, 'ZefBankLayoutV'), 3)
            local_restore_action_widths(fig);
            zef_ui_adapt_grid(fig);
            return
        end
    catch
    end
    local_reparent_to_fig(fig);
end

theme = zef_ui_theme();
local_prepare_uifigure(fig);

app = [];
try
    if isappdata(fig, 'ZefBankApp')
        app = getappdata(fig, 'ZefBankApp');
    end
catch
end

local_restore_noise_labels(fig);

name = '';
try
    name = lower(char(fig.Name));
catch
end
is_rec = contains(name, 'reconstruction');

root = [];
for attempt = 1:3
    local_prepare_uifigure(fig);
    try
        root = uigridlayout(fig, [6 1]);
        break
    catch
        if attempt == 3
            return
        end
        pause(0.2);
        drawnow;
    end
end
if isempty(root) || ~(isgraphics(root) && isvalid(root))
    return
end
root.Tag = 'zef_ui_root';
root.RowHeight = {22, 88, 36, 22, '1x', 44};
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
if ~isempty(app)
    try
        if isprop(app, 'currentLeadfield') && ~isempty(app.currentLeadfield)
            cur_tbl = app.currentLeadfield;
        elseif isprop(app, 'current') && ~isempty(app.current)
            cur_tbl = app.current;
        end
    catch
    end
    try
        if isprop(app, 'BankTable') && ~isempty(app.BankTable)
            bank_tbl = app.BankTable;
        end
    catch
    end
end
if isempty(cur_tbl) || isempty(bank_tbl)
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
end

cur_lab = local_label(fig, 'Current');
if isempty(cur_lab)
    cur_lab = local_label(fig, 'Current leadfield');
end
if isempty(cur_lab)
    cur_lab = local_label(fig, 'Current reconstruction');
end
saved_lab = local_label(fig, 'Saved');
local_header_style(cur_lab, theme);
local_header_style(saved_lab, theme);
local_put(root, cur_lab, 1, 1);
local_put(root, cur_tbl, 2, 1);
try
    zef_ui_fit_table(cur_tbl);
catch
end
try
    root.RowHeight{2} = local_table_h(cur_tbl, 88);
catch
end

add_b = local_app_or_btn(app, {'AddButton'}, fig, 'Add');
rep_b = local_app_or_btn(app, {'replaceButton'}, fig, 'replace');
ref_b = local_app_or_btn(app, {'refreshButton', 'RefreshButton'}, fig, 'refresh');
imp = local_app_or_btn(app, {'ImportButton'}, fig, 'Import');
n_cur = 3 + double(~isempty(imp));
cur_row = uigridlayout(root, [1 n_cur + 2]);
cur_row.Tag = 'zef_bank_cur';
cur_row.ColumnWidth = [{'1x'}, repmat({104}, 1, n_cur), {'1x'}];
cur_row.Padding = [0 0 0 0];
cur_row.ColumnSpacing = 8;
try
    cur_row.BackgroundColor = theme.color.bg;
catch
end
local_put(cur_row, local_rename(add_b, 'Add'), 1, 2);
local_put(cur_row, local_rename(rep_b, 'Replace'), 1, 3);
local_put(cur_row, local_rename(ref_b, 'Refresh'), 1, 4);
if ~isempty(imp)
    local_put(cur_row, local_rename(imp, 'Import'), 1, 5);
end

local_put(root, saved_lab, 4, 1);
local_put(root, bank_tbl, 5, 1);
try
    zef_ui_fit_table(bank_tbl);
catch
end

del_b = local_app_or_btn(app, {'deleteButton'}, fig, 'delete');
local_rename(del_b, 'Delete');

if is_rec
    wrap = uigridlayout(root, [1 3]);
    wrap.Tag = 'zef_bank_foot';
    wrap.ColumnWidth = {'1x', 'fit', '1x'};
    wrap.Padding = [0 0 0 0];
    wrap.ColumnSpacing = 8;
    try
        wrap.BackgroundColor = theme.color.bg;
    catch
    end
    foot = uigridlayout(wrap, [1 4]);
    try
        foot.Layout.Column = 2;
    catch
    end
    foot.ColumnWidth = {104, 'fit', 220, 'fit'};
    foot.Padding = [0 0 0 0];
    foot.ColumnSpacing = 8;
    try
        foot.BackgroundColor = theme.color.bg;
    catch
    end
    local_put(foot, del_b, 1, 1);
    local_put(foot, local_label(fig, 'Function'), 1, 2);
    dds = gobjects(0);
    try
        if ~isempty(app) && isprop(app, 'FunctionDropDown')
            dds = app.FunctionDropDown;
        end
    catch
    end
    if isempty(dds)
        dds = findall(fig, 'Type', 'uidropdown');
    end
    if ~isempty(dds)
        local_put(foot, dds(1), 1, 3);
    end
    apply_b = local_app_or_btn(app, {'ApplytransformationButton'}, fig, ...
        'Apply transformation');
    local_put(foot, apply_b, 1, 4);
    try
        setappdata(apply_b, 'ZefPrimary', true);
    catch
    end
else
    orig = gobjects(0);
    try
        if ~isempty(app) && isprop(app, 'DeleteoriginalCheckBox')
            orig = app.DeleteoriginalCheckBox;
        end
    catch
    end
    if ~isempty(orig)
        try
            orig.Text = 'Delete original';
        catch
        end
        foot = uigridlayout(root, [1 11]);
        foot.ColumnWidth = {'1x', 104, 'fit', 'fit', 'fit', 72, 'fit', 72, 'fit', 104, '1x'};
    else
        foot = uigridlayout(root, [1 10]);
        foot.ColumnWidth = {'1x', 104, 'fit', 'fit', 'fit', 72, 'fit', 72, 104, '1x'};
    end
    foot.Tag = 'zef_bank_foot';
    foot.Padding = [0 0 0 0];
    foot.ColumnSpacing = 8;
    try
        foot.BackgroundColor = theme.color.bg;
    catch
    end
    local_put(foot, del_b, 1, 2);
    load_b = local_app_or_btn(app, {'loadTraButton'}, fig, 'loadTra');
    mag_b = local_app_or_btn(app, {'Mag2GradButton'}, fig, 'Mag2Grad');
    comb_b = local_app_or_btn(app, {'CombineButton'}, fig, 'Combine');
    local_put(foot, local_rename(load_b, 'Load transform'), 1, 3);
    local_put(foot, local_rename(mag_b, 'Mag to Grad'), 1, 4);
    ns = local_label(fig, 'Noise start');
    if isempty(ns)
        ns = local_label(fig, 'Noise st');
    end
    local_put(foot, ns, 1, 5);
    sp = findall(fig, 'Type', 'uispinner');
    if numel(sp) >= 1
        local_put(foot, local_first_spinner(sp, 'start'), 1, 6);
    end
    ne = local_label(fig, 'Noise end');
    local_put(foot, ne, 1, 7);
    if numel(sp) >= 2
        local_put(foot, local_first_spinner(sp, 'end'), 1, 8);
    end
    comb_col = 9;
    if ~isempty(orig)
        local_put(foot, orig, 1, 9);
        comb_col = 10;
    end
    local_put(foot, local_rename(comb_b, 'Combine'), 1, comb_col);
    try
        setappdata(comb_b, 'ZefPrimary', true);
    catch
    end
    try
        if ~isempty(app) && isprop(app, 'ApplytransformationButton')
            app.ApplytransformationButton.Visible = 'off';
        end
    catch
    end
end

zef_ui_hide_orphans(fig);
setappdata(fig, 'ZefBankLayoutV', 3);
try
    drawnow;
    local_restore_action_widths(fig);
catch
end
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

function local_prepare_uifigure(fig)

try
    fig.SizeChangedFcn = '';
catch
end
try
    fig.AutoResizeChildren = 'off';
catch
end
try
    fig.Scrollable = 'off';
catch
end
try
    fig.Units = 'pixels';
catch
end
try
    drawnow;
catch
end

end

function ht = local_table_h(tbl, fallback)

ht = fallback;
if isempty(tbl) || ~(isgraphics(tbl(1)) && isvalid(tbl(1)))
    return
end
n = 1;
try
    n = max(1, size(tbl(1).Data, 1));
catch
end
ht = max(72, min(120, 36 + min(n, 4) * 24 + 28));

end

function local_header_style(h, theme)

if isempty(h) || ~(isgraphics(h(1)) && isvalid(h(1)))
    return
end
try
    h.FontWeight = 'bold';
    h.FontColor = theme.color.header;
    h.FontSize = theme.font.size;
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

function h = local_rename(h, txt)

if isempty(h) || ~(isgraphics(h(1)) && isvalid(h(1)))
    return
end
try
    h.Text = txt;
catch
end

end

function local_restore_action_widths(fig)

cur = findall(fig, 'Tag', 'zef_bank_cur');
if ~isempty(cur)
    n_btn = numel(findall(cur(1), 'Type', 'uibutton'));
    n_btn = max(1, n_btn);
    cur(1).ColumnWidth = [{'1x'}, repmat({104}, 1, n_btn), {'1x'}];
end
foot = findall(fig, 'Tag', 'zef_bank_foot');
if isempty(foot)
    return
end
n_col = numel(foot(1).ColumnWidth);
name = '';
try
    name = lower(char(fig.Name));
catch
end
if contains(name, 'reconstruction')
    foot(1).ColumnWidth = {'1x', 'fit', '1x'};
elseif n_col >= 11
    foot(1).ColumnWidth = {'1x', 104, 'fit', 'fit', 'fit', 72, 'fit', 72, 'fit', 104, '1x'};
elseif n_col >= 10
    foot(1).ColumnWidth = {'1x', 104, 'fit', 'fit', 'fit', 72, 'fit', 72, 104, '1x'};
end

end

function local_reparent_to_fig(fig)

kinds = {'uitable', 'uibutton', 'uilabel', 'uidropdown', 'uispinner', 'uicheckbox'};
for k = 1:numel(kinds)
    hs = findall(fig, 'Type', kinds{k});
    for i = 1:numel(hs)
        try
            if ~isequal(hs(i).Parent, fig)
                hs(i).Parent = fig;
            end
        catch
        end
    end
end
grids = findall(fig, 'Type', 'uigridlayout');
for i = numel(grids):-1:1
    try
        delete(grids(i));
    catch
    end
end

end

function h = local_app_or_btn(app, names, fig, txt)

h = gobjects(0);
if ~isempty(app)
    for i = 1:numel(names)
        try
            if isprop(app, names{i}) && ~isempty(app.(names{i})) ...
                    && isgraphics(app.(names{i}))
                h = app.(names{i});
                return
            end
        catch
        end
    end
end
h = local_button(fig, txt);

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
