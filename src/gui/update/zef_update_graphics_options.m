% --- Zeffiro documentation header ---
% zef.use_gpu_graphic = get(zef — Zef.use gpu graphic = get(zef.
%
% Purpose:
%   Zef.use gpu graphic = get(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.colormap_size (read, write)
%   zef.colortune_param (read, write)
%   zef.cone_alpha (read, write)
%   zef.cone_lattice_resolution (read, write)
%   zef.cone_scale (read, write)
%   zef.contour_line_width (read, write)
%   zef.contour_n_smoothing (read, write)
%   zef.h_colormap_size (read)
%   zef.h_colortune_param (read)
%   zef.h_cone_alpha (read)
%   zef.h_cone_lattice_resolution (read)
%   zef.h_cone_scale (read)
%   zef.h_contour_line_width (read)
%   zef.h_contour_n_smoothing (read)
%   zef.h_n_streamline (read)
%   … (13 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.use_gpu_graphic = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
