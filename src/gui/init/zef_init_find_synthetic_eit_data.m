%ZEF_INIT_FIND_SYNTHETIC_EIT_DATA  Fill synthetic-EIT ROI widgets from zef (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Inverse of zef_update_find_synthetic_eit_data: writes
%   inv_roi_sphere columns to h_inv_roi_sphere_1..4 and perturbation /
%   noise to their edits. Multi-tools → Generate synthetic EIT data.
%
%   See also zef_update_find_synthetic_eit_data, zef_plot_roi.
set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef.inv_roi_sphere(:,1)'));
set(zef.h_inv_roi_sphere_2 ,'string',num2str(zef.inv_roi_sphere(:,2)'));
set(zef.h_inv_roi_sphere_3 ,'string',num2str(zef.inv_roi_sphere(:,3)'));
set(zef.h_inv_roi_sphere_4 ,'string',num2str(zef.inv_roi_sphere(:,4)'));
set(zef.h_inv_roi_perturbation ,'string',num2str(zef.inv_roi_perturbation'));
set(zef.h_inv_eit_noise ,'string',num2str(zef.inv_eit_noise));
