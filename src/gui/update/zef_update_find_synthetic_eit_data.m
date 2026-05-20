%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.inv_roi_sphere(:,1) = str2num(get(zef — Zef.inv roi sphere(:,1) = str2num(get(zef.
%
% Purpose:
%   Zef.inv roi sphere(:,1) = str2num(get(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_inv_eit_noise (read)
%   zef.h_inv_roi_perturbation (read)
%   zef.h_inv_roi_sphere_2 (read)
%   zef.h_inv_roi_sphere_3 (read)
%   zef.h_inv_roi_sphere_4 (read)
%   zef.inv_eit_noise (read, write)
%   zef.inv_roi_perturbation (read, write)
%   zef.inv_roi_sphere (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.inv_roi_sphere(:,1) = str2num(get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.inv_roi_sphere(:,1) = str2num(get(zef.h_inv_roi_sphere_1,'string'))';
zef.inv_roi_sphere(:,2) = str2num(get(zef.h_inv_roi_sphere_2,'string'))';
zef.inv_roi_sphere(:,3) = str2num(get(zef.h_inv_roi_sphere_3,'string'))';
zef.inv_roi_sphere(:,4) = str2num(get(zef.h_inv_roi_sphere_4,'string'))';
zef.inv_roi_perturbation = str2num(get(zef.h_inv_roi_perturbation,'string'))';
zef.inv_eit_noise = str2num(get(zef.h_inv_eit_noise,'string'))';
