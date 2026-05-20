function zef = zef_DBS_strip_struct_start(zef)
% --- Zeffiro documentation header ---
% zef_DBS_strip_struct_start — Zef DBS strip struct start.
%
% Purpose:
%   Zef DBS strip struct start.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_DBS_strip_struct_start
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_DBS_strip_struct_start(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
zef = evalin('base','zef');
end    

zef = zef_tool_start(zef,'zef_DBS_strip_struct_open',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end



end
