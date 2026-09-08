function zef_layout_mesh_visualization_tool(fig)
%ZEF_LAYOUT_MESH_VISUALIZATION_TOOL  Grouped grid layout for Mesh visualization.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reparents the App Designer controls into a two-column uigridlayout
%   with the Parameter/Graph lists spanning the bottom so both columns
%   stay balanced. Safe to call more than once.
%
%   See also zef_mesh_visualization_tool, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end

existing = findall(fig, 'Tag', 'zef_ui_root');
if ~isempty(existing)
    zef_ui_adapt_grid(fig);
    return
end

theme = zef_ui_theme();
try
    fig.SizeChangedFcn = '';
catch
end
fig.AutoResizeChildren = 'off';
try
    fig.Scrollable = 'off';
catch
end

local_fix_labels(fig);

root = uigridlayout(fig, [2 2]);
root.Tag = 'zef_ui_root';
root.ColumnWidth = {'1.08x', '1x'};
root.RowHeight = {'fit', '1x'};
root.Padding = [10 10 10 10];
root.ColumnSpacing = 12;
root.RowSpacing = 10;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

left = uigridlayout(root, [4 1]);
left.Tag = 'zef_mv_left';
left.Layout.Row = 1;
left.Layout.Column = 1;
left.RowHeight = {'fit', 'fit', 'fit', '1x'};
left.RowSpacing = 8;
left.Padding = [0 0 0 0];
try
    left.BackgroundColor = theme.color.bg;
catch
end

actions = local_section(left, theme, [3 2]);
actions.Tag = 'zef_mv_actions';
actions.RowHeight = {28, 28, 28};
local_parent(fig, actions, {'h_pushbutton31', 'h_pushbutton20'; 'h_pushbutton22', 'h_axes_popup'});
dti = zef_ui_find(fig, 'h_pushbutton_dti_streamlines');
if isempty(dti)
    dti = findobj(fig, 'Type', 'uibutton', 'Text', 'Visualize DTI streamlines');
end
if ~isempty(dti) && isvalid(dti)
    dti.Parent = actions;
    dti.Layout.Row = 3;
    dti.Layout.Column = [1 2];
end

scene = local_section(left, theme, [4 2]);
scene.Tag = 'zef_mv_scene';
scene.ColumnWidth = {'1x', '1x'};
scene.RowHeight = {22, 22, 22, 26};
local_parent(fig, scene, {'h_checkbox14', 'h_use_inflated_surfaces'; ...
    'h_cone_draw', 'h_streamline_draw'; ...
    'h_checkbox15', 'h_show_contour_text'});
contour_row = uigridlayout(scene, [1 3]);
contour_row.Layout.Row = 4;
contour_row.Layout.Column = [1 2];
contour_row.ColumnWidth = {'fit', 'fit', '1x'};
contour_row.Padding = [0 0 0 0];
contour_row.ColumnSpacing = 8;
try
    contour_row.BackgroundColor = theme.color.panel;
catch
end
h_show = local_by_prop(fig, 'h_show_contour');
if isempty(h_show)
    h_show = findobj(fig, 'Type', 'uicheckbox', 'Text', 'Contour array');
end
if ~isempty(h_show) && isvalid(h_show)
    h_show.Parent = contour_row;
    h_show.Layout.Row = 1;
    h_show.Layout.Column = 1;
end
contour_lab = uilabel(contour_row, 'Text', 'Contour set:');
contour_lab.Layout.Row = 1;
contour_lab.Layout.Column = 2;
h_cset = local_by_prop(fig, 'h_contour_set_text');
if ~isempty(h_cset) && isvalid(h_cset)
    h_cset.Parent = contour_row;
    h_cset.Layout.Row = 1;
    h_cset.Layout.Column = 3;
end

clip = local_section(left, theme, [4 1]);
clip.Tag = 'zef_mv_clip';
clip.Layout.Row = 3;
clip.RowHeight = {28, 28, 28, 28};
clip.Padding = [8 8 8 8];
local_clip_row(fig, clip, 1, 'h_checkbox_cp_on', {'h_edit_cp_a', 'h_edit_cp_b', 'h_edit_cp_c', 'h_edit_cp_d'});
local_clip_row(fig, clip, 2, 'h_cp2_on', {'h_cp2_a', 'h_cp2_b', 'h_cp2_c', 'h_cp2_d'});
local_clip_row(fig, clip, 3, 'h_cp3_on', {'h_cp3_a', 'h_cp3_b', 'h_cp3_c', 'h_cp3_d'});
mode_row = uigridlayout(clip, [1 2]);
mode_row.ColumnWidth = {'fit', '1x'};
mode_row.Padding = [0 0 0 0];
try
    mode_row.BackgroundColor = theme.color.panel;
