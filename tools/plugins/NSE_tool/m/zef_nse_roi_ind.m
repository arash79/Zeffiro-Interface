function [roi_ind_1, roi_ind_2, roi_ind_3] = zef_nse_roi_ind(zef,nse_field)
% --- Zeffiro documentation header ---
% zef_nse_roi_ind — Zef nse roi ind.
%
% Purpose:
%   Zef nse roi ind.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   nse_field
%
% Outputs:
%   roi_ind_1
%   roi_ind_2
%   roi_ind_3
%
% Zef fields (observed):
%   zef.source_positions (read)
%
% Calls (project):
%   zef_nse_roi_ind
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[roi_ind_1, roi_ind_2, roi_ind_3]] = zef_nse_roi_ind(zef, nse_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header


roi_ind_1 = find(sqrt(sum((zef.source_positions - repmat([nse_field.roi_x nse_field.roi_y nse_field.roi_z],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius);
roi_ind_2 = setdiff(roi_ind_1, find(sqrt(sum((zef.source_positions - repmat([nse_field.roi_x nse_field.roi_y nse_field.roi_z],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius/2));
roi_ind_3 = find(sqrt(sum((zef.source_positions - repmat([nse_field.roi_x nse_field.roi_y nse_field.roi_z],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius/2);

end
