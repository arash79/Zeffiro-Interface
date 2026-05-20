% --- Zeffiro documentation header ---
% function zef_add_dof_space — Function zef add dof space.
%
% Purpose:
%   Function zef add dof space.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_add_dof_space
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_add_dof_space` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_add_dof_space

h_axes = evalin('base','zef.h_axes1');
%axes(h_axes);
hold on
source_positions = evalin('base','zef.source_positions');
scatter3(source_positions(:,1),source_positions(:,2),source_positions(:,3),'filled')

end
