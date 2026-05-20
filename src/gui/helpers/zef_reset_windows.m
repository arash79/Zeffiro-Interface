% --- Zeffiro documentation header ---
% zef_segmentation_tool; — Zef segmentation tool;.
%
% Purpose:
%   Zef segmentation tool;.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%
% Calls (project):
%   zef_update
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_segmentation_tool;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_segmentation_tool;
zef_reopen_menu_tool;
zef.h_zeffiro.DeleteFcn = '';
delete(zef.h_zeffiro);
zef_figure_tool;
zef_mesh_tool;
zef_mesh_visualization_tool;
zef = zef_update(zef);
