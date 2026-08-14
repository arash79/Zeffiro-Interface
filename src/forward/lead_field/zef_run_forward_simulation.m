%ZEF_RUN_FORWARD_SIMULATION  Mesh-tool "Run script": eval the selected table Script cell.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Bound to Mesh tool button h_run_forward_simulation
%   ("Run script"). Evaluates
%
%     zef.h_forward_simulation_table.Data{zef.forward_simulation_selected(1), 3}
%
%   that is, column 3 (Script) of the currently selected row. The table is
%   loaded from profile/<profile_name>/zeffiro_forward_simulation.ini
%   (Name, Description, Script). Default head profiles call wrappers such as
%   zef_eeg_lead_field_isotropic; asteroid profiles call gravity scripts.
%
%   On error, zef_delete_waitbar is attempted so a failed FEM waitbar does not
%   linger, then the original exception is rethrown.
%
%   Side effects: whatever the Script cell does (typically writes zef.L in the
%   base workspace). This file does not set lead_field_type itself.
%
%   See also zef_mesh_tool, zef_lead_field_matrix, zef_eeg_lead_field_isotropic.

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
