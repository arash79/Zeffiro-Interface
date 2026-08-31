function zef_layout_table_dialog(fig)
%ZEF_LAYOUT_TABLE_DIALOG  Table-plus-buttons layout for settings windows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by system/plugin/profile dialogs that are mostly a uitable and
%   Save/Apply buttons.
%
%   See also zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    return
end

tables = findall(fig, 'Type', 'uitable');
if isempty(tables)
    return
end
btns = findall(fig, 'Type', 'uibutton');
if isempty(btns)
    btns = findall(fig, 'Style', 'pushbutton');
end
if numel(tables) ~= 1 || numel(btns) > 4
    return
end

theme = zef_ui_theme();
try
    fig.AutoResizeChildren = 'off';
    fig.Scrollable = 'off';
catch
end
try
    local_unwrap_fullsize_panel(fig);
    tables = findall(fig, 'Type', 'uitable');
    btns = findall(fig, 'Type', 'uibutton');
    if isempty(btns)
        btns = findall(fig, 'Style', 'pushbutton');
    end
    if numel(tables) ~= 1 || numel(btns) > 4
        return
    end
catch
end

n_rows = 4;
try
    n_rows = max(1, size(tables(1).Data, 1));
catch
end
n_cols = 1;
try
    n_cols = max(n_cols, size(tables(1).Data, 2));
    n_cols = max(n_cols, numel(tables(1).ColumnName));
catch
end
for i = 1:numel(btns)
    try
        local_flatten_btn(btns(i));
    catch
    end
end
content_h = 36 + n_rows * 26 + 8;
tbl_h = max(176, min(720, content_h + 24));
need_h = max(240, min(844, 32 + tbl_h + 16 + 64));
min_h = max(200, min(need_h, round(0.85 * need_h)));
need_w = 640;
if n_cols >= 4
    need_w = 880;
end
if n_cols >= 6
    need_w = 900;
end
try
    content_w = local_content_width(tables(1));
    if content_w > need_w
        need_w = min(900, content_w);
    end
catch
end
lname = '';
try
    lname = lower(char(fig.Name));
catch
end
if contains(lname, 'plugin') && n_rows > 12
    tbl_h = min(800, 48 + n_rows * 26 + 40);
    need_h = min(940, 48 + tbl_h + 16 + 52);
elseif contains(lname, 'export') && n_cols <= 2
    need_w = 480;
    tbl_h = max(140, 36 + max(n_rows, 4) * 26 + 12);
    need_h = max(240, 32 + tbl_h + 16 + 52);
elseif contains(lname, 'system settings') && n_rows > 12
    tbl_h = min(620, 28 + n_rows * 22 + 10);
    need_h = min(720, 32 + tbl_h + 16 + 52);
    need_w = max(need_w, 880);
elseif n_cols <= 2 && n_rows <= 8 && ~contains(lname, 'settings') ...
        && ~contains(lname, 'profile')
    need_w = 440;
    tbl_h = max(120, 28 + n_rows * 28 + 8);
    need_h = max(200, 24 + tbl_h + 12 + 52);
elseif n_rows <= 12 && n_cols >= 3
    tbl_h = max(88, 36 + n_rows * 26 + 12);
    need_h = max(220, 32 + tbl_h + 16 + 56);
    need_w = max(need_w, min(960, 120 + n_cols * 110));
end
min_w = max(360, round(0.88 * need_w));
min_h = max(200, min(need_h, round(0.90 * need_h)));
zef_ui_apply_size(fig, need_w, need_h, min_w, min_h);
zef_ui_bind_min_size(fig, min_w, min_h);

root = uigridlayout(fig, [2 1]);
root.Tag = 'zef_ui_root';
table_fit = false;
if contains(lname, 'plugin') && n_rows > 12
    root.RowHeight = {'1x', 52};
elseif contains(lname, 'export') && n_cols <= 2
    root.RowHeight = {tbl_h, 52};
    table_fit = true;
elseif contains(lname, 'system settings') && n_rows > 12
    root.RowHeight = {tbl_h, 56};
    table_fit = true;
