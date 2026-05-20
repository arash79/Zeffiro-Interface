function [file_name] = zef_bst_get_project_file_name(h_parent)
%ZEF_BST_GET_PROJECT_FILE_NAME Constructs the project file path from GUI settings.
%
% This function generates the full path to the Zeffiro project file based on
% the settings file name and configured folder structure.
%
% Inputs:
%   h_parent - Handle to parent figure containing folder and file name properties
%
% Outputs:
%   file_name - Full path to the project file (.mat)
%
% See also: ZEF_BST_GET_SETTINGS_FILE_NAME

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