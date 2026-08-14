function zef_nse_plot_sphere(h_axes,nse_field)
%ZEF_NSE_PLOT_SPHERE  Plot sphere button: grey spheres at nse_field.sphere_* on the current axes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_plot_sphere (called with no args → gca and
%   zef.nse_field). Tag additional:nse_sphere; previous spheres are deleted.
%
%   zef_nse_plot_sphere()
%   zef_nse_plot_sphere(h_axes, nse_field)
%
%   See also zef_nse_apply_source, zef_nse_plot_roi.
%

if nargin == 0
    h_axes = evalin('base','gca');
    nse_field = evalin('base','zef.nse_field');
end

axes(h_axes);
hold_val = ishold(h_axes);
if not(hold_val)
    hold(h_axes,'on');
end

h_sphere = findobj(h_axes.Children,'Tag','additional:nse_sphere');
delete(h_sphere);

[X,Y,Z]  = sphere(100);

for i = 1 : length(nse_field.sphere_radius)
h_surf = surf(nse_field.sphere_radius(i)*X + nse_field.sphere_x(i), nse_field.sphere_radius(i)*Y + nse_field.sphere_y(i), nse_field.sphere_radius(i)*Z + nse_field.sphere_z(i)); 

set(h_surf,'FaceColor',[0.5 0.5 0.5]);
set(h_surf,'EdgeColor','none');
set(h_surf,'FaceAlpha',1);
set(h_surf,'Tag','additional:nse_sphere');

end

if not(hold_val)
hold(h_axes,'off');
end

end
