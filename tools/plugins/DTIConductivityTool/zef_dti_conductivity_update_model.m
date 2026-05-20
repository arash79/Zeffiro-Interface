%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_MODEL
%
%Syncs zef.dti_conductivity_model from the GUI dropdown.

function zef_dti_conductivity_update_model

zef = evalin('base','zef');
if isfield(zef,'h_dti_model_dropdown') && isvalid(zef.h_dti_model_dropdown)
    zef.dti_conductivity_model = zef.h_dti_model_dropdown.Value;
    assignin('base','zef',zef);
end

end
