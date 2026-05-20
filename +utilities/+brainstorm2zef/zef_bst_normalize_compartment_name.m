function normalized_name = zef_bst_normalize_compartment_name(name)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_normalize_compartment_name — Zef bst normalize compartment name.
%
% Purpose:
%   Zef bst normalize compartment name.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   name
%
% Outputs:
%   normalized_name
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_normalize_compartment_name
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[normalized_name] = utilities.brainstorm2zef.zef_bst_normalize_compartment_name(name)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if ~ischar(name) && ~isstring(name)
    normalized_name = '';
    return;
end

% Convert to string and lowercase
normalized_name = lower(string(name));

% Remove whitespace
normalized_name = strrep(normalized_name, ' ', '');
normalized_name = strrep(normalized_name, '_', '');
normalized_name = strrep(normalized_name, '-', '');

% Convert back to char for compatibility
normalized_name = char(normalized_name);

end
