function [v_mag, v_dir, v_vec] = zef_nse_mean_velocity_roi(zef,nse_field)
%ZEF_NSE_MEAN_VELOCITY_ROI  Mean vessel velocity vector in the ROI from bv_vessels_1/2/3.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by plot_roi (arrow). Averages bv_vessels_* over frames and ROI
%   nodes from zef_nse_roi_ind. Wave separation uses zef_nse_vel_dir
%   instead (the mean_velocity call there is commented out).
%
%   [v_mag, v_dir, v_vec] = zef_nse_mean_velocity_roi(zef, nse_field)
%
%   See also zef_nse_plot_roi, zef_nse_roi_ind.
%

roi_ind = zef_nse_roi_ind(zef,nse_field);
v_1 = 0; 
v_2 = 0; 
v_3 = 0; 

for i = 1 : length(zef.nse_field.bv_vessels_1)
v_1 = v_1 + mean(zef.nse_field.bv_vessels_1{i}(roi_ind));
v_2 = v_2 + mean(zef.nse_field.bv_vessels_2{i}(roi_ind));
v_3 = v_3 + mean(zef.nse_field.bv_vessels_3{i}(roi_ind));
end
v_vec = [v_1 v_2 v_3]./length(zef.nse_field.bv_vessels_1);
v_mag = sqrt(sum(v_vec.^2));
v_dir = v_vec/v_mag;

end
