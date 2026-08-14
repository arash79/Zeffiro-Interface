%ZEF_MEG_MAGNETOMETERS_LEAD_FIELD_ANISOTROPIC  MEG magnetometer anisotropic (type 7).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. lead_field_type=7, imaging_method=2. Tensor columns sigma(:,3:8).
%   Same wrap as zef_meg_magnetometers_lead_field_isotropic otherwise.
%
%   See also zef_lead_field_meg_fem, zef_dti_apply_to_sigma.

warning('off');
zef.lead_field_type = 7;
zef.imaging_method = 2;
zef.source_ind = [];
zef = zef_process_meshes(zef);
zef = zef_lead_field_matrix(zef);
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
