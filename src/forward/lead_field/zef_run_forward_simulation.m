% --- Zeffiro documentation header ---
% try — Try.
%
% Purpose:
%   Try.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Zef fields (observed):
%   zef.forward_simulation_selected (read)
%   zef.h_forward_simulation_table (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%   - waitbar progress UI
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `try` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

try
    eval(zef.h_forward_simulation_table.Data{zef.forward_simulation_selected(1),3});
catch ME
    % Close any open waitbar so an error does not leave a dangling window
    % that can cause the GUI or MATLAB to crash when it is redrawn or updated.
    try
        zef_delete_waitbar;
    catch
        % Ignore waitbar cleanup errors
    end
    rethrow(ME);
end
