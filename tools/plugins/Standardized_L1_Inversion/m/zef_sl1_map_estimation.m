function zef = sl1_map_estimation(zef)
% --- Zeffiro documentation header ---
% sl1_map_estimation — Sl1 map estimation.
%
% Purpose:
%   Sl1 map estimation.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = sl1_map_estimation(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_init_sl1',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
