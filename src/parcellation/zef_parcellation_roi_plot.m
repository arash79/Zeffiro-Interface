function zef_parcellation_roi_plot(zef)
%ZEF_PARCELLATION_ROI_PLOT  Draw translucent ROI spheres on the main axes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Removes prior surfaces tagged 'additional: parcellation roi', then plots
%   one surf sphere per ROI using parcellation_roi_center, radius, and color
%   on zef.h_axes1.
%
%   zef_parcellation_roi_plot(zef)
%
%   See also zef_parcellation_roi_pick_center, zef_update_parcellation.

[s_x,s_y,s_z] = sphere(100);
h_axes1 = zef.h_axes1;
hold(h_axes1,'on');
h_parcellation_roi_sphere = findobj(h_axes1,'Tag','additional: parcellation roi');
delete(h_parcellation_roi_sphere);
for i = 1 : size(zef.parcellation_roi_center,1)
s_x_2 = zef.parcellation_roi_radius(i)*s_x + zef.parcellation_roi_center(i,1);
s_y_2 = zef.parcellation_roi_radius(i)*s_y + zef.parcellation_roi_center(i,2);
s_z_2 = zef.parcellation_roi_radius(i)*s_z + zef.parcellation_roi_center(i,3);
h_plot = surf(h_axes1,s_x_2,s_y_2,s_z_2);
set(h_plot,'facealpha',1,'edgecolor','none','facecolor',zef.parcellation_roi_color(i,:),'tag','additional: parcellation roi');
end

drawnow;
hold(h_axes1,'off');

end
