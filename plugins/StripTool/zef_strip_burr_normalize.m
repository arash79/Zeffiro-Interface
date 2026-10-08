function holes = zef_strip_burr_normalize(holes)
%ZEF_STRIP_BURR_NORMALIZE  Struct array of per-compartment burr-hole rows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Each row has compartment_tag, radius_mm, and conductivity. Malformed
%   rows are dropped. Negative or zero values are kept so the applicator
%   can reject or warn explicitly instead of substituting another number.
%
%   holes = zef_strip_burr_normalize(holes)
%
%   See also zef_strip_burr_reconcile, zef_strip_burr_check.

empty = struct('compartment_tag', {}, 'radius_mm', {}, 'conductivity', {});
if isempty(holes) || ~isstruct(holes)
    holes = empty;
    return
end
if ~isfield(holes, 'compartment_tag') || ~isfield(holes, 'radius_mm') ...
        || ~isfield(holes, 'conductivity')
    holes = empty;
    return
end
keep = true(1, numel(holes));
for i = 1:numel(holes)
    tag = holes(i).compartment_tag;
    if isstring(tag)
        tag = char(tag);
    end
    if ~ischar(tag) || isempty(strtrim(tag))
        keep(i) = false;
        continue
    end
    holes(i).compartment_tag = strtrim(tag);
    radius_mm = holes(i).radius_mm;
    conductivity = holes(i).conductivity;
    if ~isscalar(radius_mm) || ~isnumeric(radius_mm) ...
            || ~isscalar(conductivity) || ~isnumeric(conductivity)
        keep(i) = false;
        continue
    end
    holes(i).radius_mm = double(radius_mm);
    holes(i).conductivity = double(conductivity);
end
holes = holes(keep);
if isempty(holes)
    holes = empty;
end

end
