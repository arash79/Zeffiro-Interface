function zef = zef_eeg_lead_field_anisotropic(zef)
% --- Zeffiro documentation header ---
% zef_eeg_lead_field_anisotropic — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.L (read)
%   zef.imaging_method (read, write)
%   zef.lead_field_filter_quantile (read)
%   zef.lead_field_type (read, write)
%   zef.sensors (read)
%   zef.sensors_attached_volume (read, write)
%   zef.source_directions (read)
%   zef.source_interpolation_on (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_attach_sensors_volume
%   zef_eeg_lead_field_anisotropic
%   zef_lead_field_filter
%   zef_lead_field_matrix
%   zef_process_meshes
%   zef_source_interpolation
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_eeg_lead_field_anisotropic(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

warning('off');
zef.lead_field_type = 6;
zef.imaging_method = 1;
zef_delete_original_field;
zef = zef_process_meshes(zef);
zef.sensors_attached_volume = zef_attach_sensors_volume(zef,zef.sensors);
zef = zef_lead_field_matrix(zef);
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef = zef_source_interpolation(zef);
end
warning('on');

if nargout == 0
    assignin('base','zef',zef);
end

end
