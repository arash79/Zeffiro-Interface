function value = zef_bst_get_compartment_property(compartment_name, property_cell, default_value)
%ZEF_BST_GET_COMPARTMENT_PROPERTY  Lookup a key in a name/value cell pair list.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   value = zef_bst_get_compartment_property(name, property_cell)
%   value = zef_bst_get_compartment_property(name, property_cell, default)
%
%   property_cell is {key, val, key, val, ...} as used for
%   zef_bst.electrical_conductivity and zef_bst.dof_space. Match order:
%   exact ismember, then lower(), then zef_bst_normalize_compartment_name.
%   Odd-length or non-cell lists return default (nargin < 3 → []).
%
%   See also zef_bst_compartment_settings, zef_bst_normalize_compartment_name.

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
