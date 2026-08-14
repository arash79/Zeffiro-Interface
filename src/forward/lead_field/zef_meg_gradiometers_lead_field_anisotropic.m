%ZEF_MEG_GRADIOMETERS_LEAD_FIELD_ANISOTROPIC  MEG gradiometer anisotropic (type 8).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. lead_field_type=8, imaging_method=3. Same wrap as the isotropic
%   gradiometer script except zef_lead_field_matrix reads sigma(:,3:8).
%   MEG does not call zef_attach_sensors_volume; coil xyz/orientation stay
%   on zef.sensors. Does not create a volume mesh.
%
%   See also zef_lead_field_meg_grad_fem, zef_dti_apply_to_sigma.

warning('off');
zef.lead_field_type = 8;
zef.imaging_method = 3;
zef_delete_original_field;
zef_process_meshes;
zef_lead_field_matrix;
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
