function zef = zef_eeg_lead_field_anisotropic(zef)
%ZEF_EEG_LEAD_FIELD_ANISOTROPIC  EEG anisotropic lead field (type 6, sigma(:,3:8)).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Mesh-tool INI Script for "EEG lead field with anisotropic electrical
%   conductivity". Same pipeline as the isotropic wrapper except
%   lead_field_type=6 so zef_lead_field_matrix passes zef.sigma(:,3:8) into
%   the EEG FEM. Fill those columns first (DTI Conductivity Tool /
%   zef_dti_apply_to_sigma, or zef_nii_conductivity_to_sigma). Tensors must
%   be symmetric positive definite per tetrahedron.
%
%   zef = zef_eeg_lead_field_anisotropic(zef)
%
%   See also zef_lead_field_matrix, zef_dti_apply_to_sigma, zef_eeg_lead_field_isotropic.

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
