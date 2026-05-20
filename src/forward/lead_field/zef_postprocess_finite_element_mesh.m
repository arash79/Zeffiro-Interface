% --- Zeffiro documentation header ---
% [zef]=zef_postprocess_fem_mesh(zef);zef=zef_update_fig_details(zef); — [zef]=zef postprocess fem mesh(zef);zef=zef update fig details(zef);.
%
% Purpose:
%   [zef]=zef postprocess fem mesh(zef);zef=zef update fig details(zef);.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef]=zef_postprocess_fem_mesh(zef);zef=zef_update_fig_details(zef);` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef]=zef_postprocess_fem_mesh(zef);zef=zef_update_fig_details(zef);
