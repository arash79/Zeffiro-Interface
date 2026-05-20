%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_APPLY_BUTTON_CALLBACK
%
%Callback for the "Apply to Mesh" button. Ensures the waitbar is active
%so the user sees live progress, then runs the pipeline and updates the
%GUI on success or shows a clear error on failure.

function zef_dti_conductivity_apply_button_callback()
% --- Zeffiro documentation header ---
% zef_dti_conductivity_apply_button_callback — GUI callback for dti_conductivity_apply_button actions.
%
% Purpose:
%   GUI callback for dti_conductivity_apply_button actions.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.dti_conductivity_metadata (read)
%   zef.h_dti_status_text (read)
%   zef.use_waitbar (read, write)
%
% Calls (project):
%   zef_dti_apply_to_sigma
%   zef_dti_conductivity_apply_button_callback
%   zef_dti_conductivity_update
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef_dti_conductivity_apply_button_callback` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header


zef = evalin('base', 'zef');

% Ensure use_waitbar is on so the pipeline shows progress from the GUI.
zef.use_waitbar = true;

% Immediate visual feedback in the status bar.
try
    if isfield(zef, 'h_dti_status_text') && isvalid(zef.h_dti_status_text)
        zef.h_dti_status_text.Text = 'Applying DTI conductivity to mesh...';
        zef.h_dti_status_text.FontColor = [0 0 1];
        drawnow;
    end
catch
end

t_start = tic;

try
    zef = zef_dti_apply_to_sigma(zef);
    elapsed = toc(t_start);
    assignin('base', 'zef', zef);
    zef_dti_conductivity_update(zef);

    % Show elapsed time in status bar
    try
        if isfield(zef, 'h_dti_status_text') && isvalid(zef.h_dti_status_text)
            if isfield(zef,'dti_conductivity_metadata') && isfield(zef.dti_conductivity_metadata,'n_tetrahedra_updated')
                n_up = zef.dti_conductivity_metadata.n_tetrahedra_updated;
                zef.h_dti_status_text.Text = sprintf('Applied to %d tetrahedra in %.1f s', n_up, elapsed);
            else
                zef.h_dti_status_text.Text = sprintf('DTI conductivity applied (%.1f s)', elapsed);
            end
            zef.h_dti_status_text.FontColor = [0 0.7 0];
        end
    catch
    end
catch ME
    try assignin('base', 'zef', zef); catch, end
    try
        if isfield(zef, 'h_dti_status_text') && isvalid(zef.h_dti_status_text)
            zef.h_dti_status_text.Text = sprintf('Error: %s', ME.message);
            zef.h_dti_status_text.FontColor = [1 0 0];
        end
    catch
    end
    errordlg(sprintf('Apply to mesh failed:\n\n%s', ME.message), 'DTI Conductivity Tool', 'modal');
end

end
