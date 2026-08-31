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
if ~isempty(findall(fig, 'Type', 'uitable'))
    zef_layout_table_dialog(fig);
    return
end

force_rebuild = false;
try
    nm = lower(char(fig.Name));
    force_rebuild = contains(nm, 'kalman') || contains(nm, 'classical sparse') ...
        || contains(nm, 'music') ...
        || contains(nm, 'forward and inverse') || contains(nm, 'graphics processing') ...
        || contains(nm, 'gmm plot') || contains(nm, 'gmm modeling') ...
        || contains(nm, 'gm modeling') || contains(nm, 'beamformer') ...
        || contains(nm, 'dipole scan') || contains(nm, 'rap-music') ...
        || contains(nm, 'gaussian mixture') || contains(nm, 'sesame') ...
        || contains(nm, 'hierarchical l1') || contains(nm, 'l1/l2');
catch
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    if force_rebuild
        try
            local_unwind_root(fig);
        catch
            return
        end
    else
        return
    end
end

theme = zef_ui_theme();
try
    fig.SizeChangedFcn = '';
    fig.AutoResizeChildren = 'off';
    fig.Scrollable = 'off';
catch
end
try
    local_unwrap_fullsize_panel(fig);
catch
end

existing_grids = findall(fig, 'Type', 'uigridlayout');
labels = local_visible(local_findall(fig, 'uilabel'));
fields = local_visible([local_findall(fig, 'uieditfield'); ...
    local_findall(fig, 'uinumericeditfield'); ...
    local_findall(fig, 'uidropdown'); ...
    local_findall(fig, 'uispinner'); ...
    local_findall(fig, 'uitextarea')]);
checks = local_all_checks(fig);
btns = local_visible(local_findall(fig, 'uibutton'));
[btns, extra_btns] = local_split_buttons(btns);
axes_list = [local_findall(fig, 'uiaxes'); local_findall(fig, 'axes')];
if force_rebuild
    try
        if isappdata(fig, 'ZefMinSize')
            rmappdata(fig, 'ZefMinSize');
        end
    catch
    end
end
if ~isempty(existing_grids) && ~force_rebuild
    local_polish_existing_form(fig, existing_grids, theme);
    return
end

fig_panels = local_figure_panels(fig);
if ~isempty(fig_panels)
    labels = local_exclude_under(labels, fig_panels);
    fields = local_exclude_under(fields, fig_panels);
    checks = local_exclude_under(checks, fig_panels);
    btns = local_exclude_under(btns, fig_panels);
end

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
has_panel = ~isempty(fig_panels);
has_btns = ~isempty(btns);
has_extra = ~isempty(extra_btns);
n_form_cols = 1;
if n_pair >= 18
    n_form_cols = 2;
end
try
    nm_cols = lower(char(fig.Name));
    if contains(nm_cols, 'gaussian mixture')
        n_form_cols = 1;
    end
catch
end
n_form_rows = ceil(max(n_pair, 1) / n_form_cols);
est_h = 36 + n_form_rows * 32 ...
    + double(n_check > 0) * (8 + n_check_rows * 28) ...
    + double(has_axes) * 180 + double(has_panel) * 140 + double(has_btns) * 52;
try
    max_h_est = max(240, min(round(0.99 * get(groot, 'ScreenSize') * [0; 0; 0; 1]), ...
        get(groot, 'ScreenSize') * [0; 0; 0; 1] - 8));
catch
    max_h_est = 800;
end
form_scroll = est_h > max_h_est;
try
    nm_scroll = lower(char(fig.Name));
    if contains(nm_scroll, 'forward and inverse')
        form_scroll = false;
    elseif contains(nm_scroll, 'gaussian mixture')
        form_scroll = true;
    end
catch
end
has_spacer = false;
n_root = double(n_pair > 0) + double(n_check > 0) ...
    + double(has_axes) + double(has_panel) + double(has_extra) + double(has_btns);
if n_root < 1
    n_root = 1;
end
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
if form_scroll && n_pair > 0
    row_h{1} = '1x';
elseif has_axes
    ax_row = double(n_pair > 0) + double(n_check > 0) + 1;
    row_h{ax_row} = '1x';
end
root.RowHeight = row_h;
try
    root.BackgroundColor = theme.color.bg;
catch
end

