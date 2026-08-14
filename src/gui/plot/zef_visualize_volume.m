%ZEF_VISUALIZE_VOLUME  Mesh visualization → **Visualize volume** (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_pushbutton31 (App Designer Text=
%   'Visualize volume') in zef_mesh_visualization_tool. Runs
%   zef_process_meshes(zef, zef.explode_everything), sets zef.on_screen=1
%   (Details: Visualization: Volume), zef_update_fig_details, then
%   zef_plot_volume into zef.h_axes1. Clears Stop.
%
%   See also zef_plot_volume, zef_visualize_surfaces.
zef_process_meshes(zef,zef.explode_everything);
zef.on_screen = 1;
zef_update_fig_details;
zef_plot_volume;
zef.stop_movie = 0;
set(zef.h_stop_movie,'value',zef.stop_movie);
