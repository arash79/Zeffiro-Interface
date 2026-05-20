function zef = zef_parcellation_tool(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_tool — Zef parcellation tool.
%
% Purpose:
%   Zef parcellation tool.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_parcellation_tool
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_parcellation_tool(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_parcellation_tool_open',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
