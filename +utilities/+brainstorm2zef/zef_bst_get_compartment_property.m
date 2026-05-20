function value = zef_bst_get_compartment_property(compartment_name, property_cell, default_value)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_get_compartment_property — Zef bst get compartment property.
%
% Purpose:
%   Zef bst get compartment property.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   compartment_name
%   property_cell
%   default_value
%
% Outputs:
%   value
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_get_compartment_property
%   utilities.brainstorm2zef.zef_bst_normalize_compartment_name
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[value] = utilities.brainstorm2zef.zef_bst_get_compartment_property(compartment_name, property_cell, default_value)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