if n_pair > 0
    if n_form_cols == 1
        form = uigridlayout(root, [n_form_rows 2]);
        form.ColumnWidth = {'fit', '1x'};
    else
        form = uigridlayout(root, [n_form_rows 4]);
        form.ColumnWidth = {'fit', '1x', 'fit', '1x'};
    end
    rh = repmat({26}, 1, n_form_rows);
    for i = 1:n_pair
        if local_is_textarea(pairs{i}{2})
            if n_form_cols == 1
                rh{i} = 120;
            else
                rr = i;
                if i > n_form_rows
                    rr = i - n_form_rows;
                end
                rh{rr} = max(rh{rr}, 120);
            end
        end
    end
    form.RowHeight = rh;
    form.RowSpacing = 6;
    form.ColumnSpacing = 10;
    form.Padding = [10 16 10 10];
    try
        if form_scroll
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
        if n_form_cols == 1
            rr = i;
            lc = 1;
            fc = 2;
        else
            if i <= n_form_rows
                rr = i;
                lc = 1;
                fc = 2;
            else
                rr = i - n_form_rows;
                lc = 3;
                fc = 4;
            end
        end
        if ~isempty(lab)
            try
                lab.Parent = form;
                try
                    lab.Layout.Row = rr;
                    lab.Layout.Column = lc;
                catch
                    lab.Layout = matlab.ui.layout.GridLayoutOptions('Row', rr, 'Column', lc);
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
                    fld.Layout.Row = rr;
                    fld.Layout.Column = fc;
                catch
                    fld.Layout = matlab.ui.layout.GridLayoutOptions('Row', rr, 'Column', fc);
                end
                try
                    if local_is_textarea(fld)
                        fld.WordWrap = 'on';
                    end
                catch
                end
            catch
            end
        end
    end
end

if n_check > 0
    n_chk_cols = 1 + double(n_check > 1);
    chk = uigridlayout(root, [n_check_rows n_chk_cols]);
    if n_chk_cols == 1
        chk.ColumnWidth = {'1x'};
    else
        chk.ColumnWidth = {'1x', '1x'};
    end
    chk.RowHeight = repmat({28}, 1, n_check_rows);
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
                checks(i).WordWrap = 'on';
                checks(i).Visible = 'on';
            catch
            end
            try
                checks(i).Parent = chk;
                if n_chk_cols == 1
                    checks(i).Layout.Row = i;
                    checks(i).Layout.Column = 1;
                else
                    rr = ceil(i / 2);
                    cc = 2 - mod(i, 2);
                    checks(i).Layout.Row = rr;
                    checks(i).Layout.Column = cc;
                end
            catch
                try
                    checks(i).Parent = chk;
                catch
                end
            end
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

if has_panel
    for pi = 1:numel(fig_panels)
        try
            local_layout_nested_panel(fig_panels(pi), theme);
            fig_panels(pi).Parent = root;
        catch
        end
    end
end

if has_extra
    n_ex = numel(extra_btns);
    extra_row = uigridlayout(root, [n_ex 1]);
    extra_row.ColumnWidth = {'1x'};
    extra_row.RowHeight = repmat({34}, 1, n_ex);
    extra_row.Padding = [10 4 10 4];
    extra_row.RowSpacing = 6;
    try
        extra_row.BackgroundColor = theme.color.panel;
    catch
    end
    for i = 1:n_ex
        try
            extra_btns(i).Parent = extra_row;
            extra_btns(i).Layout.Row = i;
            extra_btns(i).Layout.Column = 1;
        catch
        end
    end
end

if has_btns
    n = numel(btns);
    wrap = n >= 5;
    if wrap
        n_cols = ceil(n / 2);
        brow = uigridlayout(root, [2 n_cols]);
        brow.ColumnWidth = repmat({'1x'}, 1, n_cols);
        brow.RowHeight = {34, 34};
        brow.Padding = [0 0 0 0];
        brow.ColumnSpacing = 8;
        brow.RowSpacing = 8;
        try
            brow.BackgroundColor = theme.color.bg;
        catch
        end
        for i = 1:n
            try
                btns(i).Parent = brow;
                btns(i).Layout.Row = ceil(i / n_cols);
                btns(i).Layout.Column = i - (ceil(i / n_cols) - 1) * n_cols;
            catch
            end
        end
    else
    widths = cell(1, n);
    for i = 1:n
        widths{i} = local_btn_width(btns(i));
    end
    brow = uigridlayout(root, [1 n + 1]);
    brow.ColumnWidth = [{'1x'}, widths];
    brow.RowHeight = {34};
    brow.Padding = [0 0 0 0];
    brow.ColumnSpacing = 8;
    try
        brow.BackgroundColor = theme.color.bg;
    catch
    end
    padlab = uilabel(brow, 'Text', '');
    try
        padlab.BackgroundColor = theme.color.bg;
        padlab.Layout.Row = 1;
        padlab.Layout.Column = 1;
    catch
    end
    for i = 1:n
        try
            btns(i).Parent = brow;
            btns(i).Layout.Row = 1;
            btns(i).Layout.Column = i + 1;
        catch
        end
    end
    end
