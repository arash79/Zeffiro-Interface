function zef_bst_settings_file
%ZEF_BST_SETTINGS_FILE  uigetfile('*.m') → figure settings_file_name.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_bst_settings_file
%
%   Callback for the plugin "Settings file" button. Parent of gcbo must
%   have folder_name and settings_subfolder_name. Stores the chosen file
%   name (not full path) on the figure and on Tag='settings_file' text.
%
%   See also zef_bst_plugin_start, zef_bst_get_settings_file_name.

h_parent = get(gcbo,'Parent');
h_text_1 = findobj(h_parent.Children,'Tag','settings_file');

folder_name = get(h_parent,'folder_name');
settings_subfolder_name = get(h_parent,'settings_subfolder_name');

% Open file selection dialog
[file_name] = uigetfile('*.m','Select settings file', fullfile(folder_name,settings_subfolder_name));

% Update GUI display and store file name
h_text_1.String = file_name;
set(h_parent,'settings_file_name',file_name);

end
