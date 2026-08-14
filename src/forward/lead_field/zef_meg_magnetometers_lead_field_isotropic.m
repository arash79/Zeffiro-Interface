%ZEF_MEG_MAGNETOMETERS_LEAD_FIELD_ISOTROPIC  MEG magnetometer isotropic (type 2); Mesh-tool Script.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Default INI row "MEG lead field with isotropic electrical
%   conductivity, magnetometers". Same body as zef_meg_magnetometers_lead_field.
%   Sensors: positions(:,1:3) mm, orientations(:,4:6).
%
%   See also zef_lead_field_matrix, zef_run_forward_simulation.

warning('off');
zef.lead_field_type = 2;
zef.imaging_method = 2;
zef.source_ind = [];
zef = zef_process_meshes(zef);
zef = zef_lead_field_matrix(zef);
[zef.L,zef.source_positions,zef.source_directions] = zef_lead_field_filter(zef.L,zef.source_positions,zef.source_directions,zef.lead_field_filter_quantile);
if zef.source_interpolation_on
    zef_source_interpolation;
end
warning('on');
