%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef — Set(zef.h inv roi sphere 1 ,'string',num2str(zef.
%
% Purpose:
%   Set(zef.h inv roi sphere 1 ,'string',num2str(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_inv_eit_noise (read)
%   zef.h_inv_roi_perturbation (read)
%   zef.h_inv_roi_sphere_2 (read)
%   zef.h_inv_roi_sphere_3 (read)
%   zef.h_inv_roi_sphere_4 (read)
%   zef.inv_eit_noise (read)
%   zef.inv_roi_perturbation (read)
%   zef.inv_roi_sphere (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



set(zef.h_inv_roi_sphere_1 ,'string',num2str(zef.inv_roi_sphere(:,1)'));
set(zef.h_inv_roi_sphere_2 ,'string',num2str(zef.inv_roi_sphere(:,2)'));
set(zef.h_inv_roi_sphere_3 ,'string',num2str(zef.inv_roi_sphere(:,3)'));
set(zef.h_inv_roi_sphere_4 ,'string',num2str(zef.inv_roi_sphere(:,4)'));
set(zef.h_inv_roi_perturbation ,'string',num2str(zef.inv_roi_perturbation'));
set(zef.h_inv_eit_noise ,'string',num2str(zef.inv_eit_noise));
