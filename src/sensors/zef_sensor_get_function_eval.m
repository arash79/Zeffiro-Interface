function [contacts, sensor_info, triangle_index] = zef_sensor_get_function_eval(function_string, project_struct, domain_type)
%ZEF_SENSOR_GET_FUNCTION_EVAL  Evaluate a sensor attachment function string.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Runs function_string in the caller workspace via feval and evalin,
%   passing project_struct and domain_type. Used by zef_attach_sensors_volume
%   for custom per-sensor attachment logic.
%
%   [contacts, sensor_info, triangle_index] = ...
%       zef_sensor_get_function_eval(function_string, project_struct, domain_type)
%
%   Inputs
%     function_string - MATLAB expression or function handle name as string.
%     project_struct  - zef session passed to the evaluated code.
%     domain_type     - attachment domain ('mesh', 'geometry', 'points', ...).
%
%   Outputs
%     contacts, sensor_info, triangle_index - return values from the evaluated code.
%
%   See also zef_attach_sensors_volume.

[contacts, sensor_info, triangle_index] = feval(@(project_struct, domain_type)evalin('caller',function_string),project_struct, domain_type);

end
