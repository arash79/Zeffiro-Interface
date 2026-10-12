function tf = zef_sensor_is_strip_contact(get_functions, sensor_index)
%ZEF_SENSOR_IS_STRIP_CONTACT  True when this row is bound to a shaft contact.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   tf = zef_sensor_is_strip_contact(get_functions, sensor_index)
%
%   The binding is the get_function string written by Add contacts.
%   Scalp rows have an empty string and stay on the scalp attachment.

tf = false;
if ~iscell(get_functions) || isempty(sensor_index) || ~isscalar(sensor_index)
    return
end
if sensor_index < 1 || sensor_index > numel(get_functions) || sensor_index ~= floor(sensor_index)
    return
end
function_string = get_functions{sensor_index};
if isstring(function_string)
    function_string = char(function_string);
end
tf = ischar(function_string) && contains(function_string, 'zef_get_strip_contacts');
end
