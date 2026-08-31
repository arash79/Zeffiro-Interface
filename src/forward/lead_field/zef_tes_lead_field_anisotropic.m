function zef = zef_tes_lead_field_anisotropic(zef)
%ZEF_TES_LEAD_FIELD_ANISOTROPIC  TES / tES anisotropic lead field (type 10).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Mesh-tool INI Script for anisotropic tES. lead_field_type=10 passes
%   zef.sigma(:,3:8) into zef_lead_field_tes_fem. Same wrapping steps as
%   zef_tes_lead_field_isotropic.
%
%   zef = zef_tes_lead_field_anisotropic(zef)
%
%   See also zef_lead_field_tes_fem, zef_dti_apply_to_sigma, zef_tes_lead_field_isotropic.

if nargin == 0
    zef = evalin('base','zef');
end

warning('off');
zef.lead_field_type = 10;
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
