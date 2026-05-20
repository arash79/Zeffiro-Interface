function [contacts, sensor_info, triangle_index] = zef_sensor_get_function_eval(function_string, project_struct, domain_type)
% --- Zeffiro documentation header ---
% zef_sensor_get_function_eval — Zef sensor get function eval.
%
% Purpose:
%   Zef sensor get function eval.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   function_string
%   project_struct
%   domain_type
%
% Outputs:
%   contacts
%   sensor_info
%   triangle_index
%
% Calls (project):
%   zef_sensor_get_function_eval
%
% Side effects:
%   - base/caller workspace
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[contacts, sensor_info, triangle_index]] = zef_sensor_get_function_eval(function_string, project_struct, domain_type)` with project root and `src` on the path.
% --- End Zeffiro documentation header


[contacts, sensor_info, triangle_index] = feval(@(project_struct, domain_type)evalin('caller',function_string),project_struct, domain_type);

end
