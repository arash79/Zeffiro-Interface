function tensors = find_tensors(raw)
%FIND_TENSORS  Anisotropic conductivity tensors on a DUNEuro struct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    tensors = find_named(raw, {'tensors', 'conductivity_tensors', 'sigma_tensors'}, 2);
    if isfield(raw, 'volume_conductor') && isstruct(raw.volume_conductor) ...
            && isfield(raw.volume_conductor, 'tensors')
        tensors = raw.volume_conductor.tensors;
    end
    if isempty(tensors) || ~isnumeric(tensors)
        tensors = [];
        return
    end
    if size(tensors, 1) == 6 || size(tensors, 1) == 9
        tensors = tensors.';
    end
end
