%ZEF_UPDATE_FIND_SYNTHETIC_GRAVITY_DATA  Gravity ROI widgets → zef.inv_roi_sphere / noise.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called before compute/plot. Four sphere columns,
%   inv_roi_perturbation, inv_eit_noise. Does not write measurements.
%
%   See also zef_synthetic_gravity_data, zef_plot_gravity_roi.

zef.inv_roi_sphere(:,1) = str2num(get(zef.h_inv_roi_sphere_1,'string'))';
zef.inv_roi_sphere(:,2) = str2num(get(zef.h_inv_roi_sphere_2,'string'))';
zef.inv_roi_sphere(:,3) = str2num(get(zef.h_inv_roi_sphere_3,'string'))';
zef.inv_roi_sphere(:,4) = str2num(get(zef.h_inv_roi_sphere_4,'string'))';
zef.inv_roi_perturbation = str2num(get(zef.h_inv_roi_perturbation,'string'))';
zef.inv_eit_noise = str2num(get(zef.h_inv_eit_noise,'string'))';
