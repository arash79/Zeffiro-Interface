function zef = zef_eeg_lead_field(zef)



%ZEF_EEG_LEAD_FIELD  EEG isotropic lead field (type 1); used by zef_eeg_make_all.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sets lead_field_type=1, imaging_method=1, deletes any cached original
%   field, re-processes surfaces, attaches sensors, calls zef_lead_field_matrix,
%   quantile-filters L, and interpolates if source_interpolation_on.
%   Does not create a volume mesh. Default Mesh-tool INI rows call
%   zef_eeg_lead_field_isotropic instead (same type, same steps).
%
%   zef = zef_eeg_lead_field(zef)
%
%   Input / output
%     zef  - session struct. If omitted, read from base; if nargout is 0,
%            assigned back to base.
%
%   Fields written
%     L [n_sensors × n_source_columns], source_positions [n × 3],
%     source_directions, sensors_attached_volume.
%
%   See also zef_lead_field_matrix, zef_eeg_lead_field_isotropic, zef_eeg_make_all.

if nargin == 0
    zef = evalin('base','zef');
end

warning('off');
zef.lead_field_type = 1;
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
