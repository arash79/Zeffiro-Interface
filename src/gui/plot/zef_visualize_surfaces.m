% --- Zeffiro documentation header ---
% zef = zef_process_meshes(zef,zef — Zef = zef process meshes(zef,zef.
%
% Purpose:
%   Zef = zef process meshes(zef,zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.frame_start (read, write)
%   zef.frame_stop (read, write)
%   zef.h_frame_start (read)
%   zef.h_frame_stop (read)
%   zef.h_stop_movie (read)
%   zef.on_screen (read, write)
%   zef.stop_movie (read, write)
%
% Calls (project):
%   zef_plot_meshes
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef = zef_process_meshes(zef,zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef = zef_process_meshes(zef,zef.explode_everything);
zef.on_screen = 2;
zef_update_fig_details;zef_plot_meshes([]);
zef.stop_movie = 0;

zef.frame_start=str2double(zef.h_frame_start.Value);
zef.frame_stop=str2double(zef.h_frame_stop.Value);

set(zef.h_stop_movie,'value',zef.stop_movie);
set(zef.h_stop_movie,'foregroundcolor',[0 0 0]);
set(zef.h_stop_movie,'string','Stop');

set(zef.h_stop_movie,'value',zef.stop_movie);
