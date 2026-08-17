function zef_layout_form_dialog(fig)
%ZEF_LAYOUT_FORM_DIALOG  Label-and-field grid for App Designer option windows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Pairs each label with the control to its right, stacks the rows in a
%   scrollable grid, and keeps plot axes / action buttons in dedicated
%   bands. Used for graphics, forward/inverse, hierarchical prior, and
%   similar settings windows whose App Designer layout is cramped.
%
%   See also zef_ui_ready, zef_layout_table_dialog.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    return
end
if ~isempty(findall(fig, 'Type', 'uitable'))
    zef_layout_table_dialog(fig);
    return
end

theme = zef_ui_theme();
try
    fig.AutoResizeChildren = 'on';
    fig.Scrollable = 'off';
catch
end

existing_grids = findall(fig, 'Type', 'uigridlayout');
if ~isempty(existing_grids)
    local_polish_existing_form(fig, existing_grids, theme);
    return
end

labels = local_findall(fig, 'uilabel');
fields = [local_findall(fig, 'uieditfield'); ...
    local_findall(fig, 'uinumericeditfield'); ...
    local_findall(fig, 'uidropdown'); ...
    local_findall(fig, 'uispinner')];
checks = local_findall(fig, 'uicheckbox');
btns = local_findall(fig, 'uibutton');
axes_list = [local_findall(fig, 'uiaxes'); local_findall(fig, 'axes')];

if numel(labels) + numel(fields) + numel(checks) < 3
    return
end

pairs = local_pair_rows(labels, fields);
n_pair = numel(pairs);
n_labeled = 0;
for i = 1:n_pair
    if ~isempty(pairs{i}{1})
        n_labeled = n_labeled + 1;
    end
end
if n_labeled < max(3, round(0.5 * numel(fields)))
    fig.SizeChangedFcn = '';
    zef_ui_bind_min_size(fig, 400, 240);
    return
end
n_check = numel(checks);
n_check_rows = ceil(max(n_check, 1) / 2);
has_axes = ~isempty(axes_list);
has_btns = ~isempty(btns);
extra = double(has_btns && n_check == 0 && ~has_axes && n_pair > 0);
n_root = 1 + double(n_check > 0) + double(has_axes) + double(has_btns && extra == 0);
root = uigridlayout(fig, [n_root 1]);
root.Tag = 'zef_ui_root';
root.Padding = [12 12 12 12];
root.RowSpacing = 8;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end
row_h = repmat({'fit'}, 1, n_root);
if has_axes
    ax_row = 1 + double(n_check > 0) + 1;
    row_h{ax_row} = '1x';
end
root.RowHeight = row_h;
try
    root.BackgroundColor = theme.color.bg;
catch
end

if n_pair > 0
    form_parent = root;
    center_card = extra > 0 && n_pair <= 8 && ~has_axes && n_check == 0;
    if center_card
        host = uigridlayout(root, [1 3]);
        host.ColumnWidth = {'1x', 'fit', '1x'};
        host.Padding = [0 0 0 0];
        try
            host.BackgroundColor = theme.color.bg;
        catch
        end
        form_parent = host;
    end
    form = uigridlayout(form_parent, [n_pair + extra 2]);
    if center_card
        form.Layout.Row = 1;
        form.Layout.Column = 2;
        form.ColumnWidth = {'fit', 152};
    else
        form.ColumnWidth = {'fit', '1x'};
    end
    rh = repmat({28}, 1, n_pair + extra);
    form.RowHeight = rh;
    form.RowSpacing = 8;
    form.ColumnSpacing = 10;
    form.Padding = [10 10 10 10];
    try
        if n_pair > 14
            form.Scrollable = 'on';
        else
            form.Scrollable = 'off';
        end
        form.BackgroundColor = theme.color.panel;
    catch
    end
    for i = 1:n_pair
        lab = pairs{i}{1};
        fld = pairs{i}{2};
        if ~isempty(lab)
            try
                lab.Parent = form;
                try
                    lab.Layout.Row = i;
                    lab.Layout.Column = 1;
                catch
                    lab.Layout = matlab.ui.layout.GridLayoutOptions('Row', i, 'Column', 1);
                end
                lab.HorizontalAlignment = 'right';
                lab.WordWrap = 'off';
                lab.FontWeight = 'normal';
                lab.Text = local_clean_label(lab.Text);
            catch
            end
        end
        if ~isempty(fld)
            try
                fld.Parent = form;
                try
                    fld.Layout.Row = i;
                    fld.Layout.Column = 2;
                catch
                    fld.Layout = matlab.ui.layout.GridLayoutOptions('Row', i, 'Column', 2);
                end
            catch
            end
        end
    end
