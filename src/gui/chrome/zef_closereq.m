function zef_closereq(tool_name)
%ZEF_CLOSEREQ  DeleteFcn helper for Zeffiro tools.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_closereq()
%   zef_closereq(tool_name)
%
%   With a nonempty tool_name (zef_tool_start sets DeleteFcn to
%   zef_closereq('script_name')), findall(groot,'ZefTool',tool_name)
%   and delete those figures. With no argument (Mesh tool, Mesh
%   visualization, Settings windows), call MATLAB closereq on gcbo.
%   This does not hide-and-keep a singleton; it deletes (or the
%   default close).
%
%   See also zef_tool_start, closereq.
if nargin==0
    tool_name ='';
end

if not(isempty(tool_name))
    h_tool = findall(groot,'ZefTool',tool_name);
end

if not(isempty(tool_name))
    delete(h_tool)
else
    closereq;
end

end
