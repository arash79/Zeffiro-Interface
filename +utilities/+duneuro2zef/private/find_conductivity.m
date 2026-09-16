function conductivity = find_conductivity(raw)
%FIND_CONDUCTIVITY  Scalar conductivity table or vector on a DUNEuro struct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    conductivity = find_named(raw, {'conductivity', 'conductivities', 'sigma'}, 2);
    if ~isempty(conductivity) && isnumeric(conductivity)
        conductivity = conductivity(:);
    else
        conductivity = [];
    end
end
