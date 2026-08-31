function zef_layout_filter_tool(fig)
%ZEF_LAYOUT_FILTER_TOOL  Two-column grid layout for the Filter tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Left: filter catalogue, epoch points, parameter table. Right:
%   import/reset, sampling fields, pipeline list, substitute/plot.
%   Lists and the parameter table absorb extra height on resize.
%
%   See also zef_filter_tool, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    zef_ui_adapt_grid(fig);
    return
end

lst = local_h(fig, 'h_filter_list');
if isempty(lst)
    lst = local_first(findall(fig, 'Type', 'uilistbox'));
end
if isempty(lst)
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

local_unclip_buttons(fig);

root = uigridlayout(fig, [1 2]);
root.Tag = 'zef_ui_root';
root.ColumnWidth = {'1x', '1x'};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

left = uigridlayout(root, [11 1]);
left.Tag = 'zef_filter_left';
left.RowHeight = {22, '1x', 32, 32, 32, 32, 22, '1x', 32, 36, 36};
left.RowSpacing = 8;
left.Padding = [0 0 0 0];
try
    left.BackgroundColor = theme.color.bg;
catch
end
local_put(left, local_label(fig, 'Filters:'), 1, 1);
local_put(left, lst, 2, 1);
local_put(left, local_h(fig, 'h_add_filter'), 3, 1);
local_put(left, local_h(fig, 'h_del_filter'), 4, 1);
local_put(left, local_h(fig, 'h_filter_get_epoch_points'), 5, 1);
local_put(left, local_h(fig, 'h_filter_reset_epoch_points'), 6, 1);
lab_par = local_label(fig, 'Filter parameters');
if isempty(lab_par)
    lab_par = local_label(fig, 'Filter parameter');
end
local_put(left, lab_par, 7, 1);
tbl = local_h(fig, 'h_filter_parameter_list');
if isempty(tbl)
    tbl = local_first(findall(fig, 'Type', 'uitable'));
end
local_put(left, tbl, 8, 1);
try
    zef_ui_fit_table(tbl);
catch
end
local_put(left, local_h(fig, 'h_filter_load'), 9, 1);
local_put(left, local_h(fig, 'h_filter_substitute_measurement_data'), 10, 1);
local_put(left, local_h(fig, 'h_filter_substitute_noise_data'), 11, 1);

right = uigridlayout(root, [16 1]);
right.Tag = 'zef_filter_right';
right.RowHeight = {36, 36, 32, 26, 26, 26, 26, 32, 32, 32, 22, '1x', 32, 32, 36, 32};
right.RowSpacing = 6;
right.Padding = [0 0 0 0];
try
    right.BackgroundColor = theme.color.bg;
catch
end
local_put(right, local_h(fig, 'h_filter_import_data'), 1, 1);
local_put(right, local_h(fig, 'h_filter_substitute_raw_data_with_measurement_data'), 2, 1);
local_put(right, local_h(fig, 'h_filter_reset'), 3, 1);
local_pair_row(right, 4, fig, 'Sampling rate', 'h_filter_sampling_rate', theme);
local_pair_row(right, 5, fig, 'Filter tag', 'h_filter_tag', theme);
local_pair_row(right, 6, fig, 'Export to data segment', 'h_filter_data_segment', theme);
local_pair_row(right, 7, fig, 'Time interval zoom', 'h_filter_zoom', theme);
local_put(right, local_h(fig, 'h_move_up_filter'), 8, 1);
local_put(right, local_h(fig, 'h_move_down_filter'), 9, 1);
local_put(right, local_h(fig, 'h_filter_load_epoch_points'), 10, 1);
lab_pipe = local_label(fig, 'Processing pipeline');
if isempty(lab_pipe)
    lab_pipe = local_label(fig, 'Processingpipeline');
end
local_put(right, lab_pipe, 11, 1);
pipe = local_h(fig, 'h_filter_pipeline_list');
if isempty(pipe)
    boxes = findall(fig, 'Type', 'uilistbox');
    if numel(boxes) >= 2
        pipe = boxes(2);
    end
end
local_put(right, pipe, 12, 1);
local_put(right, local_h(fig, 'h_filter_save_as'), 13, 1);
local_put(right, local_h(fig, 'h_filter_save_processed_data'), 14, 1);
local_put(right, local_h(fig, 'h_filter_substitute_raw_data'), 15, 1);
local_put(right, local_h(fig, 'h_filter_plot_data'), 16, 1);

zef_ui_hide_orphans(fig);
try
    fig.SizeChangedFcn = '';
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_apply_size(fig, 820, 860, 700, 680);
zef_ui_bind_min_size(fig, 700, 680);
zef_ui_adapt_grid(fig);
try
    zef_ui_fit_table(findall(fig, 'Type', 'uitable'));
catch
end

end

function local_pair_row(parent, row, fig, lab_txt, field_name, theme)

g = uigridlayout(parent, [1 2]);
g.ColumnWidth = {'fit', '1x'};
g.Padding = [0 0 0 0];
g.ColumnSpacing = 8;
try
    g.BackgroundColor = theme.color.bg;
catch
end
try
    g.Layout.Row = row;
    g.Layout.Column = 1;
catch
end
lab = local_label(fig, lab_txt);
if ~isempty(lab)
    try
        lab.HorizontalAlignment = 'right';
        lab.WordWrap = 'off';
    catch
    end
end
local_put(g, lab, 1, 1);
local_put(g, local_h(fig, field_name), 1, 2);

end

function local_unclip_buttons(fig)

btns = findall(fig, 'Type', 'uibutton');
for i = 1:numel(btns)
    try
        t = btns(i).Text;
        joined = strtrim(regexprep(char(join(string(t), ' ')), '\s+', ' '));
        if ~isempty(joined)
            btns(i).Text = joined;
        end
        if isprop(btns(i), 'WordWrap')
            btns(i).WordWrap = 'on';
        end
    catch
    end
end

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

function h = local_h(fig, name)

h = gobjects(0);
found = findall(fig, 'Tag', name);
if ~isempty(found)
    h = found(1);
    return
end
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, name) && isgraphics(zef.(name)) && isvalid(zef.(name))
        h = zef.(name);
        try
            h.Tag = name;
        catch
        end
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
        if strcmp(t, needle) || contains(t, needle)
            h = labs(i);
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
