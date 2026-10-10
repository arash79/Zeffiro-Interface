function column = zef_electrode_property_column(property, n_sensors)
%ZEF_ELECTRODE_PROPERTY_COLUMN  One electrode property value per sensor.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   column = zef_electrode_property_column(property, n_sensors)
%
%   A scalar applies to every sensor. A vector of length n_sensors is
%   returned as a column. Append-contacts used to stack a still-scalar
%   property in front of one row per new contact, so the stored length
%   is 1 + N_new while the point table is N_old + N_new. The first value
%   is that scalar and covers the original sensors; the rest line up
%   with the contacts added afterwards.
%
%   See also zef_cem_electrode, zef_strip_tool_add_contacts.

if nargin < 2 || isempty(n_sensors)
    n_sensors = 0;
end
n_sensors = double(n_sensors(1));
if ~isnumeric(property)
    property = zeros(0, 1);
end
property = double(property(:));
n_values = numel(property);

if n_sensors < 1
    column = property;
    return
end
if n_values == n_sensors
    column = property;
    return
end
if n_values == 0
    column = zeros(n_sensors, 1);
    return
end

% prefix counts the original sensors that shared property(1).
prefix = n_sensors - n_values + 1;
if prefix < 0
    error('zef_electrode_property_column:Length', ...
        'Electrode property has %d values for %d sensors.', n_values, n_sensors);
end
column = [repmat(property(1), prefix, 1); property(2:end)];

end
