function measurements = find_measurements(raw)
%FIND_MEASUREMENTS  Measurement / data matrix on a DUNEuro struct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    measurements = find_named(raw, {'measurements', 'avg'}, 1);
    if ~isempty(measurements) && ~isnumeric(measurements)
        measurements = [];
    end
end