catch
end
local_move_named(fig, mode_row, 'CuttingplanemodeLabel');
local_move_named(fig, mode_row, 'h_cp_mode');

right = uigridlayout(root, [2 1]);
right.Layout.Row = 1;
right.Layout.Column = 2;
right.RowHeight = {'fit', '1x'};
right.RowSpacing = 8;
right.Padding = [0 0 0 0];
try
    right.BackgroundColor = theme.color.bg;
catch
end

view = local_section(right, theme, [12 1]);
view.Tag = 'zef_mv_view';
view.RowHeight = repmat({26}, 1, 12);
local_pair_row(fig, view, 'PlotcolormapDropDownLabel', {'h_frame_start', 'h_frame_stop', 'h_frame_step'});
local_pair_row(fig, view, 'CuttingplanecoeffEditFieldLabel', {'h_edit80', 'h_edit81', 'h_edit82'});
local_pair_row(fig, view, 'RotationspeeddegsLabel', {'h_orbit_2', 'h_orbit'});
local_labeled(fig, view, 'CuttingplanecoeffEditFieldLabel_2', 'h_explode_everything');
local_labeled(fig, view, 'RotationspeeddegsEditFieldLabel_2', 'h_visualization_type');
local_labeled(fig, view, 'RotationspeeddegsEditFieldLabel', 'h_reconstruction_type');
local_labeled(fig, view, 'DistributionmodeLabel', 'h_volumetric_distribution_mode');
local_labeled(fig, view, 'PlotscaleLabel', 'h_inv_scale');
local_labeled(fig, view, 'ColormapLabel', 'h_inv_colormap');
local_labeled(fig, view, 'PlotthresholdLabel', 'h_inv_dynamic_range');
local_labeled(fig, view, 'TransparencyrecsurfLabel', {'h_brain_transparency', 'h_layer_transparency'});
local_labeled(fig, view, 'SubmeshLabel', 'h_submesh_num');
uilabel(right, 'Text', '', 'BackgroundColor', theme.color.bg);

bottom = uigridlayout(root, [3 2]);
bottom.Layout.Row = 2;
bottom.Layout.Column = [1 2];
bottom.RowHeight = {18, '1x', 28};
bottom.ColumnWidth = {'1x', '1x'};
bottom.Padding = [8 8 8 8];
bottom.RowSpacing = 6;
bottom.ColumnSpacing = 10;
try
    bottom.BackgroundColor = theme.color.panel;
catch
end
local_move_named(fig, bottom, 'ParameterListBoxLabel');
local_move_named(fig, bottom, 'GraphLabel');
local_move_named(fig, bottom, 'h_mesh_visualization_parameter_list');
local_move_named(fig, bottom, 'h_mesh_visualization_graph_list');

plot_btn = zef_ui_find(fig, 'h_plot_graph');
if isempty(plot_btn)
    plot_btn = findobj(fig, 'Type', 'uibutton', 'Text', 'Plot graph');
end
if ~isempty(plot_btn) && isvalid(plot_btn)
    plot_row = uigridlayout(bottom, [1 3]);
    plot_row.Layout.Row = 3;
    plot_row.Layout.Column = [1 2];
    plot_row.ColumnWidth = {'1x', 168, '1x'};
    plot_row.Padding = [0 0 0 0];
    try
        plot_row.BackgroundColor = theme.color.panel;
    catch
    end
    uilabel(plot_row, 'Text', '');
    plot_btn.Parent = plot_row;
    uilabel(plot_row, 'Text', '');
end

local_widen_edits(fig);
zef_ui_hide_orphans(fig);
fig.SizeChangedFcn = '';
try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_bind_min_size(fig, 680, 580);
zef_ui_adapt_grid(fig);

end

function g = local_section(parent, theme, sz)

g = uigridlayout(parent, sz);
g.Padding = [8 6 8 6];
g.RowSpacing = 4;
g.ColumnSpacing = 6;
try
    g.BackgroundColor = theme.color.panel;
catch
end

end

function local_fix_labels(fig)

