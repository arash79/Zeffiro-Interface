function zef_bst_edit_project(project_file_name)
%ZEF_BST_EDIT_PROJECT  Open an existing .mat in a display Zeffiro session.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_bst_edit_project(project_file_name)
%
%   If exist(project_file_name,'file'), calls
%   zeffiro_interface('start_mode','display','open_project',project_file_name).
%   Silent no-op if the file is missing. Plugin "Edit project" button.
%
%   See also zef_bst_get_project_file_name, zef_bst_plugin_start.

if exist(project_file_name,'file')
    zeffiro_interface('start_mode','display','open_project',project_file_name);
end

end
