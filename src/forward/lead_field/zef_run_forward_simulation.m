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
