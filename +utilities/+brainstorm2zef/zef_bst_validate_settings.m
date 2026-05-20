function [is_valid, error_msg] = zef_bst_validate_settings(zef_bst)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_validate_settings — Zef bst validate settings.
%
% Purpose:
%   Zef bst validate settings.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef_bst
%
% Outputs:
%   is_valid
%   error_msg
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_validate_settings
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[is_valid, error_msg]] = utilities.brainstorm2zef.zef_bst_validate_settings(zef_bst)` with project root and `src` on the path.
% --- End Zeffiro documentation header

is_valid = true;
error_msg = '';

% Required fields that must be present
required_fields = {
    'compartment_list', 'mesh_resolution', 'unit_conversion', ...
    'refine_surface', 'refine_volume', 'electrical_conductivity', ...
    'dof_space', 'use_gpu', 'parallel_processes'
};

% Check for required fields
for i = 1:length(required_fields)
    if ~isfield(zef_bst, required_fields{i})
        is_valid = false;
        error_msg = sprintf('Missing required field: %s', required_fields{i});
        return;
    end
end

% Validate mesh_resolution
if ~isnumeric(zef_bst.mesh_resolution) || zef_bst.mesh_resolution < 1 || zef_bst.mesh_resolution > 5
    is_valid = false;
    error_msg = 'mesh_resolution must be a numeric value between 1 and 5';
    return;
end

% Validate unit_conversion
if ~isnumeric(zef_bst.unit_conversion) || zef_bst.unit_conversion <= 0
    is_valid = false;
    error_msg = 'unit_conversion must be a positive numeric value';
    return;
end

% Validate compartment_list
if ~iscell(zef_bst.compartment_list) || isempty(zef_bst.compartment_list)
    is_valid = false;
    error_msg = 'compartment_list must be a non-empty cell array';
    return;
end

% Validate electrical_conductivity format (should be key-value pairs)
if ~iscell(zef_bst.electrical_conductivity) || mod(length(zef_bst.electrical_conductivity), 2) ~= 0
    is_valid = false;
    error_msg = 'electrical_conductivity must be a cell array with even number of elements (key-value pairs)';
    return;
end

% Validate dof_space format (should be key-value pairs)
if ~iscell(zef_bst.dof_space) || mod(length(zef_bst.dof_space), 2) ~= 0
    is_valid = false;
    error_msg = 'dof_space must be a cell array with even number of elements (key-value pairs)';
    return;
end

% Validate parallel_processes
if ~isnumeric(zef_bst.parallel_processes) || zef_bst.parallel_processes < 1
    is_valid = false;
    error_msg = 'parallel_processes must be a positive integer';
    return;
end

% Validate logical fields
logical_fields = {'use_gpu', 'refine_surface_on', 'refine_volume_on', ...
    'inflation_on', 'mesh_smoothing_on', 'distance_smoothing_on'};
for i = 1:length(logical_fields)
    if isfield(zef_bst, logical_fields{i})
        if ~islogical(zef_bst.(logical_fields{i})) && ~ismember(zef_bst.(logical_fields{i}), [0, 1])
            is_valid = false;
            error_msg = sprintf('%s must be a logical value (0 or 1)', logical_fields{i});
            return;
        end
    end
end

end
