function zef = zef_apply_mesh_tool_values(zef)
%ZEF_APPLY_MESH_TOOL_VALUES  Copy zef mesh-tool fields onto live widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inverse of zef_update_mesh_tool. After open_project / a run_script that
%   sets mesh_resolution, max_surface_face_count, etc., the Mesh tool still
%   holds startup defaults. The next zef_update would write those defaults
%   back onto zef. Push zef → widgets first (with ValueChangedFcn cleared
%   so the write does not recurse).
%
%   zef = zef_apply_mesh_tool_values(zef)
%
%   See also zef_update_mesh_tool, zef_load, zef_create_finite_element_mesh.

if nargin == 0
    zef = evalin('base', 'zef');
end

if ~isstruct(zef) || ~isfield(zef, 'h_mesh_tool') || ~isvalid(zef.h_mesh_tool)
    if nargout == 0
        assignin('base', 'zef', zef);
    end
    return
end

handles = { ...
    'h_checkbox_mesh_smoothing_on', ...
    'h_refinement_on', ...
    'h_source_interpolation_on', ...
    'h_downsample_surfaces', ...
    'h_popupmenu6', ...
    'h_popupmenu2', ...
    'h_edit65', ...
    'h_edit_meshing_accuracy', ...
    'h_smoothing_strength', ...
    'h_edit76', ...
    'h_edit75', ...
    'h_max_surface_face_count', ...
    'h_inflate_n_iterations', ...
    'h_inflate_strength', ...
    'h_forward_simulation_script', ...
    'h_forward_simulation_table'};

saved = cell(size(handles));
for i = 1:numel(handles)
    saved{i} = local_clear_callback(zef, handles{i});
end

local_set(zef, 'h_checkbox_mesh_smoothing_on', 'mesh_smoothing_on');
local_set(zef, 'h_refinement_on', 'refinement_on');
local_set(zef, 'h_source_interpolation_on', 'source_interpolation_on');
local_set(zef, 'h_downsample_surfaces', 'downsample_surfaces');
local_set(zef, 'h_popupmenu6', 'location_unit');
local_set(zef, 'h_popupmenu2', 'source_direction_mode');
local_set(zef, 'h_edit65', 'mesh_resolution');
local_set(zef, 'h_edit_meshing_accuracy', 'meshing_accuracy');
local_set(zef, 'h_smoothing_strength', 'smoothing_strength');
local_set(zef, 'h_edit76', 'solver_tolerance');
local_set(zef, 'h_edit75', 'n_sources');
local_set(zef, 'h_max_surface_face_count', 'max_surface_face_count');
local_set(zef, 'h_inflate_n_iterations', 'inflate_n_iterations');
local_set(zef, 'h_inflate_strength', 'inflate_strength');

if isfield(zef, 'h_forward_simulation_table') && isvalid(zef.h_forward_simulation_table) ...
        && isfield(zef, 'forward_simulation_table')
    try
        zef.h_forward_simulation_table.Data = zef.forward_simulation_table;
    catch
    end
end
if isfield(zef, 'h_forward_simulation_script') && isvalid(zef.h_forward_simulation_script) ...
        && isfield(zef, 'forward_simulation_script')
    try
        zef.h_forward_simulation_script.Value = char(string(zef.forward_simulation_script));
    catch
    end
end

for i = 1:numel(handles)
    local_restore_callback(zef, handles{i}, saved{i});
end

if nargout == 0
    assignin('base', 'zef', zef);
end

end

function cb = local_clear_callback(zef, name)
cb = [];
if ~isfield(zef, name)
    return
end
h = zef.(name);
if isempty(h) || ~isvalid(h)
    return
end
try
    if isprop(h, 'ValueChangedFcn')
        cb = struct('prop', 'ValueChangedFcn', 'value', h.ValueChangedFcn);
        h.ValueChangedFcn = '';
        return
    end
catch
end
try
    if isprop(h, 'DisplayDataChangedFcn')
        cb = struct('prop', 'DisplayDataChangedFcn', 'value', h.DisplayDataChangedFcn);
        h.DisplayDataChangedFcn = '';
    end
catch
end
end

function local_restore_callback(zef, name, cb)
if isempty(cb) || ~isfield(zef, name)
    return
end
h = zef.(name);
if isempty(h) || ~isvalid(h)
    return
end
try
    h.(cb.prop) = cb.value;
catch
end
end

function local_set(zef, handle_name, field_name)
if ~isfield(zef, handle_name) || ~isfield(zef, field_name)
    return
end
h = zef.(handle_name);
if isempty(h) || ~isvalid(h)
    return
end
val = zef.(field_name);
try
    if isnumeric(val) && any(isinf(val(:))) && isprop(h, 'Limits')
        h.Limits = [-Inf Inf];
    end
    h.Value = val;
catch
end
end
