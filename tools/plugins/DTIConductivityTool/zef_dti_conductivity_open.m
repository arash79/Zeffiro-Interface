%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_OPEN
%
%Plugin entry point for DTI Conductivity Tool.
%Follows standard Zeffiro plugin pattern:
%  1. Create/update GUI window
%  2. Initialize plugin-specific fields
%  3. Update GUI from zef struct
%
%WHY THIS IS NEEDED:
%Provides user-friendly interface for DTI-to-conductivity workflow.
%Without this, users would need to manually call functions and set
%parameters, which is error-prone and not user-friendly.

function zef = zef_dti_conductivity_open(zef)
% --- Zeffiro documentation header ---
% zef_dti_conductivity_open — Zef dti conductivity open.
%
% Purpose:
%   Zef dti conductivity open.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_dti_conductivity_open
%   zef_dti_conductivity_update
%   zef_dti_conductivity_window
%
% Side effects:
%   - base/caller workspace
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dti_conductivity_open(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    try
        zef = evalin('base','zef');
    catch
        error('zef struct not found in base workspace');
    end
end

% Safety check: Ensure zef is valid
if ~isstruct(zef)
    error('zef must be a struct');
end

try
    % Create or update window
    zef = zef_dti_conductivity_window(zef);
    
    % Initialize plugin fields (only if window creation succeeded)
    zef_dti_conductivity_init;
    
    % Update GUI from zef struct
    zef = zef_dti_conductivity_update(zef);
    
    % Update model-specific control visibility
    zef_dti_conductivity_update_model;
catch ME
    warning('Error opening DTI Conductivity Tool: %s', ME.message);
    rethrow(ME);
end

if nargout == 0
    try
        assignin('base','zef',zef);
    catch
        warning('Could not update zef in base workspace');
    end
end

end
