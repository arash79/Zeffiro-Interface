function zef_plot_dof_space(void)
%ZEF_PLOT_DOF_SPACE  scatter3 of zef.source_positions on Figure-tool axes1.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Mesh visualization **Plot graph** item (discovered next to zef_histogram).
%   Dummy argument void unused. evalin base zef; hold on (does not cla).
%   Positions are whatever unit zef.source_positions currently stores
%   (lead-field interpolation may have converted them).
%
%   zef_plot_dof_space(_)

h_axes = evalin('base','zef.h_axes1');
axes(h_axes)
;
hold on
source_positions = evalin('base','zef.source_positions');
scatter3(source_positions(:,1),source_positions(:,2),source_positions(:,3),'filled')

end
