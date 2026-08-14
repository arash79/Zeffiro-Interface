%ZEF_INIT_GRAPHICS_OPTIONS  Defaults for Settings → Graphics processing options (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. isfield-guarded defaults for streamlines, cones, contours,
%   parcellation, GPU graphic, colortune_param, sensors_visual_size.
%   Note: the cone_lattice_resolution guard writes
%   zef.cone_field_lattice_resolution (different field name) when
%   cone_lattice_resolution is missing. Run from
%   zef_open_graphics_options. Does not open the dialog.
%
%   See also zef_open_graphics_options.
if not(isfield(zef,'streamline_draw'))
    zef.streamline_draw = 0;
end

if not(isfield(zef,'streamline_linestyle'));
    zef.streamline_linestyle = '-';
end

if not(isfield(zef,'cone_alpha'));
    zef.cone_alpha = 1;
end;

if not(isfield(zef,'contour_n_smoothing'));
    zef.contour_n_smoothing = 2;
end;

if not(isfield(zef,'contour_line_width'));
    zef.contour_line_width = 1;
end;


if not(isfield(zef,'cone_lattice_resolution'));
    zef.cone_field_lattice_resolution = 10;
end;
if not(isfield(zef,'cone_scale'));
    zef.cone_scale = 0.5;
end;
if not(isfield(zef,'parcellation_type'));
    zef.parcellation_type = 1;
end;

if not(isfield(zef,'parcellation_quantile'));
    zef.parcellation_quantile = 0.98;
end;

if not(isfield(zef,'sensors_visual_size'));
    zef.sensors_visual_size = 3.5;
end;

if not(isfield(zef,'use_gpu_graphic'));
    zef.use_gpu_graphic = 1;
end;

if not(isfield(zef,'colortune_param'));
    zef.colortune_param = 1;
end;
