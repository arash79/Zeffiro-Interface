function [file_name] = zef_bst_get_project_file_name(h_parent)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_get_project_file_name — Zef bst get project file name.
%
% Purpose:
%   Zef bst get project file name.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   h_parent
%
% Outputs:
%   file_name
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_get_project_file_name
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[file_name] = utilities.brainstorm2zef.zef_bst_get_project_file_name(h_parent)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
