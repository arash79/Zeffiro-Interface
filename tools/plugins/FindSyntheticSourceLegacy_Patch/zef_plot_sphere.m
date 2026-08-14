function h_surf = zef_plot_sphere(position,radius,color)
%ZEF_PLOT_SPHERE  surf a sphere at position with given radius and color.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   h_surf = zef_plot_sphere(position, radius, color)
%
%   Called from zef_plot_source_patch for ball ROIs. Uses gca. No zef I/O.
%
%   See also zef_plot_ellipsoid.

h_axes = gca;
hold_state = ishold(h_axes);

if not(hold_state)
    hold on;
end

[X,Y,Z] = sphere;
X = X*radius;
Y = Y*radius;
Z = Z*radius;
h_surf = surf(h_axes,X+position(1),Y+position(2),Z+position(3));
set(h_surf,'edgecolor','none','facecolor',color,'facealpha','0.5');

if not(hold_state)
    hold off;
end

end