end

if exist('form', 'var') || exist('chk', 'var')
    form_h = gobjects(0);
    chk_h = gobjects(0);
    if exist('form', 'var')
        form_h = form;
    end
    if exist('chk', 'var')
        chk_h = chk;
    end
    try
        local_rescue_strays(fig, form_h, chk_h);
    catch
    end
    if ~isempty(chk_h) && isgraphics(chk_h) && isvalid(chk_h)
        try
            n_live = numel(local_findall(chk_h, 'uicheckbox'));
            n_check_rows = max(n_check_rows, ceil(max(n_live, 1) / 2));
            chk_h.RowHeight = repmat({26}, 1, n_check_rows);
        catch
        end
    end
end

fig.SizeChangedFcn = '';
need_h = 180;
need_w = 400;
n_form_cols = 1;
n_form_rows = n_pair;
if n_pair >= 18
    n_form_cols = 2;
    n_form_rows = ceil(n_pair / 2);
end
try
    nm_cols2 = lower(char(fig.Name));
    if contains(nm_cols2, 'gaussian mixture')
        n_form_cols = 1;
        n_form_rows = n_pair;
    end
catch
end
try
    orig = fig.Units;
    fig.Units = 'pixels';
    ta_extra = 0;
    for i = 1:n_pair
        if local_is_textarea(pairs{i}{2})
            ta_extra = ta_extra + 92;
        end
    end
    need_h = 36 + n_form_rows * 32 + ta_extra ...
        + double(n_check > 0) * (12 + n_check_rows * 32) ...
        + double(has_axes) * 180 + double(has_panel) * 140 ...
        + double(has_extra) * (16 + numel(extra_btns) * 40) ...
        + double(has_btns) * (52 + 40 * double(numel(btns) >= 5));
    if n_form_cols > 1
        need_h = need_h + 12;
    end
    need_w = local_form_width(fig, labels, n_pair, n_form_cols);
    if has_btns
        if numel(btns) >= 4
            need_w = max(need_w, 560);
        else
        btn_need = 48;
        for i = 1:numel(btns)
            btn_need = btn_need + local_btn_width(btns(i)) + 8;
        end
        need_w = max(need_w, min(760, btn_need));
        end
    end
    if ta_extra > 0
        need_w = max(need_w, 680);
    end
    if n_check > 0
        need_w = max(need_w, 480);
    end
    if n_form_cols > 1
        need_w = max(need_w, 680);
    end
    scr = get(groot, 'ScreenSize');
    max_h = max(240, min(round(0.99 * scr(4)), scr(4) - 8));
    fig.Position(3) = min(need_w, min(round(0.99 * scr(3)), scr(3) - 8));
    fig.Position(4) = min(max(need_h, 160), max_h);
    try
        if exist('form', 'var') && isgraphics(form) && isvalid(form)
            form.Scrollable = 'off';
        end
        root.Scrollable = 'off';
        fig.Scrollable = 'off';
    catch
    end
    if need_h > fig.Position(4) + 8 || contains(lower(char(fig.Name)), 'gaussian mixture')
        try
            if exist('form', 'var') && isgraphics(form) && isvalid(form)
                form.Scrollable = 'on';
            end
        catch
        end
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
try
    zef_ui_hide_orphans(fig);
catch
end
try
    fig.AutoResizeChildren = 'off';
    fig.Units = 'pixels';
    root.Position = [1 1 fig.Position(3) fig.Position(4)];
catch
end
def_w = max(need_w, 400);
def_h = max(need_h, 240);
nm_end = '';
try
    nm_end = lower(char(fig.Name));
catch
end
if contains(nm_end, 'rap-music')
    zef_ui_apply_size(fig, max(need_w, 560), max(need_h, 400), 480, 360);
elseif contains(nm_end, 'sesame')
    zef_ui_apply_size(fig, max(need_w, 560), max(need_h, 520), 500, 460);
elseif contains(nm_end, 'beamformer')
    zef_ui_apply_size(fig, max(need_w, 640), max(need_h, 660), 560, 620);
