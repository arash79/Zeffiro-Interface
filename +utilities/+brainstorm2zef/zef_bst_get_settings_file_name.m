function [file_name] = zef_bst_get_settings_file_name(h_parent)
%ZEF_BST_GET_SETTINGS_FILE_NAME Constructs the settings file path from GUI settings.
%
% This function generates the full path to the settings file based on
% the configured folder structure and selected settings file name.
%
% Inputs:
%   h_parent - Handle to parent figure containing folder and file name properties
%
% Outputs:
%   file_name - Full path to the settings file (.m)
%
% See also: ZEF_BST_GET_PROJECT_FILE_NAME

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

folder_name = get(h_parent,'folder_name');
settings_file_name = get(h_parent,'settings_file_name');
settings_subfolder_name = get(h_parent,'settings_subfolder_name');
file_name = fullfile(folder_name, settings_subfolder_name, settings_file_name);

end