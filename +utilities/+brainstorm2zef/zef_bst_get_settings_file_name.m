function [file_name] = zef_bst_get_settings_file_name(h_parent)
%ZEF_BST_GET_SETTINGS_FILE_NAME  Path of the settings .m chosen in the plugin figure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   file_name = zef_bst_get_settings_file_name
%   file_name = zef_bst_get_settings_file_name(h_parent)
%
%   Reads figure properties folder_name, settings_subfolder_name, and
%   settings_file_name (set by zef_bst_plugin_start / zef_bst_settings_file)
%   and returns fullfile of those three. Default h_parent is
%   get(gcbo,'Parent') — intended as a GUI callback, not a script API.
%   The file is a .m settings script, not a .mat.
%
%   See also zef_bst_settings_file, zef_bst_plugin_start.

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

folder_name = get(h_parent,'folder_name');
settings_file_name = get(h_parent,'settings_file_name');
settings_subfolder_name = get(h_parent,'settings_subfolder_name');
file_name = fullfile(folder_name, settings_subfolder_name, settings_file_name);

end