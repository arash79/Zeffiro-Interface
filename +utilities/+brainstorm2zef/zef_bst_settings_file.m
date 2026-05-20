% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.function zef_bst_settings_file — Function zef bst settings file.
%
% Purpose:
%   Function zef bst settings file.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_settings_file
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `utilities.brainstorm2zef.function zef_bst_settings_file` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_bst_settings_file

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
