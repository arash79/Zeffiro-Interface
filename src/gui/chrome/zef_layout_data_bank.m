function zef_layout_data_bank(fig)
%ZEF_LAYOUT_DATA_BANK  Responsive grid for the Data Bank app.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Left: tree. Right: entry/save/function cards over working and
%   catalogue tables. Combine, import, and mag2grad panels share one
%   slot and are shown by zef_dataBank_FunctionsDropDown.
%
%   See also zef_open_dataBank, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    zef_ui_adapt_grid(fig);
    return
end

app = [];
try
    if isappdata(fig, 'ZefDataBankApp')
        app = getappdata(fig, 'ZefDataBankApp');
    end
catch
end
if isempty(app)
    try
        zef = evalin('base', 'zef');
        if isfield(zef, 'dataBank') && isfield(zef.dataBank, 'app')
            app = zef.dataBank.app;
        end
    catch
    end
end
if isempty(app) || ~isprop(app, 'DataBank') || ~isequal(app.DataBank, fig)
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
try
    if isappdata(fig, 'ZefSizeChangedInner')
        rmappdata(fig, 'ZefSizeChangedInner');
    end
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end

root = uigridlayout(fig, [1 2]);
root.Tag = 'zef_ui_root';
root.ColumnWidth = {240, '1x'};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

left = uigridlayout(root, [2 1]);
left.RowHeight = {32, '1x'};
left.RowSpacing = 8;
left.Padding = [0 0 0 0];
try
    left.BackgroundColor = theme.color.bg;
catch
end
hdr = uigridlayout(left, [1 2]);
hdr.ColumnWidth = {'1x', 'fit'};
hdr.Padding = [0 0 0 0];
hdr.ColumnSpacing = 8;
try
    hdr.BackgroundColor = theme.color.bg;
catch
end
try
    app.DatabankLabel.Text = 'Data Bank';
    app.DatabankLabel.FontWeight = 'bold';
    app.DatabankLabel.FontColor = theme.color.header;
    app.DatabankLabel.FontSize = theme.font.size;
catch
end
local_put(hdr, app.DatabankLabel, 1, 1);
local_put(hdr, app.RefreshButton, 1, 2);
local_put(left, app.Tree, 2, 1);

right = uigridlayout(root, [2 1]);
right.RowHeight = {228, '1x'};
right.RowSpacing = 10;
right.Padding = [0 0 0 0];
try
    right.BackgroundColor = theme.color.bg;
catch
end

top = uigridlayout(right, [1 3]);
top.Tag = 'zef_db_top';
top.ColumnWidth = {'1.05x', '1x', '1.45x'};
top.ColumnSpacing = 10;
top.Padding = [0 0 0 0];
try
    top.BackgroundColor = theme.color.bg;
catch
end

local_style_panel(app.EntriesPanel, theme, 'Entries');
ent = local_panel_grid(app.EntriesPanel, [5 1], theme);
ent.RowHeight = {28, 28, 28, 28, 28};
try
    app.addButton.Text = 'Add entry';
    app.showButton.Text = 'Show all';
    app.showcurrentButton.Text = 'Show current';
    app.showworkingHashes.Text = 'Working hashes';
catch
end
local_put(ent, app.addButton, 1, 1);
type_row = uigridlayout(ent, [1 2]);
type_row.ColumnWidth = {40, '1x'};
type_row.Padding = [0 0 0 0];
type_row.ColumnSpacing = 8;
try
    type_row.BackgroundColor = theme.color.panel;
    type_row.Layout.Row = 2;
catch
end
local_put(type_row, app.TypeLabel, 1, 1);
local_put(type_row, app.Entrytype, 1, 2);
local_put(ent, app.showcurrentButton, 3, 1);
local_put(ent, app.showButton, 4, 1);
local_put(ent, app.showworkingHashes, 5, 1);
local_put(top, app.EntriesPanel, 1, 1);

local_style_panel(app.SavetodiskRAMsavingPanel, theme, 'Save to disk');
sav = local_panel_grid(app.SavetodiskRAMsavingPanel, [4 1], theme);
sav.RowHeight = {28, 28, 28, '1x'};
sw = uigridlayout(sav, [1 2]);
sw.ColumnWidth = {'1x', 'fit'};
sw.Padding = [0 0 0 0];
try
    sw.BackgroundColor = theme.color.panel;
    sw.Layout.Row = 1;
catch
end
try
    app.SavetodiskSwitchLabel.Text = 'Save to disk';
catch
end
local_put(sw, app.SavetodiskSwitchLabel, 1, 1);
local_put(sw, app.savetodiskSwitch, 1, 2);
fold = uigridlayout(sav, [2 1]);
fold.ColumnWidth = {'1x'};
fold.Padding = [0 0 0 0];
fold.RowSpacing = 6;
try
    fold.BackgroundColor = theme.color.panel;
    fold.Layout.Row = 2;
catch
end
local_put(fold, app.selectfolderButton, 1, 1);
local_put(fold, app.changefolderButton, 2, 1);
try
    app.DataFolder.WordWrap = 'on';
    app.DataFolder.VerticalAlignment = 'top';
catch
end
local_put(sav, app.DataFolder, 3, 1);
local_put(top, app.SavetodiskRAMsavingPanel, 1, 2);

fn_col = uigridlayout(top, [2 1]);
fn_col.RowHeight = {28, '1x'};
fn_col.RowSpacing = 6;
fn_col.Padding = [0 0 0 0];
try
    fn_col.BackgroundColor = theme.color.bg;
catch
end
fn_hdr = uigridlayout(fn_col, [1 2]);
fn_hdr.ColumnWidth = {'fit', '1x'};
fn_hdr.ColumnSpacing = 8;
fn_hdr.Padding = [0 0 0 0];
try
    fn_hdr.BackgroundColor = theme.color.bg;