elseif contains(nm_end, 'graphics processing')
    zef_ui_apply_size(fig, max(need_w, 500), max(need_h, 560), 460, max(need_h, 548));
elseif contains(nm_end, 'forward and inverse')
    zef_ui_apply_size(fig, max(need_w, 920), max(need_h, 844), 900, max(760, round(0.92 * def_h)));
elseif contains(nm_end, 'gaussian mixture')
    zef_ui_apply_size(fig, max(need_w, 640), max(need_h, 860), 560, 740);
elseif contains(nm_end, 'gmm plot') || contains(nm_end, 'gmm modeling') ...
        || contains(nm_end, 'gm modeling')
    zef_ui_apply_size(fig, max(need_w, 440), max(need_h, 240), 400, 220);
elseif n_pair <= 6 && n_check == 0 && ~has_axes && need_w <= 380
    zef_ui_apply_size(fig, need_w, max(need_h, 160), ...
        max(320, round(0.90 * need_w)), max(140, round(0.90 * need_h)));
else
    min_w = max(360, round(0.88 * def_w));
    if n_form_cols > 1
        min_w = max(min_w, round(0.97 * def_w));
    end
    if exist('form_scroll', 'var') && form_scroll
        min_h = max(240, round(0.72 * def_h));
    else
        min_h = max(220, min(def_h, round(0.96 * def_h)));
    end
    if n_check > 0
        min_h = max(min_h, min(def_h, round(0.98 * def_h)));
        min_w = max(min_w, 460);
    end
    zef_ui_apply_size(fig, def_w, def_h, min_w, min_h);
end

end

function pans = local_figure_panels(fig)

pans = gobjects(0, 1);
try
    allp = findall(fig, 'Type', 'uipanel');
catch
    return
end
for i = 1:numel(allp)
    try
        if isequal(allp(i).Parent, fig)
            pans(end+1, 1) = allp(i); %#ok<AGROW>
        end
    catch
    end
end

end

function objs = local_exclude_under(objs, pans)

if isempty(objs) || isempty(pans)
    return
end
keep = true(numel(objs), 1);
for i = 1:numel(objs)
    try
        if local_is_under_any(objs(i), pans)
            keep(i) = false;
        end
    catch
    end
end
objs = objs(keep);

end

function tf = local_is_under_any(obj, pans)

tf = false;
if isempty(obj) || ~isgraphics(obj)
    return
end
p = obj;
guard = 0;
while ~isempty(p) && isgraphics(p) && guard < 24
    for i = 1:numel(pans)
        if isequal(p, pans(i))
            tf = true;
            return
        end
    end
    try
        p = p.Parent;
    catch
        return
    end
    guard = guard + 1;
end

end

function local_layout_nested_panel(pan, theme)

if nargin < 1 || isempty(pan) || ~isgraphics(pan) || ~isvalid(pan)
    return
end
try
    pan.BorderType = 'line';
    pan.BackgroundColor = theme.color.panel;
    pan.ForegroundColor = theme.color.text;
catch
end
gs = findall(pan, 'Type', 'uigridlayout');
host = [];
for i = 1:numel(gs)
    try
        if isequal(gs(i).Parent, pan)
            host = gs(i);
            break
        end
    catch
    end
end
labs = local_visible(findall(pan, 'Type', 'uilabel'));
flds = local_visible([findall(pan, 'Type', 'uieditfield'); ...
    findall(pan, 'Type', 'uinumericeditfield'); ...
    findall(pan, 'Type', 'uidropdown')]);
pbtns = local_visible(findall(pan, 'Type', 'uibutton'));
if ~isempty(host)
    try
        host.ColumnWidth = {'fit', '1x'};
        host.Padding = [10 10 10 10];
        host.RowSpacing = 8;
        host.ColumnSpacing = 10;
        host.BackgroundColor = theme.color.panel;
    catch
    end
    return
end
n_pair = max(numel(labs), numel(flds));
n_row = n_pair + double(~isempty(pbtns));
if n_row < 1
    return
end
g = uigridlayout(pan, [n_row 2]);
g.ColumnWidth = {'fit', '1x'};
g.RowHeight = [repmat({26}, 1, n_pair), repmat({32}, 1, double(~isempty(pbtns)))];
g.Padding = [10 10 10 10];
g.RowSpacing = 8;
g.ColumnSpacing = 10;
try
    g.BackgroundColor = theme.color.panel;