end

if n_check > 0
    chk = uigridlayout(root, [n_check_rows 2]);
    chk.ColumnWidth = {'1x', '1x'};
    chk.RowHeight = repmat({26}, 1, n_check_rows);
    chk.Padding = [12 8 12 8];
    chk.ColumnSpacing = 16;
    try
        chk.BackgroundColor = theme.color.panel;
    catch
    end
    for i = 1:n_check
        if isvalid(checks(i))
            try
                checks(i).Text = local_clean_label(checks(i).Text);
                checks(i).FontWeight = 'normal';
            catch
            end
            checks(i).Parent = chk;
        end
    end
end

if has_axes
    ax_host = uigridlayout(root, [1 1]);
    ax_host.Padding = [0 0 0 0];
    try
        ax_host.BackgroundColor = theme.color.panel;
    catch
    end
    try
        axes_list(1).Parent = ax_host;
    catch
    end
end

btns_in_form = false;
if has_btns && extra > 0 && n_pair > 0 && numel(btns) == 1
    try
        brow = uigridlayout(form, [1 3]);
        brow.Layout.Row = n_pair + 1;
        brow.Layout.Column = [1 2];
        brow.ColumnWidth = {'1x', 108, '1x'};
        brow.Padding = [0 0 0 0];
        brow.ColumnSpacing = 8;
        try
            brow.BackgroundColor = theme.color.panel;
        catch
        end
        uilabel(brow, 'Text', '');
        btns(1).Parent = brow;
        try
            btns(1).Layout.Column = 2;
        catch
        end
        btns_in_form = true;
    catch
    end
end

if has_btns && ~btns_in_form
    n = numel(btns);
    brow = uigridlayout(root, [1 n + 1]);
    brow.ColumnWidth = [{'1x'}, repmat({108}, 1, n)];
    brow.RowHeight = {28};
    brow.Padding = [0 0 0 0];
    brow.ColumnSpacing = 8;
    try
        brow.BackgroundColor = theme.color.bg;
    catch
    end
    uilabel(brow, 'Text', '');
    for i = 1:n
        try
            btns(i).Parent = brow;
        catch
        end
    end
end

fig.SizeChangedFcn = '';
need_h = 180;
need_w = 400;
try
    orig = fig.Units;
    fig.Units = 'pixels';
    need_h = 24 + n_pair * 36 + double(n_check > 0) * (12 + n_check_rows * 28) ...
        + double(has_axes) * 180 + double(has_btns) * 40;
    need_w = local_form_width(labels);
    scr = get(groot, 'ScreenSize');
    fig.Position(3) = min(need_w, round(0.82 * scr(3)));
    fig.Position(4) = min(max(need_h, 160), round(0.78 * scr(4)));
    if need_h > fig.Position(4) + 8
        fig.Scrollable = 'on';
    end
    fig.Units = orig;
catch
end
fig.SizeChangedFcn = '';
try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
min_h = max(160, min(need_h, fig.Position(4)));
min_w = max(360, min(need_w, fig.Position(3)));
zef_ui_bind_min_size(fig, min_w, min_h);

end

function objs = local_findall(fig, typ)

objs = findall(fig, 'Type', typ);
if isempty(objs)
    objs = gobjects(0);
else
    objs = objs(:);
end

end

function pairs = local_pair_rows(labels, fields)

pairs = {};
used_lab = false(numel(labels), 1);
row_lab = {};
row_fld = {};
row_y = [];

for j = 1:numel(fields)
    fp = local_pos(fields(j));
    best = 0;
    best_score = inf;
    for i = 1:numel(labels)
        if used_lab(i)
            continue
        end
        lp = local_pos(labels(i));
        dy = abs((lp(2) + lp(4) / 2) - (fp(2) + fp(4) / 2));
        if dy > 28
            continue
        end
        if lp(1) > fp(1) - 8
            continue
        end
        gap = max(0, fp(1) - lp(1));
        score = dy + 0.01 * gap;
        if score < best_score
            best_score = score;
            best = i;
        end
    end
    row_fld{end+1} = fields(j); %#ok<AGROW>
    row_y(end+1) = fp(2); %#ok<AGROW>
    if best > 0
        used_lab(best) = true;
        row_lab{end+1} = labels(best); %#ok<AGROW>
        row_y(end) = max(row_y(end), local_pos(labels(best), 2));
    else
        row_lab{end+1} = []; %#ok<AGROW>
    end
end

n_paired = sum(~cellfun(@isempty, row_lab));
if n_paired >= max(1, round(0.5 * numel(fields)))
    for i = 1:numel(labels)
        if used_lab(i)
            continue
        end
        try
            labels(i).Visible = 'off';
        catch
        end
    end
