%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_INTERPOLATION_MODEL
%
%Syncs interpolation parameters from GUI to zef. No recomputation;
%parameters are used on next "Apply to Mesh".

function zef = zef_dti_conductivity_update_interpolation_model(zef)

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
