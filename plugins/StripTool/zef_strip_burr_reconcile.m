function [holes, dropped] = zef_strip_burr_reconcile(zef, holes)
%ZEF_STRIP_BURR_RECONCILE  Drop rows whose compartment tag is no longer loaded.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Identity is the compartment tag, not the display name or the row index.
%   If compartment_tags is missing, rows are kept: there is no model yet
%   against which to decide they are stale. Tags that remain are never
%   reassigned to a different compartment.
%
%   [holes, dropped] = zef_strip_burr_reconcile(zef, holes)
%
%   See also zef_strip_burr_catalog, zef_strip_burr_reconcile_all.

holes = zef_strip_burr_normalize(holes);
dropped = cell(1, 0);
if ~isstruct(zef) || ~isfield(zef, 'compartment_tags') || isempty(zef.compartment_tags)
    return
end
tags = zef.compartment_tags;
if isstring(tags)
    tags = cellstr(tags);
end
known = cell(1, numel(tags));
for i = 1:numel(tags)
    known{i} = char(string(tags{i}));
end
keep = true(1, numel(holes));
for i = 1:numel(holes)
    if ~any(strcmp(known, holes(i).compartment_tag))
        keep(i) = false;
        dropped{end + 1} = holes(i).compartment_tag; %#ok<AGROW>
    end
end
holes = holes(keep);
if isempty(holes)
    holes = zef_strip_burr_normalize([]);
end

end
