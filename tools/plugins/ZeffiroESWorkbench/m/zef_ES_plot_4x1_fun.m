function ell_idx = zef_ES_plot_4x1_fun
%ZEF_ES_PLOT_4X1_FUN  Same 4×1 overlay as zef_ES_plot_4x1 (alternate entry).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not bound in zef_ES_optimization_window. Duplicate of zef_ES_plot_4x1.
%
%   ell_idx = zef_ES_plot_4x1_fun
%
%   See also zef_ES_plot_4x1, zef_ES_4x1_sensors.
%

sensors    = evalin('base','zef.sensors(:,1:3)');
source_pos = evalin('base','zef.inv_synth_source(1,1:3)'); % Position
source_ori = evalin('base','zef.inv_synth_source(1,4:6)'); % Orientation

ell_idx = zef_ES_4x1_sensors;
axes(evalin('base','zef.h_axes1')
);
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
