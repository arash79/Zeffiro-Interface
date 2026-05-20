function zef_bst_edit_project(project_file_name)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_edit_project — Zef bst edit project.
%
% Purpose:
%   Zef bst edit project.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   project_file_name
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_edit_project
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.brainstorm2zef.zef_bst_edit_project(project_file_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if exist(project_file_name,'file')
    zeffiro_interface('start_mode','display','open_project',project_file_name);
end

end
