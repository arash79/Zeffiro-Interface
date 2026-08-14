function zef = zef_parcellation_tool(zef)
%ZEF_PARCELLATION_TOOL  Open the Parcellation tool (Multi-tools menu).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Menu Multi-tools → Parcellation tool. Delegates to
%   zef_tool_start(..., 'zef_parcellation_tool_open', 1/4, 0). Not opened
%   at startup. nargout==0 assigns zef into the base workspace.
%
%   See also zef_parcellation_tool_open, zef_tool_start.
if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_parcellation_tool_open',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
