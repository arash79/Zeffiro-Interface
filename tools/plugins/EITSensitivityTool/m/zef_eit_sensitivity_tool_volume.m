function tilavuus_vec = zef_eit_sensitivity_tool_volume
% --- Zeffiro documentation header ---
% tilavuus_vec — Tilavuus vec.
%
% Purpose:
%   Tilavuus vec.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.brain_ind (read)
%   zef.eit_count (read)
%   zef.eit_ind (read)
%   zef.nodes (read)
%   zef.tetra (read)
%
% Calls (project):
%   zef_eit_sensitivity_tool_volume
%   zef_tetra_volume
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `tilavuus_vec` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header


nodes = evalin('base','zef.nodes');
tetrahedra = evalin('base','zef.tetra');

tilavuus = zef_tetra_volume(nodes, tetrahedra, true);
tilavuus = tilavuus(:);
tilavuus_vec = accumarray(evalin('base','zef.eit_ind'),tilavuus(evalin('base','zef.brain_ind')),[size(evalin('base','zef.eit_count'),1) 1]);
