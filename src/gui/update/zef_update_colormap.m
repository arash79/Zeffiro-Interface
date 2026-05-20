function new_colormap = zef_update_colormap(colormap_ind, colortune_param, colormap_size)
% --- Zeffiro documentation header ---
% zef_update_colormap — Syncs GUI control values into `zef` for colormap.
%
% Purpose:
%   Syncs GUI control values into `zef` for colormap.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   colormap_ind
%   colortune_param
%   colormap_size
%
% Outputs:
%   new_colormap
%
% Zef fields (observed):
%   zef.colormap_cell (read)
%
% Calls (project):
%   zef_update_colormap
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[new_colormap] = zef_update_colormap(colormap_ind, colortune_param, colormap_size)` with project root and `src` on the path.
% --- End Zeffiro documentation header


colormap_cell = evalin('base','zef.colormap_cell');
new_colormap = evalin('base',[colormap_cell{colormap_ind} '(' num2str(colortune_param) ',' num2str(colormap_size) ')']);

end
