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

left = uigridlayout(root, [6 1]);
left.Tag = 'zef_filter_left';
left.RowHeight = {22, '1x', 72, 22, 140, 36};
left.RowSpacing = 8;
left.Padding = [0 0 0 0];
try
    left.BackgroundColor = theme.color.bg;
catch
end
lab_f = local_label(fig, 'Filters:');
if ~isempty(lab_f)
    lab_f.FontWeight = 'bold';
    lab_f.FontColor = theme.color.header;
end
local_put(left, lab_f, 1, 1);
local_put(left, lst, 2, 1);
local_btn_grid(left, 3, theme, ...
    {local_h(fig, 'h_add_filter'), local_h(fig, 'h_del_filter'); ...
    local_h(fig, 'h_filter_get_epoch_points'), local_h(fig, 'h_filter_reset_epoch_points')});
lab_par = local_label(fig, 'Filter parameters');
if isempty(lab_par)
    lab_par = local_label(fig, 'Filter parameter');
end
if ~isempty(lab_par)
    lab_par.FontWeight = 'bold';
    lab_par.FontColor = theme.color.header;
end
local_put(left, lab_par, 4, 1);
tbl = local_h(fig, 'h_filter_parameter_list');
if isempty(tbl)
    tbl = local_first(findall(fig, 'Type', 'uitable'));
end
local_put(left, tbl, 5, 1);
try
    zef_ui_fit_table(tbl);
catch
end
local_btn_grid(left, 6, theme, ...
    {local_h(fig, 'h_filter_load'), local_h(fig, 'h_filter_substitute_measurement_data'), ...
    local_h(fig, 'h_filter_substitute_noise_data')});

right = uigridlayout(root, [10 1]);
right.Tag = 'zef_filter_right';
right.RowHeight = {36, 26, 26, 26, 26, 32, 22, '1x', 36, 36};
right.RowSpacing = 6;
right.Padding = [0 0 0 0];
try
    right.BackgroundColor = theme.color.bg;
catch
end
local_btn_grid(right, 1, theme, ...
    {local_h(fig, 'h_filter_import_data'), ...
    local_h(fig, 'h_filter_substitute_raw_data_with_measurement_data'), ...
    local_h(fig, 'h_filter_reset')});
local_pair_row(right, 2, fig, 'Sampling rate', 'h_filter_sampling_rate', theme);
local_pair_row(right, 3, fig, 'Filter tag', 'h_filter_tag', theme);
local_pair_row(right, 4, fig, 'Export to data segment', 'h_filter_data_segment', theme);
local_pair_row(right, 5, fig, 'Time interval zoom', 'h_filter_zoom', theme);
local_btn_grid(right, 6, theme, ...
    {local_h(fig, 'h_move_up_filter'), local_h(fig, 'h_move_down_filter'), ...
    local_h(fig, 'h_filter_load_epoch_points')});
lab_pipe = local_label(fig, 'Processing pipeline');
if isempty(lab_pipe)
    lab_pipe = local_label(fig, 'Processingpipeline');
end
if ~isempty(lab_pipe)
    lab_pipe.FontWeight = 'bold';
    lab_pipe.FontColor = theme.color.header;
end
local_put(right, lab_pipe, 7, 1);
pipe = local_h(fig, 'h_filter_pipeline_list');
if isempty(pipe)
    boxes = findall(fig, 'Type', 'uilistbox');
    if numel(boxes) >= 2
        pipe = boxes(2);
    end
end
local_put(right, pipe, 8, 1);
local_btn_grid(right, 9, theme, ...
    {local_h(fig, 'h_filter_save_as'), local_h(fig, 'h_filter_save_processed_data'), ...
    local_h(fig, 'h_filter_substitute_raw_data')});
plot_host = uigridlayout(right, [1 3]);
plot_host.Tag = 'zef_filter_plot';
plot_host.ColumnWidth = {'1x', 220, '1x'};
plot_host.Padding = [0 0 0 0];
try
    plot_host.BackgroundColor = theme.color.bg;
    plot_host.Layout.Row = 10;
    plot_host.Layout.Column = 1;
catch
end
plot_btn = local_h(fig, 'h_filter_plot_data');
local_put(plot_host, plot_btn, 1, 2);
try
    setappdata(plot_btn, 'ZefPrimary', true);
catch
end

zef_ui_hide_orphans(fig);
try
    fig.SizeChangedFcn = '';
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_apply_size(fig, 900, 640, 720, 540);
zef_ui_bind_min_size(fig, 720, 540);
zef_ui_adapt_grid(fig);
try
    zef_ui_fit_table(findall(fig, 'Type', 'uitable'));
catch
end

end

function local_btn_grid(parent, row, theme, handles)

flat = handles;
if ~iscell(flat)
    return
end
n_r = size(flat, 1);
n_c = size(flat, 2);
g = uigridlayout(parent, [n_r n_c]);
g.ColumnWidth = repmat({'1x'}, 1, n_c);
g.RowHeight = repmat({32}, 1, n_r);
g.Padding = [0 0 0 0];
g.ColumnSpacing = 8;
g.RowSpacing = 6;
try
    g.BackgroundColor = theme.color.bg;
    g.Layout.Row = row;
    g.Layout.Column = 1;
catch
end
for r = 1:n_r
    for c = 1:n_c
        h = flat{r, c};
        if isempty(h)
            continue
        end
        local_put(g, h, r, c);
    end
end

end

function local_pair_row(parent, row, fig, lab_txt, field_name, theme)

g = uigridlayout(parent, [1 2]);
g.ColumnWidth = {156, '1x'};
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
        if contains(lower(lab_txt), 'zoom')
            lab.Text = 'Time interval zoom (%)';
        end
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
            joined = strrep(joined, 'measurment', 'measurement');
            if contains(lower(joined), 'substitute raw data with')
                btns(i).Tooltip = joined;
                joined = 'Raw from measurement';
            elseif contains(lower(joined), 'substitute measurement')
                btns(i).Tooltip = joined;
                joined = 'Use as measurement';
            elseif contains(lower(joined), 'substitute noise')
                btns(i).Tooltip = joined;
                joined = 'Use as noise';
            elseif contains(lower(joined), 'substitute raw data') ...
                    && ~contains(lower(joined), 'with')
                btns(i).Tooltip = joined;
                joined = 'Use as raw data';
            end
            btns(i).Text = joined;
        end
        if isprop(btns(i), 'WordWrap')
            btns(i).WordWrap = 'off';
        end
        if contains(lower(char(string(btns(i).Text))), 'plot processed')
            th = zef_ui_theme();
            btns(i).BackgroundColor = th.color.primary;
            btns(i).FontColor = th.color.primaryText;
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
