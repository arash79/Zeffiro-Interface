%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_COMPARTMENTS
%
%Syncs zef.dti_apply_to_compartments from the GUI listbox selection.

function zef_dti_conductivity_update_compartments

zef = evalin('base','zef');
if isfield(zef,'h_dti_compartments') && isvalid(zef.h_dti_compartments)
    val = zef.h_dti_compartments.Value;
    if iscell(val)
        zef.dti_apply_to_compartments = val;
    elseif ischar(val) || isstring(val)
        zef.dti_apply_to_compartments = {char(val)};
    else
        zef.dti_apply_to_compartments = {};
    end
    assignin('base','zef',zef);
end

end
