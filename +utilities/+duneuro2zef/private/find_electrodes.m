function [electrodes, extra] = find_electrodes(raw)
%FIND_ELECTRODES  N×3 electrode positions and optional extra columns.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    electrodes = [];
    extra = [];
    val = find_named(raw, {'electrodePositions', 'electrode_positions', ...
        'elecpos', 'electrodes'}, 2);
    if isempty(val) && isfield(raw, 'sensors')
        sensors = raw.sensors;
        if isstruct(sensors)
            if isfield(sensors, 'elec') && isstruct(sensors.elec) && isfield(sensors.elec, 'chanpos')
                val = sensors.elec.chanpos;
            elseif isfield(sensors, 'chanpos')
                val = sensors.chanpos;
            elseif isfield(sensors, 'elecpos')
                val = sensors.elecpos;
            end
        elseif isnumeric(sensors)
            val = sensors;
        end
    end
    if isempty(val) && isfield(raw, 'elec') && isstruct(raw.elec) && isfield(raw.elec, 'chanpos')
        val = raw.elec.chanpos;
    end
    if isempty(val)
        return
    end
    if isnumeric(val) && ismatrix(val)
        if size(val, 2) > 3 && size(val, 1) ~= 3
            extra = val(:, 4:end);
            val = val(:, 1:3);
        elseif size(val, 1) > 3 && size(val, 2) ~= 3
            extra = val(4:end, :).';
            val = val(1:3, :).';
        end
    end
    electrodes = as_n_by_k(val, 3, 'electrode positions');
    if ~all(isfinite(electrodes(:)))
        error('duneuro2zef:InvalidSensors', 'Electrode coordinates contain non-finite values.');
    end
end
