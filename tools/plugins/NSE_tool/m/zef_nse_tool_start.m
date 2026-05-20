function zef = zef_nse_tool_start(zef)
% --- Zeffiro documentation header ---
% zef_nse_tool_start — Zef nse tool start.
%
% Purpose:
%   Zef nse tool start.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_nse_tool_start
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_nse_tool_start(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_nse_tool_window',2/3,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
