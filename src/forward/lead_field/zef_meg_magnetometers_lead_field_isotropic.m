% --- Zeffiro documentation header ---
% warning('off'); — Warning('off');.
%
% Purpose:
%   Warning('off');.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Zef fields (observed):
%   zef.L (read)
%   zef.imaging_method (read, write)
%   zef.lead_field_filter_quantile (read)
%   zef.lead_field_type (read, write)
%   zef.source_directions (read)
%   zef.source_ind (read, write)
%   zef.source_interpolation_on (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_lead_field_filter
%   zef_lead_field_matrix
%   zef_process_meshes
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
zef.imaging_method = 2;
zef.source_ind = [];
zef = zef_process_meshes(zef);
zef = zef_lead_field_matrix(zef);
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
