function zef_dti_conductivity_update_compartments
%ZEF_DTI_CONDUCTIVITY_UPDATE_COMPARTMENTS  Listbox → zef.dti_apply_to_compartments.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ValueChangedFcn of the DTI tool **Apply to compartments** listbox
%   (zef.h_dti_compartments), wired in zef_dti_conductivity_window.
%   zef_dti_apply_to_sigma later restricts the tensor write to those
%   compartment names. Reads/writes base-workspace zef (not a zef
%   argument). Missing or invalid widget: no-op.
%
%   Value may be a cell of names (multi-select), a char/string (one
%   name), or anything else → {}.
%
%   See also zef_dti_conductivity_window, zef_dti_apply_to_sigma.

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
