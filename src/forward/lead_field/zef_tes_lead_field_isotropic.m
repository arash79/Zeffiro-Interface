function zef = zef_tes_lead_field_isotropic(zef)
%ZEF_TES_LEAD_FIELD_ISOTROPIC  TES / tES isotropic lead field (type 5); Mesh-tool Script.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Default INI Script "tES lead field with isotropic electrical conductivity".
%   zef_tes_lead_field is an alias of this function. Requires mesh + electrodes; uses
%   zef.sigma(:,1). Writes zef.L and zef.S.
%
%   zef = zef_tes_lead_field_isotropic(zef)
%
%   See also zef_lead_field_matrix, zef_tes_lead_field_anisotropic, zef_run_forward_simulation.

if nargin == 0
    zef = evalin('base','zef');
end

warning('off');
zef.lead_field_type = 5;
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
