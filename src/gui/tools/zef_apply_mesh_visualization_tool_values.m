function zef = zef_apply_mesh_visualization_tool_values(zef)
%ZEF_APPLY_MESH_VISUALIZATION_TOOL_VALUES  Copy visualization fields onto widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inverse of zef_update_mesh_visualization_tool. Camera, clipping,
%   colormap, and related flags live on zef. Widgets display them.
%   ValueChangedFcn remains the only widgets → zef path.
%
%   zef = zef_apply_mesh_visualization_tool_values(zef)
%
%   See also zef_update_mesh_visualization_tool, zef_update.

if nargin == 0
    zef = evalin('base', 'zef');
end

if ~isstruct(zef) || ~isfield(zef, 'h_mesh_visualization_tool') ...
        || ~isvalid(zef.h_mesh_visualization_tool)
    if nargout == 0
        assignin('base', 'zef', zef);
    end
    return
end

direct = { ...
    'h_show_contour', 'show_contour'; ...
    'h_show_contour_text', 'show_contour_text'; ...
    'h_contour_set_text', 'contour_set_text'; ...
    'h_checkbox14', 'attach_electrodes'; ...
    'h_checkbox15', 'axes_visible'; ...
    'h_edit80', 'azimuth'; ...
    'h_edit81', 'elevation'; ...
    'h_edit82', 'cam_va'; ...
    'h_visualization_type', 'visualization_type'; ...
    'h_cp2_on', 'cp2_on'; ...
    'h_cp3_on', 'cp3_on'; ...
    'h_reconstruction_type', 'reconstruction_type'; ...
    'h_checkbox_cp_on', 'cp_on'; ...
    'h_inv_scale', 'inv_scale'; ...
    'h_inv_colormap', 'inv_colormap'; ...
    'h_cp_mode', 'cp_mode'; ...
    'h_use_inflated_surfaces', 'use_inflated_surfaces'; ...
    'h_explode_everything', 'explode_everything'; ...
    'h_cone_draw', 'cone_draw'; ...
    'h_streamline_draw', 'streamline_draw'; ...
    'h_volumetric_distribution_mode', 'volumetric_distribution_mode'};

as_text = { ...
    'h_frame_start', 'frame_start'; ...
    'h_frame_stop', 'frame_stop'; ...
    'h_frame_step', 'frame_step'; ...
    'h_orbit', 'orbit_1'; ...
    'h_orbit_2', 'orbit_2'; ...
    'h_cp2_a', 'cp2_a'; ...
    'h_cp2_b', 'cp2_b'; ...
    'h_cp2_c', 'cp2_c'; ...
    'h_cp2_d', 'cp2_d'; ...
    'h_cp3_a', 'cp3_a'; ...
    'h_cp3_b', 'cp3_b'; ...
    'h_cp3_c', 'cp3_c'; ...
    'h_cp3_d', 'cp3_d'; ...
    'h_edit_cp_a', 'cp_a'; ...
    'h_edit_cp_b', 'cp_b'; ...
    'h_edit_cp_c', 'cp_c'; ...
    'h_edit_cp_d', 'cp_d'; ...
    'h_submesh_num', 'submesh_num'};

saved = cell(size(direct, 1) + size(as_text, 1) + 6, 2);
n_saved = 0;
for i = 1:size(direct, 1)
    n_saved = n_saved + 1;
    saved(n_saved, :) = local_clear(zef, direct{i, 1});
    local_set(zef, direct{i, 1}, direct{i, 2}, false);
end
for i = 1:size(as_text, 1)
    n_saved = n_saved + 1;
    saved(n_saved, :) = local_clear(zef, as_text{i, 1});
    local_set(zef, as_text{i, 1}, as_text{i, 2}, true);
end

