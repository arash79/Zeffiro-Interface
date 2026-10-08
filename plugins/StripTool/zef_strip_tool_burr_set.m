function zef = zef_strip_tool_burr_set(zef)
%ZEF_STRIP_TOOL_BURR_SET  Store one compartment's radius and conductivity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Updates the row when that compartment is already listed, otherwise
%   appends it. Values are read before the widget update so a refresh
%   cannot change which compartment is stored. Invalid numbers are not
%   written. This does not modify the mesh; Apply to mesh does.
%
%   zef = zef_strip_tool_burr_set(zef)
%
%   See also zef_strip_tool_burr_remove, zef_strip_burr_check.

popup = zef.strip_tool.h_burr_compartment;
tags = popup.UserData;
tag = '';
if iscell(tags) && popup.Value >= 1 && popup.Value <= numel(tags)
    tag = tags{popup.Value};
end
radius_mm = str2double(zef.strip_tool.h_burr_radius.String);
conductivity = str2double(zef.strip_tool.h_burr_conductivity.String);

zef = zef_strip_tool_update(zef);

if isempty(tag)
    zef = zef_strip_tool_burr_refresh(zef, ...
        'Load a model with compartments before configuring a burr hole.');
    return
end
[ok, notice] = zef_strip_burr_check(radius_mm, conductivity);
if ~ok
    zef = zef_strip_tool_burr_refresh(zef, notice);
    return
end

key = [zef.current_sensors '_strip_cell'];
strip = zef.(key){zef.strip_tool.current_strip};
holes = zef_strip_burr_normalize([]);
if isfield(strip, 'burr_holes')
    holes = zef_strip_burr_normalize(strip.burr_holes);
end
found = [];
if ~isempty(holes)
    found = find(strcmp({holes.compartment_tag}, tag), 1);
end
if isempty(found)
    found = numel(holes) + 1;
end
holes(found).compartment_tag = tag;
holes(found).radius_mm = double(radius_mm);
holes(found).conductivity = double(conductivity);
strip.burr_holes = holes;
zef.(key){zef.strip_tool.current_strip} = strip;

catalog = zef_strip_burr_catalog(zef);
name = tag;
index = find(strcmp(catalog.tag, tag), 1);
if ~isempty(index)
    name = sprintf('%s [%s]', catalog.name{index}, tag);
end
message = sprintf('Stored %s: %g mm, %g S/m. Apply to mesh updates conductivity.', ...
    name, double(radius_mm), double(conductivity));
if ~isempty(notice)
    message = [message ' ' notice];
end
zef = zef_strip_tool_burr_refresh(zef, message);

end
