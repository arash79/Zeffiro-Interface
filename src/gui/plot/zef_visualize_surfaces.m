%ZEF_VISUALIZE_SURFACES  Mesh visualization → **Visualize surfaces** (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_pushbutton20 (Text='Visualize surfaces').
%   zef_process_meshes, zef.on_screen=2 (Details: Visualization: Surfaces),
%   zef_update_fig_details, zef_plot_meshes([]) into zef.h_axes1. Also
%   copies h_frame_start / h_frame_stop into zef.frame_*. Clears Stop.
%
%   See also zef_plot_meshes, zef_visualize_volume.
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
