function zef = zef_strip_tool_open(zef)
%ZEF_STRIP_TOOL_OPEN  Construct the Strip tool window and init the first strip.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_open(zef)
%
%   Called via zef_tool_start from zef_strip_tool_start. Creates
%   zef.strip_tool if missing (strip_current_id=1), then window,
%   init, update. Does not embed.
%
%   See also zef_strip_tool_window, zef_strip_tool_start.

if not(isfield(zef,'strip_tool'))
zef.strip_tool = struct; 
zef.strip_tool.strip_current_id = 1; 
end

zef.strip_tool.current_strip = 1;

zef = zef_strip_tool_window(zef);
zef = zef_strip_tool_init(zef); 
zef = zef_strip_tool_update(zef); 

end
