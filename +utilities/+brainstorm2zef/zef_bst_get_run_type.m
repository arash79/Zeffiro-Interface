function [run_type] = zef_bst_get_run_type(h_parent)
%ZEF_BST_GET_RUN_TYPE  Popup Value of Tag='run_type' on the plugin figure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   run_type = zef_bst_get_run_type
%   run_type = zef_bst_get_run_type(h_parent)
%
%   Numeric popup index, not a string. Strings on the control are
%   {'Fresh start','Import compartments','Use project'} → 1, 2, 3.
%   Default h_parent is get(gcbo,'Parent').
%
%   See also zef_bst_plugin_start, zef_bst_create_project.

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

h_object = findobj(h_parent.Children,'Tag','run_type');
run_type = h_object.Value;

end