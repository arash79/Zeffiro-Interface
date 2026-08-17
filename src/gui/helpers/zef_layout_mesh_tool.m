function zef_layout_mesh_tool(fig)
%ZEF_LAYOUT_MESH_TOOL  Two-column grid layout for the Mesh tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Left: mesh actions and parameters. Right: forward-simulation table
%   and script. Full labels replace truncated App Designer strings.
%
%   See also zef_mesh_tool, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    return
end

theme = zef_ui_theme();
fig.AutoResizeChildren = 'on';
try
    fig.Scrollable = 'off';
catch
end

local_fix_labels(fig);

btns = findall(fig, 'Type', 'uibutton');
for i = 1:numel(btns)
    try
        t = btns(i).Text;
        joined = strtrim(regexprep(char(join(string(t), ' ')), '\s+', ' '));
        if ~isempty(joined)
            btns(i).Text = joined;
        end
    catch
    end
end

root = uigridlayout(fig, [1 2]);
root.Tag = 'zef_ui_root';
root.ColumnWidth = {340, '1x'};
root.Padding = [12 12 12 12];
root.ColumnSpacing = 12;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

left = uigridlayout(root, [3 1]);
left.RowHeight = {'fit', 'fit', '1x'};
left.RowSpacing = 6;
left.Padding = [0 0 0 0];
try
    left.BackgroundColor = theme.color.bg;
catch
end

actions = uigridlayout(left, [3 2]);
actions.RowHeight = {32, 32, 32};
actions.ColumnWidth = {'1x', '1x'};
actions.Padding = [8 8 8 8];
actions.RowSpacing = 6;
actions.ColumnSpacing = 6;
try
    actions.BackgroundColor = theme.color.panel;
catch
end
local_move(fig, actions, 'h_pushbutton21');
local_move(fig, actions, 'h_pushbutton34');
local_move(fig, actions, 'h_field_downsampling');
local_move(fig, actions, 'h_surface_downsampling');
local_move(fig, actions, 'h_interpolate');
local_move(fig, actions, 'h_pushbutton23');

opts = uigridlayout(left, [2 2]);
opts.ColumnWidth = {'fit', 'fit'};
opts.Padding = [8 8 8 8];
opts.RowSpacing = 4;
opts.ColumnSpacing = 16;
opts.RowHeight = {26, 26};
try
    opts.BackgroundColor = theme.color.panel;
catch
end
local_move(fig, opts, 'h_refinement_on');
local_move(fig, opts, 'h_checkbox_mesh_smoothing_on');
local_move(fig, opts, 'h_source_interpolation_on');
local_move(fig, opts, 'h_downsample_surfaces');

params = uigridlayout(left, [9 2]);
params.ColumnWidth = {'1x', 96};
params.RowHeight = repmat({'1x'}, 1, 9);
params.Padding = [10 8 10 8];
params.RowSpacing = 6;
try
    params.BackgroundColor = theme.color.panel;
catch
end
local_pair(fig, params, 'CuttingplanecoeffEditFieldLabel_6', 'h_edit75');
local_pair(fig, params, 'CuttingplanecoeffEditFieldLabel_4', 'h_edit65');
local_pair(fig, params, 'CuttingplanecoeffEditFieldLabel_5', 'h_edit_meshing_accuracy');
local_pair(fig, params, 'SurfacetrianglesmaxLabel', 'h_max_surface_face_count');
local_pair(fig, params, 'CuttingplanecoeffEditFieldLabel_7', 'h_smoothing_strength');
local_pair(fig, params, 'CuttingplanecoeffEditFieldLabel_8', 'h_edit76');
local_pair(fig, params, 'InflatingiterationsLabel', 'h_inflate_n_iterations');
local_pair(fig, params, 'CuttingplanecoeffEditFieldLabel_9', 'h_inflate_strength');
local_pair(fig, params, 'DirectionsDropDownLabel', 'h_popupmenu2');

right = uigridlayout(root, [3 1]);
right.Tag = 'zef_mesh_right';
right.RowHeight = {'1.8x', '0.70x', 36};
right.RowSpacing = 8;
right.Padding = [0 0 0 0];
try
    right.BackgroundColor = theme.color.bg;
catch
end
local_move(fig, right, 'h_forward_simulation_table');
local_move(fig, right, 'h_forward_simulation_script');

btns = uigridlayout(right, [1 3]);
btns.ColumnWidth = {'1x', '1.45x', '1x'};
btns.Padding = [0 0 0 0];
btns.ColumnSpacing = 8;
try
    btns.BackgroundColor = theme.color.bg;
catch
end
local_move(fig, btns, 'h_save_forward_simulation_profile');
local_move(fig, btns, 'h_forward_simulation_update_from_profile');
local_move(fig, btns, 'h_run_forward_simulation');

zef_ui_hide_orphans(fig);
fig.SizeChangedFcn = '';
try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_bind_min_size(fig, 680, 460);
zef_ui_adapt_grid(fig);

end

function local_fix_labels(fig)

map = { ...
    'LF source interp.', 'LF interpolation'; ...
    'Lead-field source interpolation', 'LF interpolation'; ...
    'Lead-field interpolation', 'LF interpolation'; ...
    'Resample surf.', 'Resample surfaces'; ...
    'Surface triangles max.:', 'Surface triangles (max.)'; ...
    'Source/Field count:', 'Source / field count'; ...
    'Mesh resolution:', 'Mesh resolution'; ...
    'Meshing accuracy:', 'Meshing accuracy'; ...
    'Smoothing strength:', 'Smoothing strength'; ...
    'Solver tolerance:', 'Solver tolerance'; ...
    'Inflating iterations:', 'Inflating iterations'; ...
    'Inflating strength:', 'Inflating strength'; ...
    'Directions:', 'Source directions'; ...
    'Update from', 'Update from profile'};

objs = findall(fig);
for i = 1:numel(objs)
    txt_prop = '';
    if isprop(objs(i), 'Text')
        txt_prop = 'Text';
    elseif isprop(objs(i), 'String')
        txt_prop = 'String';
    end
    if isempty(txt_prop)
        continue
    end
    try
        txt = objs(i).(txt_prop);
        if iscell(txt)
            joined = strtrim(sprintf('%s ', txt{:}));
            for k = 1:size(map, 1)
                if contains(joined, map{k, 1}) || strcmp(strtrim(joined), map{k, 1})
                    objs(i).(txt_prop) = map{k, 2};
                    break
                end
            end
        else
            raw = char(string(txt));
            for k = 1:size(map, 1)
                if strcmp(strtrim(raw), map{k, 1})
                    objs(i).(txt_prop) = map{k, 2};
                    break
                end
            end
        end
    catch
    end
end

end

function local_move(fig, parent, name)

h = findall(fig, 'Tag', name);
if isempty(h)
    try
        zef = evalin('base', 'zef');
        if isfield(zef, name)
            h = zef.(name);
        end
    catch
        h = gobjects(0);
    end
end
if ~isempty(h) && isgraphics(h(1)) && isvalid(h(1))
    h(1).Parent = parent;
    try
        if strcmpi(char(h(1).Type), 'uitable')
            zef_ui_fit_table(h(1));
        end
    catch
    end
end

end

function local_pair(fig, parent, label_name, field_name)

local_move(fig, parent, label_name);
local_move(fig, parent, field_name);
lab = findall(parent, 'Type', 'uilabel');
for i = 1:numel(lab)
    try
        lab(i).HorizontalAlignment = 'right';
        lab(i).WordWrap = 'off';
    catch
    end
end

end