catch
end
[~, lo] = sort(local_panel_y(labs), 'descend');
labs = labs(lo);
[~, fo] = sort(local_panel_y(flds), 'descend');
flds = flds(fo);
for i = 1:n_pair
    if i <= numel(labs)
        try
            labs(i).Parent = g;
            labs(i).Layout.Row = i;
            labs(i).Layout.Column = 1;
            labs(i).HorizontalAlignment = 'right';
        catch
        end
    end
    if i <= numel(flds)
        try
            flds(i).Parent = g;
            flds(i).Layout.Row = i;
            flds(i).Layout.Column = 2;
        catch
        end
    end
end
if ~isempty(pbtns)
    try
        pbtns(1).Parent = g;
        pbtns(1).Layout.Row = n_pair + 1;
        pbtns(1).Layout.Column = [1 2];
    catch
    end
end

end

function ys = local_panel_y(objs)

ys = zeros(numel(objs), 1);
for i = 1:numel(objs)
    try
        gp = getpixelposition(objs(i), true);
        ys(i) = gp(2);
    catch
    end
end

end

function objs = local_visible(objs)

if isempty(objs)
    objs = gobjects(0);
    return
end
keep = true(numel(objs), 1);
for i = 1:numel(objs)
    try
        if ~isgraphics(objs(i)) || ~isvalid(objs(i))
            keep(i) = false;
            continue
        end
        if ~local_is_shown(objs(i))
            keep(i) = false;
            continue
        end
        if local_is_ensemble(objs(i))
            keep(i) = false;
        end
    catch
    end
end
objs = objs(keep);

end

function objs = local_all_checks(fig)

objs = local_findall(fig, 'uicheckbox');
try
    uc = findall(fig, 'Style', 'checkbox');
    if ~isempty(uc)
        objs = [objs; uc(:)];
    end
catch
end
if isempty(objs)
    objs = gobjects(0);
    return
end
keep = true(numel(objs), 1);
for i = 1:numel(objs)
    if ~isgraphics(objs(i)) || ~isvalid(objs(i)) || local_is_ensemble(objs(i))
        keep(i) = false;
        continue
    end
    for k = 1:i-1
        if keep(k) && isequal(objs(i), objs(k))
            keep(i) = false;
            break
        end
    end
end
objs = objs(keep);

end

function tf = local_is_ensemble(obj)

tf = false;
try
    tg = lower(char(string(obj.Tag)));
    if contains(tg, 'ensemble')
        tf = true;
        return
    end
catch
end
try
    if isprop(obj, 'Text')
        txt = lower(char(string(obj.Text)));
        tf = contains(txt, 'ensemble');
    end
catch
end

end

function tf = local_is_shown(obj)

tf = true;
try
    v = obj.Visible;
    if isnumeric(v) || islogical(v)
        tf = logical(v);
        return
    end
    vs = lower(strtrim(char(string(v))));
    tf = any(strcmp(vs, {'on', '1', 'true'}));
catch
    try
        tf = strcmpi(char(obj.Visible), 'on');
    catch
    end
end

end

function objs = local_findall(fig, typ)

objs = findall(fig, 'Type', typ);
if isempty(objs)
    objs = gobjects(0);
else
    objs = objs(:);
end

end

function tf = local_is_textarea(fld)

tf = false;
if isempty(fld) || ~(isgraphics(fld) && isvalid(fld))
    return
end
try
    tf = strcmpi(char(fld.Type), 'uitextarea');
catch
end

end

function [footer, extra] = local_split_buttons(btns)

footer = gobjects(0, 1);
extra = gobjects(0, 1);
if isempty(btns)
    return
end
is_foot = false(numel(btns), 1);
for i = 1:numel(btns)
    is_foot(i) = local_is_footer_btn(btns(i));
end
if any(is_foot)
    footer = local_sort_action_buttons(btns(is_foot));
    extra = btns(~is_foot);
else
    footer = local_sort_action_buttons(btns);
end

end

function tf = local_is_footer_btn(btn)

tf = false;
if nargin < 1 || isempty(btn) || ~isgraphics(btn)
    return
end
txt = '';
try
    txt = lower(strtrim(char(string(btn.Text))));
catch
end
if isempty(txt)
    return
end
keys = {'close', 'apply', 'start', 'ok', 'cancel'};
if any(strcmp(txt, keys))
    tf = true;
    return
end
for i = 1:numel(keys)
    if startsWith(txt, [keys{i} ' ']) || startsWith(txt, [keys{i} '-'])
        tf = true;
        return
    end
