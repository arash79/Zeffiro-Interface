function [v_mag, v_dir, v_vec] = zef_nse_mean_velocity_roi(zef,nse_field)
% --- Zeffiro documentation header ---
% zef_nse_mean_velocity_roi — Zef nse mean velocity roi.
%
% Purpose:
%   Zef nse mean velocity roi.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   nse_field
%
% Outputs:
%   v_mag
%   v_dir
%   v_vec
%
% Zef fields (observed):
%   zef.nse_field (read)
%
% Calls (project):
%   zef_nse_mean_velocity_roi
%   zef_nse_roi_ind
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[v_mag, v_dir, v_vec]] = zef_nse_mean_velocity_roi(zef, nse_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
