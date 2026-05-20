%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_COMPARTMENTS
%
%Syncs zef.dti_apply_to_compartments from the GUI listbox selection.
% --- Zeffiro documentation header ---
% function zef_dti_conductivity_update_compartments — Function zef dti conductivity update compartments.
%
% Purpose:
%   Function zef dti conductivity update compartments.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.dti_apply_to_compartments (read, write)
%   zef.h_dti_compartments (read)
%
% Calls (project):
%   zef_dti_conductivity_update_compartments
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_dti_conductivity_update_compartments` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
