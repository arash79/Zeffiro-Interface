%ZEF_EIT_LEAD_FIELD  EIT isotropic lead field (type 4); used by zef_eit_make_all.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Sets lead_field_type=4, imaging_method=1, attaches sensors, calls
%   zef_lead_field_matrix (writes L, inv_bg_data, eit_ind, eit_count). Default
%   INI rows call zef_eit_lead_field_isotropic.
%
%   See also zef_lead_field_eit_fem, zef_eit_lead_field_isotropic.

warning('off');
zef.lead_field_type = 4;
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
