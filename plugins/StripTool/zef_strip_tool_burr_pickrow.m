function zef = zef_strip_tool_burr_pickrow(zef)
%ZEF_STRIP_TOOL_BURR_PICKROW  Load the selected burr-hole row into the edit boxes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_burr_pickrow(zef)
%
%   See also zef_strip_tool_burr_compartment.

list = zef.strip_tool.h_burr_list;
tags = list.UserData;
if ~iscell(tags) || isempty(tags) || list.Value < 1 || list.Value > numel(tags)
    return
end
tag = tags{list.Value};
if isempty(tag)
    return
end
popup = zef.strip_tool.h_burr_compartment;
if iscell(popup.UserData)
    match = find(strcmp(popup.UserData, tag), 1);
    if ~isempty(match)
        popup.Value = match;
    end
end
zef = zef_strip_tool_burr_compartment(zef);

end
