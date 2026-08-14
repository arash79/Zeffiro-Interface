%ZEF_EIT_LEAD_FIELD_ANISOTROPIC  EIT anisotropic lead field (type 9).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Mesh-tool **Run script** row for anisotropic EIT. Sets
%   lead_field_type=9, imaging_method=1 (EEG-style electrodes), deletes the
%   cached original field, process_meshes, attach_sensors_volume,
%   zef_lead_field_matrix (uses zef.sigma(:,3:8)), quantile filter, optional
%   source interpolation. Fill the tensor columns first (DTI tool). Does not
%   create a volume mesh.
%
%   See also zef_eit_lead_field_isotropic, zef_dti_apply_to_sigma.

warning('off');
zef.lead_field_type = 9;
zef.imaging_method = 1;
zef_delete_original_field;
zef_process_meshes;
zef_attach_sensors_volume(zef,zef.sensors);
zef_lead_field_matrix;
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
