function zef = zef_ramus_inversion_tool(zef)
% --- Zeffiro documentation header ---
% zef_ramus_inversion_tool — Zef ramus inversion tool.
%
% Purpose:
%   Zef ramus inversion tool.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_ramus_inversion_tool
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ramus_inversion_tool(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_ramus_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
