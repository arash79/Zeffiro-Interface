%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_APPLY_BUTTON_CALLBACK
%
%Callback for the "Apply to Mesh" button. Ensures the waitbar is active
%so the user sees live progress, then runs the pipeline and updates the
%GUI on success or shows a clear error on failure.

function zef_dti_conductivity_apply_button_callback()

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
