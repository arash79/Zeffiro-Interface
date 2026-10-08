function zef = zef_strip_tool_burr_remove(zef)
%ZEF_STRIP_TOOL_BURR_REMOVE  Drop the selected compartment row from this lead.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The mesh is unchanged until Apply to mesh. Removing the row means the
%   next apply will not rewrite that compartment, and a previous rewrite
%   of it is restored when Apply runs.
%
%   zef = zef_strip_tool_burr_remove(zef)
%
%   See also zef_strip_tool_burr_set, zef_strip_tool_burr_apply.

list = zef.strip_tool.h_burr_list;
tags = list.UserData;
val = list.Value;
tag = '';
if iscell(tags) && isnumeric(val) && isscalar(val) && val >= 1 && val <= numel(tags)
    tag = tags{val};
end

zef = zef_strip_tool_update(zef);

if isempty(tag)
    zef = zef_strip_tool_burr_refresh(zef, 'Select a configured compartment to remove.');
    return
end

key = [zef.current_sensors '_strip_cell'];
strip = zef.(key){zef.strip_tool.current_strip};
holes = zef_strip_burr_normalize([]);
if isfield(strip, 'burr_holes')
    holes = zef_strip_burr_normalize(strip.burr_holes);
end
if isempty(holes)
    zef = zef_strip_tool_burr_refresh(zef, 'No burr-hole rows to remove.');
    return
end
keep = ~strcmp({holes.compartment_tag}, tag);
holes = holes(keep);
if isempty(holes)
    holes = zef_strip_burr_normalize([]);
end
strip.burr_holes = holes;
zef.(key){zef.strip_tool.current_strip} = strip;
zef = zef_strip_tool_burr_refresh(zef, ...
    sprintf('Removed %s. Apply to mesh drops that cylinder from the conductivity.', tag));

end
