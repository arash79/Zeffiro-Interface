%ZEF_MEG_GRADIOMETERS_LEAD_FIELD_ISOTROPIC  MEG gradiometer isotropic (type 3); Mesh-tool Script.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Default INI row for gradiometers with isotropic conductivity.
%
%   See also zef_lead_field_matrix, zef_run_forward_simulation.

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
