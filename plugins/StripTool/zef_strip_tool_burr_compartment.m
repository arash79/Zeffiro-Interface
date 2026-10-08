function zef = zef_strip_tool_burr_compartment(zef)
%ZEF_STRIP_TOOL_BURR_COMPARTMENT  Show the selected compartment's radius and conductivity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   A compartment that already has a row loads that row. Otherwise the
%   conductivity box is prefilled with the compartment's current scalar
%   sigma so the user can see the value being replaced. The radius box is
%   left as typed unless a stored row supplies one.
%
%   zef = zef_strip_tool_burr_compartment(zef)
%
%   See also zef_strip_tool_burr_refresh, zef_strip_tool_burr_set.

if ~isfield(zef, 'strip_tool') || ~isfield(zef.strip_tool, 'h_burr_compartment') ...
        || ~isgraphics(zef.strip_tool.h_burr_compartment)
    return
end
popup = zef.strip_tool.h_burr_compartment;
tags = popup.UserData;
if ~iscell(tags) || isempty(tags) || popup.Value < 1 || popup.Value > numel(tags)
    return
end
tag = tags{popup.Value};
if isempty(tag)
    return
end

holes = zef_strip_burr_normalize([]);
key = [zef.current_sensors '_strip_cell'];
if isfield(zef, key) && numel(zef.(key)) >= zef.strip_tool.current_strip
    strip = zef.(key){zef.strip_tool.current_strip};
    if isstruct(strip) && isfield(strip, 'burr_holes')
        holes = zef_strip_burr_normalize(strip.burr_holes);
    end
end
found = [];
if ~isempty(holes)
    found = find(strcmp({holes.compartment_tag}, tag), 1);
end
if ~isempty(found)
    zef.strip_tool.h_burr_radius.String = sprintf('%.8g', holes(found).radius_mm);
    zef.strip_tool.h_burr_conductivity.String = sprintf('%.8g', holes(found).conductivity);
    return
end

catalog = zef_strip_burr_catalog(zef);
index = find(strcmp(catalog.tag, tag), 1);
if ~isempty(index) && isfinite(catalog.sigma(index))
    zef.strip_tool.h_burr_conductivity.String = sprintf('%.8g', catalog.sigma(index));
end

end
