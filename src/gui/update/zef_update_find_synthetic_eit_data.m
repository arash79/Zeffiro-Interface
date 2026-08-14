%ZEF_UPDATE_FIND_SYNTHETIC_EIT_DATA  Multi-tools → Generate synthetic EIT data (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Copies h_inv_roi_sphere_1..4 strings into columns of
%   zef.inv_roi_sphere (x, y, z, radius), plus h_inv_roi_perturbation →
%   inv_roi_perturbation and h_inv_eit_noise → inv_eit_noise. Inverse of
%   zef_init_find_synthetic_eit_data. Does not generate data; the dialog
%   run button does that.
%
%   See also zef_init_find_synthetic_eit_data, zef_plot_roi.
zef.inv_roi_sphere(:,1) = str2num(get(zef.h_inv_roi_sphere_1,'string'))';
zef.inv_roi_sphere(:,2) = str2num(get(zef.h_inv_roi_sphere_2,'string'))';
zef.inv_roi_sphere(:,3) = str2num(get(zef.h_inv_roi_sphere_3,'string'))';
zef.inv_roi_sphere(:,4) = str2num(get(zef.h_inv_roi_sphere_4,'string'))';
zef.inv_roi_perturbation = str2num(get(zef.h_inv_roi_perturbation,'string'))';
zef.inv_eit_noise = str2num(get(zef.h_inv_eit_noise,'string'))';
