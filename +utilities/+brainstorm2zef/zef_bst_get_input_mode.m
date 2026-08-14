function [input_mode] = zef_bst_get_input_mode(h_parent)
%ZEF_BST_GET_INPUT_MODE  Popup Value of Tag='input_mode' on the plugin figure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   input_mode = zef_bst_get_input_mode
%   input_mode = zef_bst_get_input_mode(h_parent)
%
%   Numeric popup index. Strings are {'Use input files','Ignore input files'}
%   → 1 keep zef_bst.compartment_files, 2 clear them in create_project.
%   Default h_parent is get(gcbo,'Parent').
%
%   See also zef_bst_plugin_start, zef_bst_create_project.

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

h_object = findobj(h_parent.Children,'Tag','input_mode');
input_mode = h_object.Value;

end