n_saved = n_saved + 1;
saved(n_saved, :) = local_clear(zef, 'h_layer_transparency');
local_set_opacity(zef, 'h_layer_transparency', 'layer_transparency');
n_saved = n_saved + 1;
saved(n_saved, :) = local_clear(zef, 'h_brain_transparency');
local_set_opacity(zef, 'h_brain_transparency', 'brain_transparency');
n_saved = n_saved + 1;
saved(n_saved, :) = local_clear(zef, 'h_inv_dynamic_range');
local_set_dynamic_range(zef);

n_saved = n_saved + 1;
saved(n_saved, :) = local_clear(zef, 'h_mesh_visualization_parameter_list');
local_set_choice(zef, 'h_mesh_visualization_parameter_list', 'mesh_visualization_parameter_selected');
n_saved = n_saved + 1;
saved(n_saved, :) = local_clear(zef, 'h_mesh_visualization_graph_list');
local_set_choice(zef, 'h_mesh_visualization_graph_list', 'mesh_visualization_graph_selected');
local_enable_plane(zef, 'cp_on', {'h_edit_cp_a', 'h_edit_cp_b', 'h_edit_cp_c', 'h_edit_cp_d'});
local_enable_plane(zef, 'cp2_on', {'h_cp2_a', 'h_cp2_b', 'h_cp2_c', 'h_cp2_d'});
local_enable_plane(zef, 'cp3_on', {'h_cp3_a', 'h_cp3_b', 'h_cp3_c', 'h_cp3_d'});

for i = 1:n_saved
    local_restore(zef, saved{i, 1}, saved{i, 2});
end

if nargout == 0
    assignin('base', 'zef', zef);
end

end

function pair = local_clear(zef, name)
pair = {name, []};
if ~isfield(zef, name)
    return
end
h = zef.(name);
if isempty(h) || ~isvalid(h) || ~isprop(h, 'ValueChangedFcn')
    return
end
pair = {name, h.ValueChangedFcn};
h.ValueChangedFcn = '';
end

function local_restore(zef, name, cb)
if isempty(name) || isempty(cb) || ~isfield(zef, name)
    return
end
h = zef.(name);
if isempty(h) || ~isvalid(h)
    return
end
try
    h.ValueChangedFcn = cb;
catch
end
end

function local_set(zef, handle_name, field_name, as_text)
if ~isfield(zef, handle_name) || ~isfield(zef, field_name)
    return
end
h = zef.(handle_name);
if isempty(h) || ~isvalid(h)
    return
end
val = zef.(field_name);
try
    if as_text
        h.Value = char(string(val));
    else
        h.Value = val;
    end
catch
end
end

function local_set_opacity(zef, handle_name, field_name)
if ~isfield(zef, handle_name) || ~isfield(zef, field_name)
    return
end
h = zef.(handle_name);
if isempty(h) || ~isvalid(h)
    return
end
try
    h.Value = char(string(1 - zef.(field_name)));
catch
end
end

function local_set_dynamic_range(zef)
if ~isfield(zef, 'h_inv_dynamic_range') || ~isfield(zef, 'inv_dynamic_range')
    return
end
h = zef.h_inv_dynamic_range;
if isempty(h) || ~isvalid(h)
    return
end
val = zef.inv_dynamic_range;
try
    if isempty(val) || ~isfinite(val) || val == 0
        shown = 0;
    else
        shown = 1 / val;
    end
    h.Value = char(string(shown));
catch
end
end

function local_set_choice(zef, handle_name, field_name)
if ~isfield(zef, handle_name) || ~isfield(zef, field_name)
    return
end
h = zef.(handle_name);
if isempty(h) || ~isvalid(h)
    return
end
try
    h.Value = zef.(field_name);
catch
end
end

function local_enable_plane(zef, flag_name, handles)
if ~isfield(zef, flag_name)
    return
end
if zef.(flag_name)
    state = 'on';
else
    state = 'off';
end
for i = 1:numel(handles)
    if ~isfield(zef, handles{i})
        continue
    end
    h = zef.(handles{i});
    if isempty(h) || ~isvalid(h)
        continue
    end
    try
        h.Enable = state;
    catch
    end
end
end
