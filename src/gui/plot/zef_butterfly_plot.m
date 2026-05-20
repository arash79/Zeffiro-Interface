function zef = zef_butterfly_plot(zef)
% --- Zeffiro documentation header ---
% zef_butterfly_plot — Zef butterfly plot.
%
% Purpose:
%   Zef butterfly plot.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_butterfly_plot
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_butterfly_plot(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_butterfly_plot_start',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end
