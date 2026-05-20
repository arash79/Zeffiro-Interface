function zef = zef_find_synthetic_source_patch(zef)
% --- Zeffiro documentation header ---
% zef_find_synthetic_source_patch — Zef find synthetic source patch.
%
% Purpose:
%   Zef find synthetic source patch.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_find_synthetic_source_patch
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_find_synthetic_source_patch(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_find_synthetic_source_patch_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
