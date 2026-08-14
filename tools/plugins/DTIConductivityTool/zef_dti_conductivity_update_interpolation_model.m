function zef = zef_dti_conductivity_update_interpolation_model(zef)
%ZEF_DTI_CONDUCTIVITY_UPDATE_INTERPOLATION_MODEL  Copy interp widgets into zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ValueChangedFcn for interpolation mode and radius. Writes
%   zef.dti_interpolation_mode and zef.dti_interpolation_radius. Used on
%   the next **Apply to Mesh** (zef_dti_tensor_interpolate_mesh_space).
%   nargout==0 → assignin base zef.
%
%   See also zef_dti_conductivity_update_conversion_model.

if nargin == 0
    zef = evalin('base','zef');
end
if isfield(zef,'h_dti_interp_mode') && isvalid(zef.h_dti_interp_mode)
    zef.dti_interpolation_mode = zef.h_dti_interp_mode.Value;
end
if isfield(zef,'h_dti_interp_radius') && isvalid(zef.h_dti_interp_radius)
    zef.dti_interpolation_radius = zef.h_dti_interp_radius.Value;
end
if nargout == 0
    assignin('base','zef',zef);
end

end
