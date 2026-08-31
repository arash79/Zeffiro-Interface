function zef_simple_plot_sphere_min(varargin)
%ZEF_SIMPLE_PLOT_SPHERE_MIN  Queue renderer: sphere at min |reconstruction|.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same zef.reconstruction / source_positions / f_ind path as
%   zef_simple_plot_sphere_max, with min instead of max. Default radius
%   10, color [1 0 0]. Deletes and retags 'additional: max sphere' (same
%   tag as the max renderer).
%
%   zef_simple_plot_sphere_min
%   zef_simple_plot_sphere_min(radius)
%   zef_simple_plot_sphere_min(radius, color)
%
%   See also zef_simple_plot_sphere_max.

if not(isempty(varargin))
    radius_val = varargin{1};
    if length(varargin) > 1
        color_val = varargin{2};
    else
        color_val = [1 0 0];
    end
else
    radius_val = 10;
    color_val = [1 0 0];
end

[X,Y,Z] = sphere(100);
h_axes = evalin('caller','h_axes_image');
hold on;

f_ind = evalin('caller','f_ind');
delete(findobj(h_axes,'Tag','additional: max sphere'));
r = evalin('base','zef.reconstruction');
p = evalin('base','zef.source_positions');
if iscell(r)
    [~,r_ind] = min(sum(reshape(r{f_ind},3,length(r{f_ind}(:))/3).^2));
else
    [~,r_ind] = min(sum(reshape(r,3,length(r(:))/3).^2));
end
h_surf = surf(h_axes,radius_val*X+p(r_ind,1),radius_val*Y+p(r_ind,2),radius_val*Z+p(r_ind,3));
set(h_surf,'edgecolor','none','facecolor',color_val);
set(h_surf,'Tag','additional: max sphere');

end
