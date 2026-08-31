function zef = zef_eeg_lead_field_isotropic(zef)
%ZEF_EEG_LEAD_FIELD_ISOTROPIC  EEG isotropic lead field (type 1); default Mesh-tool Script.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   This is the Script cell in profile/multicompartment_head/zeffiro_forward_simulation.ini
%   ("EEG lead field with isotropic electrical conductivity"). Mesh tool →
%   Run script evals this name. Requires an existing FEM mesh and zef.sensors;
%   uses zef.sigma(:,1). zef_eeg_lead_field is an alias of this function.
%
%   zef = zef_eeg_lead_field_isotropic(zef)
%
%   Input / output
%     zef  - session struct. If omitted, read from base; if nargout is 0,
%            assigned back to base.
%
%   See also zef_lead_field_matrix, zef_run_forward_simulation, zef_eeg_lead_field_anisotropic.

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
