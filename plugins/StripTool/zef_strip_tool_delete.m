function zef = zef_strip_tool_delete(zef)
%ZEF_STRIP_TOOL_DELETE  Remove the selected strip and its electrode contacts.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_delete(zef)
%
%   Delete button. Drops strip_cell{current_strip} and every sensor row
%   Add contacts registered to that lead. Registration is the strip_id
%   returned by the contact get_function and the strip_cell index stored
%   in that function string. Remaining strip get_functions are rewritten
%   so their cell index follows the compacted list. Cached electrode
%   products (sensors, the attachment table, the lead field) are updated
%   or cleared so a later forward run cannot keep the deleted channels.
%   Figure-tool glyphs stamped with that strip or sensor index are
%   removed. Does not remove already-embedded compartments.
%
%   See also zef_strip_tool_add, zef_strip_tool_add_contacts, zef_strip_tool_plot.

prefix = zef.current_sensors;
strip_field = [prefix '_strip_cell'];
strip_cell = zef.(strip_field);
deleted_index = zef.strip_tool.current_strip;
strip_id = strip_cell{deleted_index}.strip_id;

drop = local_owned_contact_rows(zef, prefix, strip_id, deleted_index);
zef = local_drop_contact_rows(zef, prefix, drop);

keep_strips = setdiff(1:numel(strip_cell), deleted_index);
if isempty(keep_strips)
    zef.(strip_field) = cell(0);
else
    zef.(strip_field) = strip_cell(keep_strips);
end
function_field = [prefix '_get_functions'];
if isfield(zef, function_field)
    zef.(function_field) = local_reindex_get_functions( ...
        zef.(function_field), prefix, deleted_index);
end
zef = local_sync_electrode_products(zef, drop);
zef = local_remove_lead_graphics(zef, strip_id, drop);
zef = local_refresh_name_table(zef, prefix);

[zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
zef.strip_burr_report = report;

zef.strip_tool.current_strip = 1;
zef_colored_list('value', zef.strip_tool.h_strip_list, 1);

zef = zef_strip_tool_init(zef);
zef = zef_strip_tool_update(zef);

end

function drop = local_owned_contact_rows(zef, prefix, strip_id, strip_index)
% Rows Add contacts appended for this lead. A get_function owns the row
% when it names this strip_cell slot or its sensor_info strip_id matches.
n_points = size(zef.([prefix '_points']), 1);
drop = false(n_points, 1);
function_field = [prefix '_get_functions'];
if n_points == 0 || ~isfield(zef, function_field) || isempty(zef.(function_field))
    return
end
functions = zef.(function_field);
for index = 1:min(n_points, numel(functions))
    if local_function_owns_strip(functions{index}, zef, prefix, strip_id, strip_index)
        drop(index) = true;
    end
end
end

function owns = local_function_owns_strip(function_string, zef, prefix, strip_id, strip_index)
owns = false;
if isempty(function_string) || ~(ischar(function_string) || isstring(function_string))
    return
end
function_string = char(function_string);
bound_index = local_strip_cell_index(function_string, prefix);
if isequal(bound_index, strip_index)
    owns = true;
    return
end
try
    [~, sensor_info] = zef_sensor_get_function_eval(function_string, zef, 'sensor_info');
catch
    return
end
owns = isstruct(sensor_info) && isscalar(sensor_info) ...
    && isfield(sensor_info, 'strip_id') && isequal(sensor_info.strip_id, strip_id);
end

function strip_index = local_strip_cell_index(function_string, prefix)
strip_index = [];
pattern = [regexptranslate('escape', prefix) '_strip_cell\{(\d+)\}'];
token = regexp(function_string, pattern, 'tokens', 'once');
if isempty(token)
    return
end
strip_index = str2double(token{1});
if ~isscalar(strip_index) || ~isfinite(strip_index)
    strip_index = [];
end
end

function zef = local_drop_contact_rows(zef, prefix, drop)
if ~any(drop)
    return
end
n_points = numel(drop);
keep = find(~drop);
fields = { ...
    'points', 'directions', 'electrode_impedance', 'electrode_inner_radius', ...
    'electrode_outer_radius', 'name_list', 'visible_list', 'color_table', ...
    'get_functions'};
if isfield(zef, 'parameter_profile') && iscell(zef.parameter_profile)
    for row = 1:size(zef.parameter_profile, 1)
        if isequal(zef.parameter_profile{row, 8}, 'Sensors') ...
                && isequal(zef.parameter_profile{row, 6}, 'On') ...
                && isequal(zef.parameter_profile{row, 7}, 'On')
            fields{end + 1} = zef.parameter_profile{row, 2}; %#ok<AGROW>
        end
    end
end
fields = unique(fields, 'stable');
for index = 1:numel(fields)
    field = [prefix '_' fields{index}];
    if ~isfield(zef, field)
        continue
    end
    zef.(field) = local_keep_aligned(zef.(field), keep, n_points);
end
end

function value = local_keep_aligned(value, keep, n_points)
% Per-electrode columns follow the point rows. A scalar is a shared
% setting and is left in place.
if isempty(value)
    return
end
if size(value, 1) == n_points
    value = value(keep, :);
elseif isrow(value) && numel(value) == n_points
    value = value(:, keep);
end
end

function functions = local_reindex_get_functions(functions, prefix, deleted_index)
if isempty(functions)
    return
end
for index = 1:numel(functions)
    if isempty(functions{index}) || ~(ischar(functions{index}) || isstring(functions{index}))
        continue
    end
    functions{index} = local_reindex_one(char(functions{index}), prefix, deleted_index);
end
end

function function_string = local_reindex_one(function_string, prefix, deleted_index)
pattern = [regexptranslate('escape', prefix) '_strip_cell\{(\d+)\}'];
tokens = regexp(function_string, pattern, 'tokens');
if isempty(tokens)
    return
end
numbers = unique(cellfun(@(token) str2double(token{1}), tokens));
numbers = sort(numbers(numbers > deleted_index), 'descend');
for number = numbers(:)'
    function_string = strrep(function_string, ...
        sprintf('%s_strip_cell{%d}', prefix, number), ...
        sprintf('%s_strip_cell{%d}', prefix, number - 1));
end
end

function zef = local_sync_electrode_products(zef, drop)
if ~any(drop)
    return
end
n_points = numel(drop);
keep = find(~drop);
if isfield(zef, 'sensors') && ~isempty(zef.sensors) && size(zef.sensors, 1) == n_points
    zef.sensors = zef.sensors(keep, :);
end
% The attachment table and L are derived from the electrode set. The
% forward builders recompute them. Leaving the previous table in place
% would keep deleted channel ids in the next lead field.
if isfield(zef, 'sensors_attached_volume')
    zef.sensors_attached_volume = [];
end
if isfield(zef, 'L')
    zef.L = [];
end
if isfield(zef, 'inv_bg_data')
    zef.inv_bg_data = [];
end
end

function zef = local_remove_lead_graphics(zef, strip_id, drop)
if ~isfield(zef, 'h_axes1') || ~isgraphics(zef.h_axes1)
    return
end
removed = find(drop);
objects = findobj(zef.h_axes1);
for index = 1:numel(objects)
    object = objects(index);
    if ~isgraphics(object)
        continue
    end
    payload = object.UserData;
    if ~(isstruct(payload) && isscalar(payload))
        continue
    end
    if isfield(payload, 'strip_id') && isequal(payload.strip_id, strip_id)
        delete(object);
    elseif isfield(payload, 'sensor_index') && ismember(payload.sensor_index, removed)
        delete(object);
    end
end
if isempty(removed)
    return
end
objects = findobj(zef.h_axes1);
for index = 1:numel(objects)
    object = objects(index);
    if ~isgraphics(object)
        continue
    end
    payload = object.UserData;
    if ~(isstruct(payload) && isscalar(payload) && isfield(payload, 'sensor_index'))
        continue
    end
    sensor_index = payload.sensor_index;
    if isempty(sensor_index) || ~isscalar(sensor_index) || ismember(sensor_index, removed)
        continue
    end
    payload.sensor_index = sensor_index - sum(removed < sensor_index);
    object.UserData = payload;
end
end

function zef = local_refresh_name_table(zef, prefix)
if ~isfield(zef, 'h_sensors_name_table') || ~isgraphics(zef.h_sensors_name_table)
    return
end
required = {'_points', '_name_list', '_visible', '_visible_list', '_color_table', '_color'};
for index = 1:numel(required)
    if ~isfield(zef, [prefix required{index}])
        return
    end
end
zef = zef_init_sensors_name_table(zef);
end
