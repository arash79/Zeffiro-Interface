% --- Zeffiro documentation header ---
% if not(isfield(zef,'streamline_draw')) — If not(isfield(zef,'streamline draw')).
%
% Purpose:
%   If not(isfield(zef,'streamline draw')).
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.colortune_param (read, write)
%   zef.cone_alpha (read, write)
%   zef.cone_field_lattice_resolution (read, write)
%   zef.cone_scale (read, write)
%   zef.contour_line_width (read, write)
%   zef.contour_n_smoothing (read, write)
%   zef.parcellation_quantile (read, write)
%   zef.parcellation_type (read, write)
%   zef.sensors_visual_size (read, write)
%   zef.streamline_draw (read, write)
%   zef.streamline_linestyle (read, write)
%   zef.use_gpu_graphic (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'streamline_draw'))` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
