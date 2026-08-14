%ZEF_UPDATE_GRAPHICS_OPTIONS  Settings → Graphics processing options (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ValueChangedFcn on zef.h_zef_graphics_processing_options
%   (wired in zef_open_graphics_options). Copies GPU-graphic,
%   parcellation_type/quantile, cone lattice/scale, colormap_size,
%   streamlines, colortune_param, sensors_visual_size, contour smoothing
%   and line width. Widget cone alpha is stored inverted:
%   zef.cone_alpha = 1 - str2num(h_cone_alpha.Value). Does not replot;
%   next Visualize volume/surfaces picks the new values up.
%
%   See also zef_open_graphics_options, zef_init_graphics_options.
zef.use_gpu_graphic = get(zef.h_use_gpu_graphic,'Value');
zef.parcellation_type = get(zef.h_parcellation_type,'Value');
zef.parcellation_quantile = str2num(get(zef.h_parcellation_quantile,'Value'));
zef.cone_lattice_resolution = str2num(get(zef.h_cone_lattice_resolution,'Value'));
zef.cone_scale = str2num(get(zef.h_cone_scale,'Value'));
zef.colormap_size = str2num(get(zef.h_colormap_size,'value'));
zef.cone_alpha = 1 - str2num(get(zef.h_cone_alpha,'value'));
zef.streamline_linestyle = get(zef.h_streamline_linestyle,'value');
zef.streamline_linewidth = str2num(get(zef.h_streamline_linewidth,'value'));
zef.streamline_color = get(zef.h_streamline_color,'value');
zef.n_streamline = str2num(get(zef.h_n_streamline,'value'));
zef.colortune_param = str2num(get(zef.h_colortune_param,'Value'));
zef.sensors_visual_size = str2num(get(zef.h_sensors_visual_size,'value'));
zef.contour_n_smoothing = str2num(get(zef.h_contour_n_smoothing,'value'));
zef.contour_line_width = str2num(get(zef.h_contour_line_width,'value'));
