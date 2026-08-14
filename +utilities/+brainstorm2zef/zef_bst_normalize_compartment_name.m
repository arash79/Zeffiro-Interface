function normalized_name = zef_bst_normalize_compartment_name(name)
%ZEF_BST_NORMALIZE_COMPARTMENT_NAME  lower(name) with spaces, '_', '-' removed.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   normalized_name = zef_bst_normalize_compartment_name(name)
%
%   Non-char/string name returns ''. Output is char. Used when matching
%   Brainstorm Comment strings to zef_bst.compartment_list entries.
%
%   See also zef_bst_find_compartment, zef_bst_get_compartment_property.

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
