% --- Zeffiro documentation header ---
% zef_init_graphics_options; — Initializes GUI widgets and default `zef` fields for graphics_options;.
%
% Purpose:
%   Initializes GUI widgets and default `zef` fields for graphics_options;.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.colormap_size (read)
%   zef.colortune_param (read)
%   zef.cone_alpha (read)
%   zef.cone_lattice_resolution (read)
%   zef.cone_scale (read)
%   zef.contour_line_width (read)
%   zef.contour_n_smoothing (read)
%   zef.fieldnames (read, write)
%   zef.font_size (read)
%   zef.graphics_options_current_size (read, write)
%   zef.h_colormap_size (read)
%   zef.h_colortune_param (read)
%   zef.h_cone_alpha (read)
%   zef.h_cone_lattice_resolution (read)
%   zef.h_cone_scale (read)
%   … (19 more)
%
% Calls (project):
%   zef_change_size_function
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef_init_graphics_options;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_init_graphics_options;

zef_data = zef_graphics_processing_options;

zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
    if find(ismember(properties(zef.(zef.fieldnames{zef_i})),'ValueChangedFcn'))
        zef.(zef.fieldnames{zef_i}).ValueChangedFcn = 'zef_update_graphics_options;';
    end
end

zef = rmfield(zef,'fieldnames');

clear zef_data;

zef.h_sensors_visual_size.Value = num2str(zef.sensors_visual_size);
zef.h_use_gpu_graphic.Value = zef.use_gpu_graphic;
zef.h_parcellation_type.ItemsData = [1:length(zef.h_parcellation_type.Items)];
zef.h_parcellation_type.Value = zef.parcellation_type;
zef.h_cone_alpha.Value = num2str(1 - zef.cone_alpha);
zef.h_parcellation_quantile.Value = num2str(zef.parcellation_quantile);
zef.h_cone_lattice_resolution.Value = num2str(zef.cone_lattice_resolution);
zef.h_cone_scale.Value = num2str(zef.cone_scale);
zef.h_colormap_size.Value = num2str(zef.colormap_size);
zef.h_streamline_linestyle.Value = zef.streamline_linestyle;
zef.h_streamline_linewidth.Value = num2str(zef.streamline_linewidth);
zef.h_streamline_color.Value = zef.streamline_color;
zef.h_n_streamline.Value = num2str(zef.n_streamline);
zef.h_colortune_param.Value = num2str(zef.colortune_param);
zef.h_contour_n_smoothing.Value = num2str(zef.contour_n_smoothing);
zef.h_contour_line_width.Value = num2str(zef.contour_line_width);

zef.h_zef_graphics_processing_options.Name = 'ZEFFIRO Interface: Graphics processing options';
set(findobj(zef.h_zef_graphics_processing_options.Children,'-property','FontUnits'),'FontUnits','pixels');
set(findobj(zef.h_zef_graphics_processing_options.Children,'-property','FontSize'), 'FontSize', zef.font_size);

set(zef.h_zef_graphics_processing_options,'AutoResizeChildren','off');
zef.graphics_options_current_size = get(zef.h_zef_graphics_processing_options,'Position');
set(zef.h_zef_graphics_processing_options,'SizeChangedFcn','zef.graphics_options_current_size = zef_change_size_function(zef.h_zef_graphics_processing_options,zef.graphics_options_current_size);');

set(zef.h_zef_graphics_processing_options,'DeleteFcn','zef_closereq;');


clear zef_data;
