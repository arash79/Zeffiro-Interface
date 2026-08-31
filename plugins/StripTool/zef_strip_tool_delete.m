function zef = zef_strip_tool_delete(zef)
%ZEF_STRIP_TOOL_DELETE  Remove the selected strip and clear matching get_functions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_delete(zef)
%
%   Delete button. Drops strip_cell{current_strip}; blanks sensor
%   get_functions whose sensor_info.strip_id matches. Then init/update
%   with current_strip=1. Does not remove already-embedded compartments.
%
%   See also zef_strip_tool_add.

struct_aux_1 = cell(0);
struct_aux_2 = zef.([zef.current_sensors '_strip_cell']);

strip_id = struct_aux_2{zef.strip_tool.current_strip}.strip_id;
domain_type = 'sensor_info';

if isfield(zef, zef.([zef.current_sensors '_get_functions']))
for i_ind = 1 : length(zef.([zef.current_sensors '_get_functions']))
    h_function_aux = zef.([zef.current_sensors '_get_functions']){i_ind}; 
    [~, sensor_info] = zef_sensor_get_function_eval(h_function_aux, zef, domain_type);
    if isequal(strip_id, sensor_info.strip_id)
    zef.([zef.current_sensors '_get_functions'])(i_ind) = cell(1);
    end
end
end

I = setdiff(1:length(struct_aux_2),zef.strip_tool.current_strip);
if not(isempty(I))
struct_aux_1 = struct_aux_2(I);
else
    struct_aux_1 = cell(0);
end
zef.([zef.current_sensors '_strip_cell']) = struct_aux_1;

zef.strip_tool.current_strip = 1;
zef_colored_list('value', zef.strip_tool.h_strip_list, 1);

zef = zef_strip_tool_init(zef);
zef = zef_strip_tool_update(zef);

end
