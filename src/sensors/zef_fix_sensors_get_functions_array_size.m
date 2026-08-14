function zef = zef_fix_sensors_get_functions_array_size(zef)
%ZEF_FIX_SENSORS_GET_FUNCTIONS_ARRAY_SIZE  Resize sensor get_functions cell to match sensor count.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sets zef.<current_sensors>_get_functions to length n_sensors (minimum 1),
%   preserving non-empty entries and dropping empty trailing cells.
%
%   zef = zef_fix_sensors_get_functions_array_size(zef)
%
%   Input
%     zef - session with current_sensors and _points populated.
%
%   Output
%     zef - session with normalized _get_functions cell array.
%
%   See also zef_attach_sensors_volume, zef_create_sensors.

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
