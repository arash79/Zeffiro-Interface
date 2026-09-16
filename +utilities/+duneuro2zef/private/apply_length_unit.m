function [coords, report] = apply_length_unit(coords, raw, report)
%APPLY_LENGTH_UNIT  Scale coordinates to millimetres using unit or bbox.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    if isfield(report, 'unit_scale') && ~isempty(report.unit_scale)
        coords = coords * report.unit_scale;
        return
    end
    unit = find_named(raw, {'unit', 'units', 'length_unit'}, 2);
    scale = 1;
    unit_name = '';
    if ~isempty(unit)
        unit_name = lower(strtrim(char(string(unit))));
        switch unit_name
            case {'m', 'metre', 'meter', 'metres', 'meters', 'si'}
                scale = 1000;
            case {'cm', 'centimetre', 'centimeter'}
                scale = 10;
            case {'mm', 'millimetre', 'millimeter'}
                scale = 1;
        end
    else
        diag_len = bbox_diagonal(coords);
        if diag_len >= 0.05 && diag_len <= 0.5
            scale = 1000;
            unit_name = 'm (inferred from bounding-box diagonal)';
        elseif diag_len >= 50 && diag_len <= 500
            scale = 1;
            unit_name = 'mm (inferred from bounding-box diagonal)';
        else
            unit_name = 'unspecified; coordinates stored as given, location_unit=mm';
        end
    end
    report.unit_scale = scale;
    report.length_unit = unit_name;
    if scale ~= 1
        coords = coords * scale;
        report.warnings{end+1} = sprintf('Converted coordinates from %s to millimetres.', unit_name);
    end
end

function d = bbox_diagonal(coords)
    if isempty(coords)
        d = NaN;
        return
    end
    lo = min(coords, [], 1);
    hi = max(coords, [], 1);
    d = norm(hi - lo);
end