end
tf = contains(txt, 'pull from') || contains(txt, 'push to') ...
    || strcmp(txt, 'reset local');

end

function btns = local_sort_action_buttons(btns)

if isempty(btns)
    return
end
rank = inf(numel(btns), 1);
xs = inf(numel(btns), 1);
want = {'close', 'apply', 'start', 'ok', 'cancel', 'reset', 'pull', 'push'};
for i = 1:numel(btns)
    txt = '';
    try
        txt = lower(strtrim(char(string(btns(i).Text))));
    catch
    end
    for k = 1:numel(want)
        if contains(txt, want{k})
            rank(i) = k;
            break
        end
    end
    try
        gp = getpixelposition(btns(i), true);
        xs(i) = gp(1);
    catch
    end
end
[~, bo] = sortrows([rank, xs]);
btns = btns(bo);

end

function pairs = local_pair_rows(labels, fields)

pairs = {};
used_lab = false(numel(labels), 1);
row_lab = {};
row_fld = {};
row_y = [];

for j = 1:numel(fields)
    if ~local_keep_field(fields(j))
        continue
    end
    fp = local_pos(fields(j));
    best = 0;
    best_score = inf;
    for i = 1:numel(labels)
        if used_lab(i)
            continue
        end
        lp = local_pos(labels(i));
        lab_mid = lp(2) + lp(4) / 2;
        fld_mid = fp(2) + fp(4) / 2;
        dy = abs(lab_mid - fld_mid);
        if fp(4) > 50 && lab_mid >= fp(2) - 8 && lab_mid <= fp(2) + fp(4) + 8
            dy = 0;
        end
        if dy > 80
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

unlab = find(cellfun(@isempty, row_lab));
unused = find(~used_lab);
if ~isempty(unlab) && ~isempty(unused)
    lab_y = zeros(numel(unused), 1);
    for i = 1:numel(unused)
        lab_y(i) = local_pos(labels(unused(i)), 2);
    end
    fld_y = zeros(numel(unlab), 1);
    for i = 1:numel(unlab)
        fld_y(i) = local_pos(row_fld{unlab(i)}, 2);
    end
    taken = false(numel(unused), 1);
    for i = 1:numel(unlab)
        best = 0;
        best_dy = inf;
        for k = 1:numel(unused)
            if taken(k)
                continue
            end
            dy = abs(lab_y(k) - fld_y(i));
            if dy < 80 && dy < best_dy
                best_dy = dy;
                best = k;
            end
        end
        if best > 0
            taken(best) = true;
            li = unused(best);
            fi = unlab(i);
            used_lab(li) = true;
            row_lab{fi} = labels(li);
            row_y(fi) = max(row_y(fi), local_pos(labels(li), 2));
        end
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
keep_row = true(numel(row_fld), 1);
for i = 1:numel(row_fld)
    if ~local_keep_field(row_fld{i})
        keep_row(i) = false;
    end
end
row_fld = row_fld(keep_row);
row_lab = row_lab(keep_row);
row_y = row_y(keep_row);
if isempty(row_fld)
    return
end
[~, order] = sort(row_y, 'descend');
for i = 1:numel(order)
    k = order(i);
    pairs{end+1} = {row_lab{k}, row_fld{k}}; %#ok<AGROW>
end

end

function tf = local_keep_field(fld)

tf = true;
if isempty(fld) || ~(isgraphics(fld) && isvalid(fld))
    tf = false;
    return
end
if ~local_is_shown(fld)
    tf = false;
    return
end
try
    tg = lower(char(string(fld.Tag)));
    if contains(tg, 'ensemble')
        tf = false;
        return
    end
catch
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
    p = getpixelposition(h, true);
catch
    try
        p = h.Position;
    catch
    end
end
if numel(p) < 4
    p = [0 0 40 22];
end
if nargin >= 2
    p = p(idx);
end

end

function w = local_form_width(fig, labels, n_pair, n_form_cols)

if nargin < 3 || isempty(n_pair)
    n_pair = numel(labels);
end
if nargin < 4 || isempty(n_form_cols)
    n_form_cols = 1;
end
lab_px = local_label_width(labels);
field_px = 180;
try
    dds = findall(fig, 'Type', 'uidropdown');
    for i = 1:numel(dds)
        items = {};
        try
            items = dds(i).Items;
        catch
        end
        for k = 1:numel(items)
            field_px = max(field_px, min(420, 36 + round(7.2 * numel(char(string(items{k}))))));
        end
    end
