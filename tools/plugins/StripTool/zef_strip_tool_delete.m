function zef = zef_strip_tool_delete(zef)
% --- Zeffiro documentation header ---
% zef_strip_tool_delete — Zef strip tool delete.
%
% Purpose:
%   Zef strip tool delete.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.current_sensors (read)
%   zef.strip_tool (read)
%
% Calls (project):
%   zef_sensor_get_function_eval
%   zef_strip_tool_delete
%   zef_strip_tool_init
%   zef_strip_tool_update
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_strip_tool_delete(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
zef.strip_tool.h_strip_list.Value = 1;

zef = zef_strip_tool_init(zef);
zef = zef_strip_tool_update(zef);

end