pairs = { ...
    'RotationspeeddegsEditFieldLabel', 'Reconstruction type:'; ...
    'RotationspeeddegsEditFieldLabel_2', 'Visualization type:'; ...
    'PlotcolormapDropDownLabel', 'Frame start, stop, step:'; ...
    'CuttingplanecoeffEditFieldLabel', 'Orientation (az, el, FOV):'; ...
    'CuttingplanecoeffEditFieldLabel_2', 'Explode:'; ...
    'RotationspeeddegsLabel', 'Rotation (deg/s):'; ...
    'TransparencyrecsurfLabel', 'Transparency rec/surf:'; ...
    'PlotthresholdLabel', 'Plot threshold:'; ...
    'DistributionmodeLabel', 'Distribution mode:'; ...
    'PlotscaleLabel', 'Plot scale:'; ...
    'ColormapLabel', 'Colormap:'; ...
    'SubmeshLabel', 'Submesh:'; ...
    'CuttingplanemodeLabel', 'Clipping mode:'; ...
    'ParameterListBoxLabel', 'Parameter'; ...
    'GraphLabel', 'Graph'};
for i = 1:size(pairs, 1)
    labs = findall(fig, 'Type', 'uilabel');
    for k = 1:numel(labs)
        try
            if strcmp(labs(k).Tag, pairs{i, 1})
                labs(k).Text = pairs{i, 2};
            end
        catch
        end
    end
    named = findall(fig);
    for k = 1:numel(named)
        try
            if isprop(named(k), 'Tag') && strcmp(char(named(k).Tag), pairs{i, 1}) && isprop(named(k), 'Text')
                named(k).Text = pairs{i, 2};
            end
        catch
        end
    end
end

% App Designer stores labels as properties on the app, not always as Tag.
% Match by current (often truncated) Text and replace with the full string.
replace_text = { ...
    'Reconstrution type:', 'Reconstruction type:'; ...
    'Transparency rec./surf.:', 'Transparency rec/surf:'; ...
    'Attach electr...', 'Attach electrodes'; ...
    'Visualize t...', 'Visualize DTI streamlines'; ...
    'Distance / Explo...', 'Explode:'; ...
    'Am...', 'Orientation (az, el, FOV):'};
labs = findall(fig, 'Type', 'uilabel');
for k = 1:numel(labs)
    try
        txt = char(labs(k).Text);
        for i = 1:size(replace_text, 1)
            if strcmp(txt, replace_text{i, 1})
                labs(k).Text = replace_text{i, 2};
            end
        end
        labs(k).WordWrap = 'off';
        labs(k).Interpreter = 'none';
    catch
    end
end

cbs = findall(fig, 'Type', 'uicheckbox');
for k = 1:numel(cbs)
    try
        cbs(k).WordWrap = 'off';
        cbs(k).Interpreter = 'none';
        if contains(char(cbs(k).Text), 'Attach electr')
            cbs(k).Text = 'Attach electrodes';
        end
        if contains(char(cbs(k).Text), 'inflated')
            cbs(k).Text = 'Inflated surfaces';
        end
        if contains(char(cbs(k).Text), 'Clipping plane')
            cbs(k).Text = strrep(char(cbs(k).Text), ':', '');
        end
    catch
    end
end

end

function local_parent(fig, grid, names)

[n, m] = size(names);
for r = 1:n
    for c = 1:m
        h = local_by_prop(fig, names{r, c});
        if ~isempty(h) && isvalid(h)
            h.Parent = grid;
            h.Layout.Row = r;
            h.Layout.Column = c;
        end
    end
end

end

function local_move_named(fig, grid, name)

h = local_by_prop(fig, name);
if isempty(h)
    h = findall(fig, 'Type', 'uilabel');
    for i = 1:numel(h)
        if isprop(h(i), 'Tag') && strcmp(h(i).Tag, name)
            h(i).Parent = grid;
            return
        end
    end
    return
end
if isvalid(h)
    h.Parent = grid;
end

end

function local_clip_row(fig, parent, row, check_name, edit_names)

wrap = uigridlayout(parent, [1 1 + numel(edit_names)]);
wrap.ColumnWidth = [{36}, repmat({'1x'}, 1, numel(edit_names))];
wrap.RowHeight = {26};
wrap.Padding = [0 0 0 0];
wrap.ColumnSpacing = 6;
wrap.Layout.Row = row;
try
    wrap.BackgroundColor = parent.BackgroundColor;
catch
end
h = local_by_prop(fig, check_name);
if ~isempty(h) && isvalid(h)
    h.Parent = wrap;
    h.Layout.Row = 1;
    h.Layout.Column = 1;
    try
        txt = char(h.Text);
        if contains(txt, '1')
            h.Text = 'P1';
            h.Tooltip = 'Clip plane 1';
        elseif contains(txt, '2')
            h.Text = 'P2';
            h.Tooltip = 'Clip plane 2';
        elseif contains(txt, '3')
            h.Text = 'P3';
            h.Tooltip = 'Clip plane 3';
        end
    catch
    end
