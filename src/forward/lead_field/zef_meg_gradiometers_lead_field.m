%ZEF_MEG_GRADIOMETERS_LEAD_FIELD  MEG gradiometer lead field (type 3); used by make_all.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Sets lead_field_type=3, imaging_method=3, then process_meshes,
%   zef_lead_field_matrix (zef_lead_field_meg_grad_fem), filter, interpolation.
%   Gradiometers use two coil orientations when sensors have 9 columns.
%
%   See also zef_lead_field_meg_grad_fem, zef_meg_gradiometers_lead_field_isotropic.

warning('off');
zef.lead_field_type = 3;
zef.imaging_method = 3;
zef_delete_original_field;
zef_process_meshes;
zef_lead_field_matrix;
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
