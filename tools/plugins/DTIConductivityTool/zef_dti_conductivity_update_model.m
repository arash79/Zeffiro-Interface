%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_MODEL
%
%Syncs zef.dti_conductivity_model from the GUI dropdown.
% --- Zeffiro documentation header ---
% function zef_dti_conductivity_update_model — Function zef dti conductivity update model.
%
% Purpose:
%   Function zef dti conductivity update model.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.dti_conductivity_model (read, write)
%   zef.h_dti_model_dropdown (read)
%
% Calls (project):
%   zef_dti_conductivity_update_model
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_dti_conductivity_update_model` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

function zef_dti_conductivity_update_model


zef = evalin('base','zef');
if isfield(zef,'h_dti_model_dropdown') && isvalid(zef.h_dti_model_dropdown)
    zef.dti_conductivity_model = zef.h_dti_model_dropdown.Value;
    assignin('base','zef',zef);
end

end
