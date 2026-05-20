function zef = zef_fix_sensors_get_functions_array_size(zef)
% --- Zeffiro documentation header ---
% zef_fix_sensors_get_functions_array_size — Zef fix sensors get functions array size.
%
% Purpose:
%   Zef fix sensors get functions array size.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.current_sensors (read)
%
% Calls (project):
%   zef_fix_sensors_get_functions_array_size
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_fix_sensors_get_functions_array_size(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


n_sensors = size(zef.([zef.current_sensors '_points']),1);
if isequal(n_sensors,0)
n_sensors = 1;
end

if not(isfield(zef,[zef.current_sensors '_get_functions']))
zef.([zef.current_sensors '_get_functions']) = cell(1,n_sensors);
end
zef.([zef.current_sensors '_get_functions_aux']) = cell(1,n_sensors);
zef.([zef.current_sensors '_get_functions_aux_ind']) = setdiff([1:size(zef.([zef.current_sensors '_get_functions']),2)],find(cellfun(@isempty, zef.([zef.current_sensors '_get_functions']))));
zef.([zef.current_sensors '_get_functions_aux'])(zef.([zef.current_sensors '_get_functions_aux_ind'])) = zef.([zef.current_sensors '_get_functions'])(zef.([zef.current_sensors '_get_functions_aux_ind'])); 
zef.([zef.current_sensors '_get_functions']) = zef.([zef.current_sensors '_get_functions_aux']);

zef = rmfield(zef,[zef.current_sensors '_get_functions_aux']);
zef = rmfield(zef,[zef.current_sensors '_get_functions_aux_ind']);

end
