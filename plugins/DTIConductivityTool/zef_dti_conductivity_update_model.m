function zef_dti_conductivity_update_model
%ZEF_DTI_CONDUCTIVITY_UPDATE_MODEL  Dropdown → zef.dti_conductivity_model.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_dti_conductivity_update_model
%
%   Copies h_dti_model_dropdown.Value (1 volume fraction, 2 effective
%   medium, 3 direct scaling — see zef_dti_conductivity_init).
%
%   See also zef_dti_conductivity_update_compartments, zef_dti_conductivity_init.

zef = evalin('base','zef');
if isfield(zef,'h_dti_model_dropdown') && isvalid(zef.h_dti_model_dropdown)
    zef.dti_conductivity_model = zef.h_dti_model_dropdown.Value;
    assignin('base','zef',zef);
end

end