end
for i = 1:numel(edit_names)
    e = local_by_prop(fig, edit_names{i});
    if ~isempty(e) && isvalid(e)
        e.Parent = wrap;
        e.Layout.Row = 1;
        e.Layout.Column = 1 + i;
    end
end

end

function local_pair_row(fig, parent, label_name, field_names)

n = numel(field_names);
rowg = uigridlayout(parent, [1 2]);
rowg.ColumnWidth = {148, '1x'};
rowg.Padding = [0 0 0 0];
rowg.ColumnSpacing = 8;
try
    rowg.BackgroundColor = parent.BackgroundColor;
catch
end
lab = local_by_prop(fig, label_name);
if isempty(lab)
    labs = findall(fig, 'Type', 'uilabel');
    for i = 1:numel(labs)
        if strcmp(labs(i).Tag, label_name)
            lab = labs(i);
            break
        end
    end
end
if ~isempty(lab) && isvalid(lab)
    lab.Parent = rowg;
    lab.Layout.Row = 1;
    lab.Layout.Column = 1;
    try
        lab.HorizontalAlignment = 'right';
        lab.WordWrap = 'off';
    catch
    end
end
fields = uigridlayout(rowg, [1 max(n, 1)]);
fields.Padding = [0 0 0 0];
fields.ColumnSpacing = 6;
fields.ColumnWidth = repmat({'1x'}, 1, max(n, 1));
fields.Layout.Row = 1;
fields.Layout.Column = 2;
try
    fields.BackgroundColor = parent.BackgroundColor;
catch
end
for i = 1:n
    e = local_by_prop(fig, field_names{i});
    if ~isempty(e) && isvalid(e)
        e.Parent = fields;
        e.Layout.Row = 1;
        e.Layout.Column = i;
    end
end

end

function local_labeled(fig, parent, label_name, field_name)

rowg = uigridlayout(parent, [1 2]);
rowg.ColumnWidth = {148, '1x'};
rowg.Padding = [0 0 0 0];
rowg.ColumnSpacing = 8;
try
    rowg.BackgroundColor = parent.BackgroundColor;
catch
end
lab = local_by_prop(fig, label_name);
if isempty(lab)
    labs = findall(fig, 'Type', 'uilabel');
    for i = 1:numel(labs)
        if strcmp(labs(i).Tag, label_name)
            lab = labs(i);
            break
        end
    end
end
if ~isempty(lab) && isvalid(lab)
    lab.Parent = rowg;
    lab.Layout.Row = 1;
    lab.Layout.Column = 1;
    try
        lab.HorizontalAlignment = 'right';
        lab.WordWrap = 'off';
    catch
    end
end
if iscell(field_name)
    fields = uigridlayout(rowg, [1 numel(field_name)]);
    fields.Padding = [0 0 0 0];
    fields.ColumnWidth = repmat({'1x'}, 1, numel(field_name));
    fields.Layout.Row = 1;
    fields.Layout.Column = 2;
    try
        fields.BackgroundColor = parent.BackgroundColor;
    catch
    end
    for i = 1:numel(field_name)
        e = local_by_prop(fig, field_name{i});
        if ~isempty(e) && isvalid(e)
            e.Parent = fields;
            e.Layout.Row = 1;
            e.Layout.Column = i;
        end
    end
else
    e = local_by_prop(fig, field_name);
    if ~isempty(e) && isvalid(e)
        e.Parent = rowg;
        e.Layout.Row = 1;
        e.Layout.Column = 2;
    end
end

end

function local_widen_edits(fig)

edits = [findall(fig, 'Type', 'uieditfield'); findall(fig, 'Type', 'uinumericeditfield')];
for i = 1:numel(edits)
    try
        if isprop(edits(i), 'HorizontalAlignment')
            edits(i).HorizontalAlignment = 'right';
        end
    catch
    end
end

end

function h = local_by_prop(fig, name)

h = gobjects(0);
% App Designer copies handles onto zef as h_*, but on the figure the
% control Tag is often empty. Search by matching the app property name
% stored as Tag when present, else walk zef in the base workspace.
found = findall(fig, 'Tag', name);
if ~isempty(found)
    h = found(1);
    return
end
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, name) && isgraphics(zef.(name)) && isvalid(zef.(name))
        h = zef.(name);
        return
    end
catch
end

end
