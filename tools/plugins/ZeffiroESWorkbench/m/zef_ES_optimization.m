function zef_ES_optimization(zef)
% --- Zeffiro documentation header ---
% zef_ES_optimization — Zef ES optimization.
%
% Purpose:
%   Zef ES optimization.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.font_size (read, write)
%
% Calls (project):
%   zef_ES_optimization
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_ES_optimization(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

org_val         = zef.font_size;
zef.font_size   = 14;
zef             = zef_tool_start(zef, 'zef_ES_optimization_window', 1/5, 1);
zef.font_size   = org_val;

if nargout == 0
    assignin('base','zef',zef);
end

end
