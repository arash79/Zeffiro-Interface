function normalized_name = zef_bst_normalize_compartment_name(name)
%ZEF_BST_NORMALIZE_COMPARTMENT_NAME Normalizes compartment names for consistent matching.
%
% This function normalizes compartment names by removing whitespace, converting
% to a standard case, and handling common variations in naming conventions.
% This improves the robustness of compartment matching across different
% Brainstorm projects.
%
% Inputs:
%   name - String containing compartment name (e.g., 'Scalp', 'Outer Skull')
%
% Outputs:
%   normalized_name - Normalized compartment name (e.g., 'scalp', 'outerskull')
%
% Example:
%   norm_name = utilities.brainstorm2zef.zef_bst_normalize_compartment_name('Outer Skull');
%   % Returns: 'outerskull'
%
% See also: ZEF_BST_FIND_COMPARTMENT

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
