function zef = zef_strip_tool_add(zef)
%ZEF_STRIP_TOOL_ADD  Append a new tentative strip (next strip_current_id).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_add(zef)
%
%   Add button. current_strip = length(strip_cell)+1; then init/update.
%   Does not add contacts or compartments.
%
%   See also zef_strip_tool_delete.

zef.strip_tool.strip_current_id = zef.strip_tool.strip_current_id + 1; 

zef.strip_tool.current_strip = length(zef.([zef.current_sensors '_strip_cell']))+1;

zef = zef_strip_tool_init(zef);
zef = zef_strip_tool_update(zef);

end
