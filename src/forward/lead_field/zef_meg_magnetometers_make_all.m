% --- Zeffiro documentation header ---
% warning('off'); — Warning('off');.
%
% Purpose:
%   Warning('off');.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Zef fields (observed):
%   zef.h_source_interpolation_on (read)
%   zef.lead_field_type (read, write)
%   zef.n_sources_mod (read, write)
%   zef.source_ind (read, write)
%   zef.source_interpolation_on (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `warning('off');` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

warning('off');
zef.lead_field_type = 2;
zef.source_interpolation_on = 1;
set(zef.h_source_interpolation_on,'value',1);
zef_create_finite_element_mesh;
zef_postprocess_finite_element_mesh;
zef.n_sources_mod = 1;
zef.source_ind = [];
zef_update_fig_details;
zef_meg_magnetometers_lead_field;
zef_source_interpolation;
