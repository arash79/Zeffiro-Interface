function Y = orient_measurements(Y, n_electrodes)
%ORIENT_MEASUREMENTS  Sensors×time measurement matrix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    if isempty(n_electrodes) || n_electrodes <= 0
        return
    end
    if size(Y, 1) == n_electrodes
        return
    end
    if size(Y, 2) == n_electrodes && size(Y, 1) ~= n_electrodes
        Y = Y.';
        return
    end
    error('duneuro2zef:InvalidMeasurements', ...
        'Measurements size %s does not match %d sensors.', mat2str(size(Y)), n_electrodes);
end