catch
end
w = max(360, min(880, 48 + lab_px + field_px));
if n_form_cols > 1
    w = max(w, min(920, 56 + 2 * (lab_px + field_px)));
end
if n_pair <= 6 && w <= 380
    w = 360;
end

end

function w = local_btn_width(btn)

w = 100;
if nargin < 1 || isempty(btn) || ~isgraphics(btn)
    return
end
txt = '';
try
    if isprop(btn, 'Text')
        txt = char(string(btn.Text));
    elseif isprop(btn, 'String')
        txt = char(string(btn.String));
    end
catch
end
txt = strtrim(regexprep(txt, '\s+', ' '));
if isempty(txt)
    return
end
w = max(80, min(200, 28 + round(numel(txt) * 7.4)));

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
n_grid_rows = 0;
for i = 1:numel(grids)
    if ~isvalid(grids(i))
        continue
    end
    try
        cw = grids(i).ColumnWidth;
        n_grid_rows = max(n_grid_rows, numel(grids(i).RowHeight));
    catch
        continue
    end
    try
        if numel(cw) == 2
            n_two = n_two + 1;
            grids(i).ColumnWidth = {'fit', '1x'};
        elseif numel(cw) == 4
            n_two = n_two + 1;
            grids(i).ColumnWidth = {'fit', '1x', 'fit', '1x'};
        elseif numel(cw) >= 2
            cw{end} = '1x';
            grids(i).ColumnWidth = cw;
        end
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
        cbs(i).WordWrap = 'on';
        cbs(i).FontWeight = 'normal';
    catch
    end
end

need_w = local_form_width(fig, labs, max(n_two, numel(labs)), 1);
need_w = max(440, need_w);
if ~isempty(findall(fig, 'Type', 'uidropdown'))
    need_w = max(need_w, 560);
end
for i = 1:numel(grids)
    try
        ch = grids(i).Children;
        has_cb = false;
        for k = 1:numel(ch)
            if contains(class(ch(k)), 'CheckBox')
                has_cb = true;
                break
            end
        end
        if ~has_cb
            continue
        end
        rh = grids(i).RowHeight;
        for r = 1:numel(rh)
            if isnumeric(rh{r})
                rh{r} = max(32, rh{r});
            end
        end
        grids(i).RowHeight = rh;
    catch
    end
end
n_btn = numel(local_findall(fig, 'uibutton'));
n_rows = max([n_two, numel(labs), n_grid_rows]);
content_h = 28 + n_rows * 36 + 24 + 12 * numel(cbs) + 44 * double(n_btn > 0);
need_h = max(180, content_h);
scr = get(groot, 'ScreenSize');
max_h = max(240, min(round(0.99 * scr(4)), scr(4) - 8));
if content_h > max_h - 24
    try
        top.Scrollable = 'on';
    catch
    end
    need_h = max_h;
end
try
    orig = fig.Units;
    fig.Units = 'pixels';
    fig.Position(3) = min(need_w, min(round(0.99 * scr(3)), scr(3) - 8));
    fig.Position(4) = min(need_h, max_h);
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
zef_ui_bind_min_size(fig, max(360, min(need_w, fig.Position(3))), ...
    max(180, min(need_h, fig.Position(4))));
try
    zef_ui_fit_dropdowns(fig);
catch
end

end

function local_rescue_strays(fig, form, chk)

root = findall(fig, 'Tag', 'zef_ui_root');
if isempty(root)
    return
end
root = root(1);
chks = local_all_checks(fig);
for i = 1:numel(chks)
    h = chks(i);
    if ~isgraphics(h) || ~isvalid(h) || local_is_under(h, root)
        continue
    end
    if isempty(chk) || ~(isgraphics(chk) && isvalid(chk))
        continue
    end
    try
        h.Visible = 'on';
        h.WordWrap = 'off';
        h.Parent = chk;
    catch
    end
end
if ~isempty(chk) && isgraphics(chk) && isvalid(chk)
    try
        n_live = numel(local_findall(chk, 'uicheckbox'));
        chk.RowHeight = repmat({26}, 1, max(1, ceil(n_live / 2)));
    catch
    end
end
if isempty(form) || ~(isgraphics(form) && isvalid(form))
    return
end
flds = [local_findall(fig, 'uieditfield'); ...
    local_findall(fig, 'uinumericeditfield'); ...
    local_findall(fig, 'uidropdown'); ...
    local_findall(fig, 'uispinner')];
