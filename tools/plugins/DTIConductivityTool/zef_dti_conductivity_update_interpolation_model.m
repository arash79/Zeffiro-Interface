%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_UPDATE_INTERPOLATION_MODEL
%
%Syncs interpolation parameters from GUI to zef. No recomputation;
%parameters are used on next "Apply to Mesh".

function zef = zef_dti_conductivity_update_interpolation_model(zef)
% --- Zeffiro documentation header ---
% zef_dti_conductivity_update_interpolation_model — Zef dti conductivity update interpolation model.
%
% Purpose:
%   Zef dti conductivity update interpolation model.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dti_interpolation_mode (read, write)
%   zef.dti_interpolation_radius (read, write)
%   zef.h_dti_interp_mode (read)
%   zef.h_dti_interp_radius (read)
%
% Calls (project):
%   zef_dti_conductivity_update_interpolation_model
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dti_conductivity_update_interpolation_model(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
