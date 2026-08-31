function zef = zef_start_source_tree_tool(zef)
%ZEF_START_SOURCE_TREE_TOOL  Open Forward tools → Source tree tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Default-profile menu callback. App Designer tree of Jansen–Rit nodes
%   with optional measurement simulation through zef.L.
%
%   zef = zef_start_source_tree_tool(zef)
%
%   See also zef_open_source_tree, zef_simulate_jr_tree.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_open_source_tree',1/3,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
