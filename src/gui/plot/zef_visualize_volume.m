% --- Zeffiro documentation header ---
% zef_process_meshes(zef,zef — Zef process meshes(zef,zef.
%
% Purpose:
%   Zef process meshes(zef,zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_stop_movie (read)
%   zef.on_screen (read, write)
%   zef.stop_movie (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_process_meshes(zef,zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_process_meshes(zef,zef.explode_everything);
zef.on_screen = 1;
zef_update_fig_details;
zef_plot_volume;
zef.stop_movie = 0;
set(zef.h_stop_movie,'value',zef.stop_movie);
