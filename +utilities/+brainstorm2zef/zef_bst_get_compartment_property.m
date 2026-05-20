function value = zef_bst_get_compartment_property(compartment_name, property_cell, default_value)
%ZEF_BST_GET_COMPARTMENT_PROPERTY Gets a property value for a compartment from key-value cell array.
%
% This utility function extracts property values (like conductivity or DOF space)
% from a key-value cell array format used in settings. It handles both exact
% and normalized name matching for robustness.
%
% Inputs:
%   compartment_name - Name of the compartment (e.g., 'Scalp', 'Cortex')
%   property_cell    - Cell array with alternating keys and values
%                      Example: {'Scalp', 0.34, 'Cortex', 0.33}
%   default_value    - Default value to return if compartment not found
%
% Outputs:
%   value - Property value for the compartment, or default_value if not found
%
% Example:
%   conductivity = utilities.brainstorm2zef.zef_bst_get_compartment_property(...
%       'Scalp', {'Scalp', 0.34, 'Cortex', 0.33}, 1.0);
%   % Returns: 0.34
%
% See also: ZEF_BST_COMPARTMENT_SETTINGS

if nargin < 3
    default_value = [];
end

if ~iscell(property_cell) || mod(length(property_cell), 2) ~= 0
    value = default_value;
    return;
end

% Try exact match first
keys = property_cell(1:2:end);
values = property_cell(2:2:end);

exact_match = find(ismember(keys, compartment_name), 1);
if ~isempty(exact_match)
    value = values{exact_match};
    return;
end

% Try case-insensitive match
case_insensitive_match = find(ismember(lower(keys), lower(compartment_name)), 1);
if ~isempty(case_insensitive_match)
    value = values{case_insensitive_match};
    return;
end

% Try normalized match
normalized_compartment = utilities.brainstorm2zef.zef_bst_normalize_compartment_name(compartment_name);
normalized_keys = cellfun(@(x) utilities.brainstorm2zef.zef_bst_normalize_compartment_name(x), keys, 'UniformOutput', false);
normalized_match = find(ismember(normalized_keys, normalized_compartment), 1);
if ~isempty(normalized_match)
    value = values{normalized_match};
    return;
end

% No match found, return default
value = default_value;

end
