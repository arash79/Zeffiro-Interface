function zef = zef_dti_conductivity_open(zef)
%ZEF_DTI_CONDUCTIVITY_OPEN  Open Forward tools → DTI Conductivity Tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Menu callback from profile/multicompartment_head/zeffiro_plugins.ini
%   (label "DTI Conductivity Tool", parent forward_tools). Creates the
%   uifigure "ZEFFIRO Interface: DTI Conductivity Tool", initializes
%   plugin fields, and copies zef DTI state onto the widgets.
%
%   Apply to Mesh (in this window) calls zef_dti_apply_to_sigma in
%   src/forward/dti. This function only opens the UI.
%
%   zef = zef_dti_conductivity_open(zef)
%
%   See also zef_dti_conductivity_window, zef_dti_apply_to_sigma.

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