catch
end
try
    app.FunctionsLabel.Text = 'Functions';
    app.FunctionsLabel.FontWeight = 'bold';
    app.FunctionsLabel.FontColor = theme.color.header;
catch
end
local_put(fn_hdr, app.FunctionsLabel, 1, 1);
local_put(fn_hdr, app.FunctionsDropDown, 1, 2);

fn_slot = uigridlayout(fn_col, [1 1]);
fn_slot.Padding = [0 0 0 0];
try
    fn_slot.BackgroundColor = theme.color.bg;
catch
end
local_style_panel(app.combinePanel, theme, 'Combine');
cmb = local_panel_grid(app.combinePanel, [5 1], theme);
cmb.RowHeight = {28, 26, 26, 26, 32};
local_put(cmb, app.combineMenu, 1, 1);
local_pair(cmb, 2, app.StarttimeLabel, app.StarttimeSpinner, theme);
local_pair(cmb, 3, app.EndtimeLabel, app.EndtimeSpinner, theme);
local_pair(cmb, 4, app.SfreqLabel, app.SfreqSpinner, theme);
local_put(cmb, app.combineButton, 5, 1);
try
    app.combineButton.BackgroundColor = theme.color.primary;
    app.combineButton.FontColor = theme.color.primaryText;
    app.StarttimeLabel.Text = 'Start time';
    app.EndtimeLabel.Text = 'End time';
    app.SfreqLabel.Text = 'Sampling freq.';
catch
end

local_style_panel(app.importPanel, theme, 'Import / Export');
imp = local_panel_grid(app.importPanel, [4 1], theme);
imp.RowHeight = {28, 28, 28, 28};
imp_row = uigridlayout(imp, [1 2]);
imp_row.ColumnWidth = {'fit', '1x'};
imp_row.Padding = [0 0 0 0];
try
    imp_row.BackgroundColor = theme.color.panel;
    imp_row.Layout.Row = 1;
catch
end
local_put(imp_row, app.typeDropDownLabel, 1, 1);
local_put(imp_row, app.typeDropDown, 1, 2);
local_put(imp, app.importButton, 2, 1);
local_put(imp, app.exportButton, 3, 1);
local_put(imp, app.helpButton, 4, 1);

local_style_panel(app.mag2gragPanel, theme, 'Magnetometer → gradiometer');
mg = local_panel_grid(app.mag2gragPanel, [3 1], theme);
mg.RowHeight = {28, 28, 28};
local_put(mg, app.loadtraButton, 1, 1);
local_put(mg, app.transformButton, 2, 1);
local_put(mg, app.deletetraButton, 3, 1);

app.combinePanel.Parent = fn_slot;
app.importPanel.Parent = fn_slot;
app.mag2gragPanel.Parent = fn_slot;
try
    app.combinePanel.Layout.Row = 1;
    app.combinePanel.Layout.Column = 1;
    app.importPanel.Layout.Row = 1;
    app.importPanel.Layout.Column = 1;
    app.mag2gragPanel.Layout.Row = 1;
    app.mag2gragPanel.Layout.Column = 1;
catch
end
try
    app.importPanel.Visible = 'off';
    app.mag2gragPanel.Visible = 'off';
    app.combinePanel.Visible = 'on';
catch
end

local_style_panel(app.DataPanel, theme, 'Data');
dat = local_panel_grid(app.DataPanel, [4 1], theme);
dat.RowHeight = {22, '1x', 22, '1.2x'};
try
    app.dataLabel.Text = 'Working data';
    app.dataLabel.FontWeight = 'bold';
    app.dataLabel.FontColor = theme.color.header;
catch
end
local_put(dat, app.dataLabel, 1, 1);
local_put(dat, app.currentTable, 2, 1);
all_lab = uilabel(dat, 'Text', 'Catalogue', 'FontWeight', 'bold', ...
    'FontColor', theme.color.header);
try
    all_lab.Layout.Row = 3;
catch
end
local_put(dat, app.DataTable, 4, 1);
try
    zef_ui_fit_table(app.currentTable);
    zef_ui_fit_table(app.DataTable);
catch
end
local_put(right, app.DataPanel, 2, 1);

zef_ui_hide_orphans(fig);
zef_ui_apply_size(fig, 980, 640, 840, 520);
zef_ui_bind_min_size(fig, 840, 520);
zef_ui_adapt_grid(fig);

end

function local_style_panel(pan, theme, title)

if isempty(pan) || ~isgraphics(pan)
    return
end
try
    pan.Title = title;
    pan.BackgroundColor = theme.color.panel;
    pan.ForegroundColor = theme.color.header;
    pan.BorderType = 'line';
    pan.FontWeight = 'bold';
catch
end
try
    pan.AutoResizeChildren = 'off';
catch
end

end

function g = local_panel_grid(pan, sz, theme)

g = uigridlayout(pan, sz);
g.Padding = [8 8 8 8];
g.RowSpacing = 6;
g.ColumnSpacing = 8;
try
    g.BackgroundColor = theme.color.panel;
catch
end

end

function local_pair(parent, row, lab, fld, theme)

g = uigridlayout(parent, [1 2]);
g.ColumnWidth = {88, '1x'};
g.Padding = [0 0 0 0];
g.ColumnSpacing = 8;
try
    g.BackgroundColor = theme.color.panel;
    g.Layout.Row = row;
    g.Layout.Column = 1;
catch
end
if ~isempty(lab)
    try
        lab.HorizontalAlignment = 'right';
    catch
    end
    local_put(g, lab, 1, 1);
end
local_put(g, fld, 1, 2);

end

function local_put(parent, h, row, col)

if isempty(h) || ~(isgraphics(h(1)) && isvalid(h(1)))
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
