function ell_idx = zef_ES_plot_4x1
% --- Zeffiro documentation header ---
% ell_idx — Ell idx.
%
% Purpose:
%   Ell idx.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.inv_synth_source (read)
%   zef.sensors (read)
%
% Calls (project):
%   zef_ES_plot_4x1
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `ell_idx` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

sensors    = evalin('base','zef.sensors(:,1:3)');
source_pos = evalin('base','zef.inv_synth_source(1,1:3)'); % Position
source_ori = evalin('base','zef.inv_synth_source(1,4:6)'); % Orientation

ell_idx = zef_ES_4x1_sensors;
axes(evalin('base','zef.h_axes1'));
hold on
quiver3(source_pos(1), source_pos(2), source_pos(3), source_ori(1),source_ori(2),source_ori(3),20,'g','linewidth',1,'marker','o');
for i = 1:length(sensors)
    if ismember(i,ell_idx(1))
        scatter3(sensors(i,1),sensors(i,2),sensors(i,3),'r','filled');
    elseif ismember(i,ell_idx(2:5))
        scatter3(sensors(i,1),sensors(i,2),sensors(i,3),'b','filled');
     else
        scatter3(sensors(i,1),sensors(i,2),sensors(i,3),'.','k');
    end
end
axis equal
hold off
end
