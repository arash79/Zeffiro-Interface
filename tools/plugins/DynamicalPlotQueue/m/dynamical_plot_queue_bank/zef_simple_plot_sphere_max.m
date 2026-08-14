function zef_simple_plot_sphere_max(varargin)
%ZEF_SIMPLE_PLOT_SPHERE_MAX  Queue renderer: sphere at max |reconstruction|.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads base zef.reconstruction and zef.source_positions. For a cell
%   reconstruction uses caller f_ind; otherwise the whole vector. Argmax
%   is over sum of squared xyz components per source. Default radius 10,
%   color [1 0 0]. Tag: 'additional: max sphere' on caller h_axes_image.
%
%   zef_simple_plot_sphere_max
%   zef_simple_plot_sphere_max(radius)
%   zef_simple_plot_sphere_max(radius, color)
%
%   See also zef_simple_plot_sphere_min, zef_plot_dpq.

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

%axes(h_axes);

f_ind = evalin('caller','f_ind');
delete(findobj(h_axes,'Tag','additional: max sphere')
);
r = evalin('base','zef.reconstruction');
p = evalin('base','zef.source_positions');
if iscell(r)
    [~,r_ind] = max(sum(reshape(r{f_ind},3,length(r{f_ind}(:))/3).^2));
else
    [~,r_ind] = max(sum(reshape(r,3,length(r(:))/3).^2));
end
h_surf = surf(h_axes,radius_val*X+p(r_ind,1),radius_val*Y+p(r_ind,2),radius_val*Z+p(r_ind,3));
set(h_surf,'edgecolor','none','facecolor',color_val);
set(h_surf,'Tag','additional: max sphere');

end
