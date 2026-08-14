function [file_name] = zef_bst_get_project_file_name(h_parent)
%ZEF_BST_GET_PROJECT_FILE_NAME  Proposed .mat path beside the settings script.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   file_name = zef_bst_get_project_file_name
%   file_name = zef_bst_get_project_file_name(h_parent)
%
%   From figure properties: folder_name / project_subfolder_name /
%   fileparts(settings_file_name) + '.mat'. Default h_parent is
%   get(gcbo,'Parent'). Does not check that the .mat exists.
%
%   See also zef_bst_plugin_start, zef_bst_edit_project.

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

settings_file_name = h_parent.settings_file_name;
folder_name = h_parent.folder_name;
subfolder_name = h_parent.project_subfolder_name;

% Extract base name from settings file and construct project file path
[settings_file_path, settings_file_name] = fileparts(settings_file_name);
settings_file_name = fullfile(settings_file_path,settings_file_name);
file_name = fullfile(folder_name,subfolder_name,[settings_file_name '.mat']);

end