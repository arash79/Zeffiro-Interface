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
%   default close). A commented block used to offload fields to
%   zef.matfile_object — that path is inactive.
%
%   See also zef_tool_start, closereq.
if nargin==0
    tool_name ='';
end

if not(isempty(tool_name))
    h_tool = findall(groot,'ZefTool',tool_name);
end

% if evalin('base','exist(''zef'',''var'');')
%     zef = evalin('base','zef');
%
%     if not(isempty(tool_name)) & not(isempty(h_tool))
%         time_val = now;
%         if not(isempty(zef.matfile_object))
%     I = find(ismember(zef.zeffiro_variable_data(:,1),tool_name));
%     for i = 1 : length(I)
%     if isfield(zef,zef.zeffiro_variable_data{I(i),2})
%         zef.matfile_object.(zef.zeffiro_variable_data{I(i),2}) = zef.(zef.zeffiro_variable_data{I(i),2});
%         zef.zeffiro_variable_data{I(i),5} = time_val;
%         zef = rmfield(zef,zef.zeffiro_variable_data{I(i),2});
%     end
%     end
%         end
%     if not(isempty(h_tool))
%     zef = zef_remove_object_handles(zef,[],cat(1,cat(1,h_tool.Children)));
%     else
%     zef = zef_remove_object_handles(zef,[],cat(1,get(gcbo,'Children')));
%     end
%     else
%     zef = zef_remove_object_handles(zef,[],cat(1,get(gcbo,'Children')));
%     end
%
%     keyboard
%     assignin('base','zef',zef);
%
% end


if not(isempty(tool_name))
    delete(h_tool)
else
    closereq;
end

end
