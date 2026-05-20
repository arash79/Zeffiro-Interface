function zef_bst_settings_file
%ZEF_BST_SETTINGS_FILE Opens file dialog to select a settings file.
%
% This callback function opens a file selection dialog allowing the user
% to choose a settings file from the settings subfolder. The selected
% file name is then displayed in the GUI and stored in the figure properties.
%
% See also: ZEF_BST_PLUGIN_START

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