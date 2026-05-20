function zef = zef_find_synthetic_source_legacy(zef)
% --- Zeffiro documentation header ---
% zef_find_synthetic_source_legacy — Zef find synthetic source legacy.
%
% Purpose:
%   Zef find synthetic source legacy.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_find_synthetic_source_legacy
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_find_synthetic_source_legacy(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_find_synthetic_source_legacy_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
