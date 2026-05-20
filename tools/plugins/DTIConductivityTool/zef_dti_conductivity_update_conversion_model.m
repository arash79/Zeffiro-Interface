%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_CONVERSION_MODEL
%
%Syncs conversion model parameters from GUI to zef. No recomputation;
%parameters are used on next "Apply to Mesh".

function zef = zef_dti_conductivity_update_conversion_model(zef)

if nargin == 0
    zef = evalin('base','zef');
end
if isfield(zef,'h_dti_volume_fraction') && isvalid(zef.h_dti_volume_fraction)
    zef.dti_volume_fraction = zef.h_dti_volume_fraction.Value;
end
if isfield(zef,'h_dti_extra_conductivity') && isvalid(zef.h_dti_extra_conductivity)
    zef.dti_extra_conductivity = zef.h_dti_extra_conductivity.Value;
end
if isfield(zef,'h_dti_intra_conductivity') && isvalid(zef.h_dti_intra_conductivity)
    zef.dti_intra_conductivity = zef.h_dti_intra_conductivity.Value;
end
if isfield(zef,'h_dti_conductivity_scale') && isvalid(zef.h_dti_conductivity_scale)
    zef.dti_conductivity_scale = zef.h_dti_conductivity_scale.Value;
end
if isfield(zef,'h_dti_anisotropy_threshold') && isvalid(zef.h_dti_anisotropy_threshold)
    zef.dti_anisotropy_threshold = zef.h_dti_anisotropy_threshold.Value;
end
if isfield(zef,'h_dti_model_dropdown') && isvalid(zef.h_dti_model_dropdown)
    zef.dti_conductivity_model = zef.h_dti_model_dropdown.Value;
end
if nargout == 0
    assignin('base','zef',zef);
end

end