for i = 1:numel(flds)
    h = flds(i);
    if ~isgraphics(h) || ~isvalid(h) || local_is_under(h, root)
        continue
    end
    if ~local_keep_field(h) && ~local_is_shown(h)
        continue
    end
    try
        h.Visible = 'on';
        h.Parent = form;
        n_cols = max(1, numel(form.ColumnWidth));
        n_exist = numel(form.Children);
        rr = max(1, ceil(n_exist / n_cols));
        cc = n_cols;
        try
            h.Layout.Row = rr;
            h.Layout.Column = cc;
        catch
        end
    catch
    end
end
labs = local_findall(fig, 'uilabel');
for i = 1:numel(labs)
    h = labs(i);
    if ~isgraphics(h) || ~isvalid(h) || local_is_under(h, root)
        continue
    end
    txt = '';
    try
        txt = strtrim(char(string(h.Text)));
    catch
    end
    if numel(txt) < 3 || ~contains(txt, ':')
        continue
    end
    try
        h.Visible = 'on';
        h.Parent = form;
        h.HorizontalAlignment = 'right';
        h.WordWrap = 'off';
    catch
    end
end
try
    n_child = numel(form.Children);
    n_cols = max(1, numel(form.ColumnWidth));
    need_rows = max(1, ceil(n_child / n_cols));
    rh = form.RowHeight;
    if need_rows > numel(rh)
        form.RowHeight = [rh, repmat({26}, 1, need_rows - numel(rh))];
        form.Padding = max(form.Padding, [10 16 10 10]);
    end
catch
end

end

function local_unwind_root(fig)

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
roots = findall(fig, 'Tag', 'zef_ui_root');
if isempty(roots)
    return
end
ctrls = [local_findall(fig, 'uilabel'); local_findall(fig, 'uieditfield'); ...
    local_findall(fig, 'uinumericeditfield'); local_findall(fig, 'uidropdown'); ...
    local_findall(fig, 'uispinner'); local_findall(fig, 'uitextarea'); ...
    local_findall(fig, 'uibutton'); local_findall(fig, 'uicheckbox'); ...
    local_findall(fig, 'uiaxes'); local_findall(fig, 'axes'); ...
    local_findall(fig, 'uitable'); local_findall(fig, 'uilistbox')];
try
    uc = findall(fig, 'Style', 'checkbox');
    if ~isempty(uc)
        ctrls = [ctrls; uc(:)];
    end
catch
end
for i = 1:numel(ctrls)
    try
        if ~isgraphics(ctrls(i)) || ~isvalid(ctrls(i))
            continue
        end
        if ~local_is_under(ctrls(i), roots(1)) && numel(roots) == 1
            continue
        end
        under = false;
        for r = 1:numel(roots)
            if local_is_under(ctrls(i), roots(r))
                under = true;
                break
            end
        end
        if ~under
            continue
        end
        ctrls(i).Parent = fig;
    catch
    end
end
for i = 1:numel(roots)
    try
        if isgraphics(roots(i)) && isvalid(roots(i))
            delete(roots(i));
        end
    catch
    end
end
gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        if ~isvalid(gs(i))
            continue
        end
        if isempty(gs(i).Children)
            delete(gs(i));
        end
    catch
    end
end
try
    if isappdata(fig, 'ZefMinSize')
        rmappdata(fig, 'ZefMinSize');
    end
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end

end

function local_unwrap_fullsize_panel(fig)

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
kids = [];
try
    kids = fig.Children;
catch
    return
end
pan = [];
n_other = 0;
for i = 1:numel(kids)
    t = '';
    try
        t = lower(char(kids(i).Type));
    catch
    end
    if strcmp(t, 'uipanel')
        if isempty(pan)
            pan = kids(i);
        else
            return
        end
    elseif contains(t, 'menu')
        continue
    else
        n_other = n_other + 1;
    end
end
if isempty(pan) || n_other > 0
    return
end
ch = [];
try
    ch = pan.Children;
catch
    return
end
for i = numel(ch):-1:1
    try
        ch(i).Parent = fig;
    catch
    end
end
try
    delete(pan);
catch
    try
        pan.Visible = 'off';
    catch
    end
end

end

function tf = local_is_under(obj, root)

tf = false;
p = obj;
guard = 0;
while isgraphics(p) && isvalid(p) && guard < 16
    if p == root
        tf = true;
        return
    end
    try
        p = p.Parent;
    catch
        return
    end
    guard = guard + 1;
end

end
