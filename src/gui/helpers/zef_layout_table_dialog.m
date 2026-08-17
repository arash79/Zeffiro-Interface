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

theme = zef_ui_theme();
fig.AutoResizeChildren = 'on';
try
    fig.Scrollable = 'off';
catch
end

n_rows = 4;
try
    n_rows = max(1, size(tables(1).Data, 1));
catch
end
content_h = 34 + n_rows * 28 + 4;
tbl_h = max(80, min(280, content_h));
need_h = max(150, min(360, 24 + tbl_h + 8 + 36));
min_h = max(150, min(need_h, 200));
zef_ui_apply_size(fig, 520, need_h, 480, min_h);
zef_ui_bind_min_size(fig, 480, min_h);

btns = findall(fig, 'Type', 'uibutton');
if isempty(btns)
    btns = findall(fig, 'Style', 'pushbutton');
end

root = uigridlayout(fig, [2 1]);
root.Tag = 'zef_ui_root';
root.RowHeight = {'1x', 36};
root.Padding = [12 12 12 12];
root.RowSpacing = 8;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

tables(1).Parent = root;
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
    row.ColumnWidth = {'1x', 120, '1x'};
    uilabel(row, 'Text', '');
elseif n == 2
    row = uigridlayout(root, [1 2]);
    row.ColumnWidth = {'1x', '1x'};
else
    row = uigridlayout(root, [1 n]);
    row.ColumnWidth = repmat({'1x'}, 1, n);
end
row.RowHeight = {28};
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
        end
    catch
    end
end

fig.SizeChangedFcn = '';
try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_bind_min_size(fig, 480, min_h);

end
