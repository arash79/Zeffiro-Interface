function [roi_ind_1, roi_ind_2, roi_ind_3] = zef_nse_roi_ind(zef,nse_field)
%ZEF_NSE_ROI_IND  Source indices inside roi_radius of roi_x/y/z (and shell / outer sets).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by plot_graph, mean_velocity_roi, separate_waves_roi. Reads
%   zef.source_positions (not nodes). roi_ind_1 = ball of roi_radius;
%   roi_ind_3 = inner ball of roi_radius/2; roi_ind_2 = spherical shell.
%
%   [in, shell, inner] = zef_nse_roi_ind(zef, nse_field)
%
%   See also zef_nse_plot_graph, zef_nse_apply_roi.
%

roi_ind_1 = find(sqrt(sum((zef.source_positions - repmat([nse_field.roi_x nse_field.roi_y nse_field.roi_z],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius);
roi_ind_2 = setdiff(roi_ind_1, find(sqrt(sum((zef.source_positions - repmat([nse_field.roi_x nse_field.roi_y nse_field.roi_z],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius/2));
roi_ind_3 = find(sqrt(sum((zef.source_positions - repmat([nse_field.roi_x nse_field.roi_y nse_field.roi_z],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius/2);

end
