function labels = find_electrode_labels(raw, n)
%FIND_ELECTRODE_LABELS  Channel names matching electrode count, else E1..EN.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    labels = arrayfun(@(k) sprintf('E%d', k), (1:n)', 'UniformOutput', false);
    val = find_named(raw, {'label', 'labels', 'electrode_labels', 'chanlabel'}, 2);
    if isempty(val) && isfield(raw, 'sensors') && isstruct(raw.sensors)
        if isfield(raw.sensors, 'elec') && isfield(raw.sensors.elec, 'label')
            val = raw.sensors.elec.label;
        elseif isfield(raw.sensors, 'label')
            val = raw.sensors.label;
        end
    end
    if isempty(val)
        return
    end
    if ischar(val)
        val = cellstr(val);
    end
    if isstring(val)
        val = cellstr(val);
    end
    if iscell(val) && numel(val) == n
        labels = val(:);
    end
end
