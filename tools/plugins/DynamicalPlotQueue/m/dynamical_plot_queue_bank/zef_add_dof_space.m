function zef_add_dof_space
%ZEF_ADD_DOF_SPACE  Queue renderer: scatter3 of zef.source_positions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Draws the source DOF cloud (not a reconstruction) on base zef.h_axes1.
%   Bank List item; zef_plot_dpq evalin-calls this name. Uses h_axes1,
%   not the caller h_axes_image most other overlays use.
%
%   zef_add_dof_space
%
%   See also zef_plot_dpq, zef_simple_plot_sphere_max.

h_axes = evalin('base','zef.h_axes1');
%axes(h_axes);
hold on
source_positions = evalin('base','zef.source_positions');
scatter3(source_positions(:,1),source_positions(:,2),source_positions(:,3),'filled')

end
