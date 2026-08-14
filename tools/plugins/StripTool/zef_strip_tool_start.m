function zef = zef_strip_tool_start(zef)
%ZEF_STRIP_TOOL_START  Open Strip tool (no default menu).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not in the default profile INI. Embed adds strip (and optional
%   encapsulation) compartments via zef_add_compartment.
%
%   zef = zef_strip_tool_start(zef)
%
%   See also zef_strip_tool_embed, zef_create_strip.
%

if nargin == 0
zef = evalin('base','zef');
end    

zef = zef_tool_start(zef,'zef_strip_tool_open',1/2.5,0);

if nargout == 0
    assignin('base','zef',zef)
end



end
