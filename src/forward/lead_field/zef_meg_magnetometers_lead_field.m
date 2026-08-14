%ZEF_MEG_MAGNETOMETERS_LEAD_FIELD  MEG magnetometer lead field (type 2); used by make_all.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (reads zef in the base workspace). Sets lead_field_type=2,
%   imaging_method=2, clears source_ind, process_meshes, zef_lead_field_matrix,
%   quantile filter, optional interpolation. Does not attach sensors via
%   zef_attach_sensors_volume (MEG uses zef.sensors columns 1:3 / 4:6 in metres
%   inside the dispatcher). Default INI rows call the _isotropic sibling.
%
%   See also zef_lead_field_meg_fem, zef_meg_magnetometers_lead_field_isotropic.

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
