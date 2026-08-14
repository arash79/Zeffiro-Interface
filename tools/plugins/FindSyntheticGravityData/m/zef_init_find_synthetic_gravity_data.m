%ZEF_INIT_FIND_SYNTHETIC_GRAVITY_DATA  inv_roi_sphere / perturbation / noise onto edits.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called from the gravity window. Does not compute data
%   (Create → zef_synthetic_gravity_data).
%
%   See also zef_update_find_synthetic_gravity_data.

set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef.inv_roi_sphere(:,1)'));
set(zef.h_inv_roi_sphere_2 ,'string',num2str(zef.inv_roi_sphere(:,2)'));
set(zef.h_inv_roi_sphere_3 ,'string',num2str(zef.inv_roi_sphere(:,3)'));
set(zef.h_inv_roi_sphere_4 ,'string',num2str(zef.inv_roi_sphere(:,4)'));
set(zef.h_inv_roi_perturbation ,'string',num2str(zef.inv_roi_perturbation'));
set(zef.h_inv_eit_noise ,'string',num2str(zef.inv_eit_noise));