elseif n_cols <= 2 && n_rows <= 8 && ~contains(lname, 'settings') ...
        && ~contains(lname, 'profile')
    root.RowHeight = {'fit', 52};
    table_fit = true;
elseif n_rows <= 12 && n_cols >= 3
    root.RowHeight = {tbl_h, 56};
    table_fit = true;
else
    root.RowHeight = {'1x', 56};
end
root.Padding = [12 12 12 12];
root.RowSpacing = 8;
if contains(lname, 'plugin') && n_rows > 12
    root.Padding = [12 12 12 12];
    root.RowSpacing = 8;
end
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

tables(1).Parent = root;
try
    tables(1).Layout.Row = 1;
    tables(1).Layout.Column = 1;
catch
end
try
    tables(1).RowName = {};
catch
end
zef_ui_fit_table(tables);

if isempty(btns)
    fig.SizeChangedFcn = '';
    return
end

n = numel(btns);
if n == 1
    row = uigridlayout(root, [1 3]);
    row.ColumnWidth = {'1x', local_btn_width(btns(1)), '1x'};
    uilabel(row, 'Text', '');
else
    widths = cell(1, n);
    for i = 1:n
        widths{i} = local_btn_width(btns(i));
    end
    row = uigridlayout(root, [1 n + 2]);
    row.ColumnWidth = [{'1x'}, widths, {'1x'}];
    uilabel(row, 'Text', '');
end
row.RowHeight = {34};
row.Padding = [0 0 0 0];
row.ColumnSpacing = 8;
try
    row.BackgroundColor = theme.color.bg;
catch
end
for i = 1:n
    try
        btns(i).Parent = row;
        if n == 1
            btns(i).Layout.Column = 2;
        else
            btns(i).Layout.Column = i + 1;
        end
        local_flatten_btn(btns(i));
    catch
    end
end
if n > 1
    uilabel(row, 'Text', '');
end

zef_ui_hide_orphans(fig);
try
    fig.SizeChangedFcn = '';
catch
end
try
    fig.AutoResizeChildren = 'off';
    fig.Units = 'pixels';
    root.Position = [1 1 fig.Position(3) fig.Position(4)];
catch
end
if exist('table_fit', 'var') && table_fit
    try
        setappdata(fig, 'ZefTableFitH', tbl_h);
    catch
    end
end
zef_ui_fit_table(tables);

try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_bind_min_size(fig, min_w, min_h);

end

function local_flatten_btn(btn)

if nargin < 1 || isempty(btn) || ~isgraphics(btn)
    return
end
try
    if isprop(btn, 'Text')
        t = btn.Text;
        if iscell(t) || (isstring(t) && numel(t) > 1)
            btn.Text = strtrim(strjoin(string(t), ' '));
        end
    elseif isprop(btn, 'String')
        t = btn.String;
        if iscell(t)
            btn.String = strtrim(strjoin(string(t), ' '));
        end
    end
catch
end
try
    if isprop(btn, 'WordWrap')
        btn.WordWrap = 'off';
    end
catch
end

end

function w = local_content_width(tbl)

w = 0;
if nargin < 1 || isempty(tbl) || ~isgraphics(tbl)
    return
end
try
    d = tbl.Data;
    names = {};
    try
        names = tbl.ColumnName;
    catch
    end
    if isstring(names)
        names = cellstr(names);
    end
    n = max(size(d, 2), numel(names));
    col_w = 0;
    for c = 1:n
        mx = 8;
        if c <= numel(names)
            mx = max(mx, numel(char(string(names{c}))));
        end
        n_row = min(size(d, 1), 40);
        for r = 1:n_row
            try
                mx = max(mx, numel(char(string(d{r, c}))));
            catch
            end
        end
        col_w = col_w + min(320, max(72, 8 + round(mx * 7.6)));
    end
    w = 64 + col_w;
catch
end

end

function w = local_btn_width(btn)

w = 120;
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
txt = strtrim(txt);
if isempty(txt)
    return
end
w = max(96, min(220, 28 + round(numel(txt) * 7.4)));

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