end

if isempty(row_fld)
    return
end
[~, order] = sort(row_y, 'descend');
for i = 1:numel(order)
    k = order(i);
    pairs{end+1} = {row_lab{k}, row_fld{k}}; %#ok<AGROW>
end

end

function txt = local_clean_label(txt)

try
    txt = char(string(txt));
catch
    txt = '';
    return
end
map = { ...
    'Inflation strenth:', 'Inflation strength:'; ...
    'Exclude_box', 'Exclude box'; ...
    'Colormap size :', 'Colormap size:'; ...
    'Hyperprior tail length (dB)::', 'Hyperprior tail length (dB):'};
for i = 1:size(map, 1)
    if strcmp(strtrim(txt), map{i, 1})
        txt = map{i, 2};
        return
    end
end
txt = regexprep(txt, ':+$', ':');
txt = strrep(txt, '_', ' ');

end

function p = local_pos(h, idx)

p = [0 0 40 22];
try
    p = h.Position;
catch
end
if numel(p) < 4
    p = [0 0 40 22];
end
if nargin >= 2
    p = p(idx);
end

end

function w = local_form_width(labels)

lab_px = local_label_width(labels);
w = max(360, min(480, 48 + lab_px + 168));

end

function lab_w = local_label_width(labels)

lab_w = 132;
max_n = 0;
for i = 1:numel(labels)
    try
        max_n = max(max_n, numel(char(string(labels(i).Text))));
    catch
    end
end
lab_w = min(220, max(120, round(7.2 * max_n) + 14));

end

function local_polish_existing_form(fig, grids, theme)

top = grids(1);
for i = 1:numel(grids)
    try
        if isequal(grids(i).Parent, fig)
            top = grids(i);
            break
        end
    catch
    end
end
try
    top.Tag = 'zef_ui_root';
    top.Padding = min(top.Padding, [12 12 12 12]);
    top.RowSpacing = min(top.RowSpacing, 8);
    top.ColumnSpacing = min(top.ColumnSpacing, 10);
    try
        top.BackgroundColor = theme.color.bg;
        top.Scrollable = 'off';
    catch
    end
catch
    top.Tag = 'zef_ui_root';
end

n_two = 0;
for i = 1:numel(grids)
    if ~isvalid(grids(i))
        continue
    end
    try
        cw = grids(i).ColumnWidth;
    catch
        continue
    end
    if numel(cw) ~= 2
        continue
    end
    n_two = n_two + 1;
    try
        lab_w = local_label_width(local_findall(fig, 'uilabel'));
        grids(i).ColumnWidth = {'fit', '1x'};
        grids(i).ColumnSpacing = min(grids(i).ColumnSpacing, 10);
        rh = grids(i).RowHeight;
        for r = 1:numel(rh)
            if isnumeric(rh{r})
                rh{r} = max(28, rh{r});
            elseif ischar(rh{r}) && strcmp(rh{r}, 'fit')
                rh{r} = 28;
            end
        end
        grids(i).RowHeight = rh;
        try
            grids(i).BackgroundColor = theme.color.panel;
        catch
        end
    catch
    end
end

labs = local_findall(fig, 'uilabel');
max_n = 0;
for i = 1:numel(labs)
    try
        labs(i).Text = local_clean_label(labs(i).Text);
        labs(i).FontWeight = 'normal';
        labs(i).WordWrap = 'off';
        labs(i).HorizontalAlignment = 'right';
        max_n = max(max_n, numel(char(string(labs(i).Text))));
    catch
    end
end
cbs = local_findall(fig, 'uicheckbox');
for i = 1:numel(cbs)
    try
        cbs(i).Text = local_clean_label(cbs(i).Text);
    catch
    end
end

need_w = max(360, min(520, 48 + min(220, max(120, round(7.2 * max_n))) + 180));
n_rows = max(n_two, numel(labs));
need_h = min(640, max(180, 28 + n_rows * 34 + 24));
if n_rows > 16
    try
        top.Scrollable = 'on';
        need_h = min(need_h, 560);
    catch
    end
end
try
    orig = fig.Units;
    fig.Units = 'pixels';
    scr = get(groot, 'ScreenSize');
    fig.Position(3) = min(need_w, round(0.82 * scr(3)));
    fig.Position(4) = min(need_h, round(0.78 * scr(4)));
    fig.Units = orig;
catch
end

fig.SizeChangedFcn = '';
try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_bind_min_size(fig, max(360, min(need_w, 400)), max(180, min(need_h, 240)));

end
