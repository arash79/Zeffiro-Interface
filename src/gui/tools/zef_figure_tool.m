%ZEF_FIGURE_TOOL  Build the Figure tool (visualization axes and color/movie controls).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Not App Designer. Creates figure
%   "ZEFFIRO Interface: Figure tool" with axes h_axes1. assignin
%   ('base','zef',zef) so string callbacks see the session. DeleteFcn
%   zef_reopen_figure. Layout is zef_figure_tool_layout.
%
%   See also zef_plot_volume, zef_set_figure_tool_sliders, zef_figure_tool_layout.

zef_ui_theme_local = zef_ui_theme(zef);

make_shell = true;
try
    make_shell = isempty(findall(groot, 'Tag', 'zef_shell_nav'));
catch
end

width_aux = 900;
height_aux = 720;
if make_shell
    width_aux = zef_ui_theme_local.space.shellDefW;
    height_aux = zef_ui_theme_local.space.shellDefH;
end
if isfield(zef, 'h_zeffiro_menu') && isvalid(zef.h_zeffiro_menu)
    ref = zef.h_zeffiro_menu.Position;
else
    ref = zef.segmentation_tool_default_position;
end
work = zef_ui_screen_workarea(ref);
zef.size_temp = zef_ui_clamp_position( ...
    zef_ui_center_position([0 0 width_aux height_aux], work), work);

zef.h_zeffiro = figure( ...
    'WindowStyle', 'normal', ...
    'PaperUnits', get(0, 'defaultfigurePaperUnits'), ...
    'Units', 'Pixels', ...
    'Position', zef.size_temp, ...
    'Renderer', get(0, 'defaultfigureRenderer'), ...
    'Visible', 'off', ...
    'Color', zef_ui_theme_local.color.bg, ...
    'CloseRequestFcn', 'closereq;', ...
    'CurrentAxesMode', 'manual', ...
    'IntegerHandle', 'off', ...
    'NextPlot', get(0, 'defaultfigureNextPlot'), ...
    'Colormap', [0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0], ...
    'DoubleBuffer', 'off', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'Name', 'ZEFFIRO Interface: Figure tool', ...
    'NumberTitle', 'off', ...
    'HandleVisibility', 'callback', ...
    'DeleteFcn', 'zef_reopen_figure;', ...
    'Tag', 'figure_tool', ...
    'UserData', [], ...
    'Resize', get(0, 'defaultfigureResize'), ...
    'PaperPosition', get(0, 'defaultfigurePaperPosition'), ...
    'PaperSize', [20.99999864 29.69999902], ...
    'PaperType', get(0, 'defaultfigurePaperType'), ...
    'InvertHardcopy', get(0, 'defaultfigureInvertHardcopy'), ...
    'ScreenPixelsPerInchMode', 'manual', ...
    'AutoResizeChildren', 'off');

try
    assignin('base', 'zef', zef);
catch
end

zef.h_zeffiro.ContextMenu = uicontextmenu(zef.h_zeffiro);
uimenu(zef.h_zeffiro.ContextMenu, 'Text', 'Axes pop-up', 'MenuSelectedFcn', 'zef_axes_popup;');

zef.stop_movie = 0;
zef.h_figure_view = uipanel('Parent', zef.h_zeffiro, ...
    'Units', 'pixels', 'Position', [20 200 500 400], ...
    'Title', '', 'BorderType', 'none', ...
    'BackgroundColor', zef_ui_theme_local.color.axesBg, ...
    'ForegroundColor', zef_ui_theme_local.color.text, ...
    'Tag', 'figure_view');
try
    zef.h_figure_view.Clipping = 'on';
catch
end
try
    zef.h_figure_view.AutoResizeChildren = 'off';
catch
end

zef.h_axes1 = axes('Parent', zef.h_figure_view, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [1 1 498 398], 'Tag', 'axes1', ...
    'Color', zef_ui_theme_local.color.axesBg, 'Box', 'off', ...
    'XTick', [], 'YTick', []);
try
    zef.h_axes1.Toolbar.Visible = 'off';
catch
end
try
    disableDefaultInteractivity(zef.h_axes1);
catch
end

zef.h_panel_sidebar = uipanel('Parent', zef.h_zeffiro, ...
    'Units', 'pixels', 'Position', [540 200 300 400], ...
    'Title', '', 'BorderType', 'line', ...
    'HighlightColor', zef_ui_theme_local.color.border, ...
    'ForegroundColor', zef_ui_theme_local.color.text, ...
    'BackgroundColor', zef_ui_theme_local.color.panel, ...
    'Tag', 'figure_sidebar');

zef.h_panel_lists = uipanel('Parent', zef.h_zeffiro, ...
    'Units', 'pixels', 'Position', [20 12 500 zef_ui_theme_local.space.statusH], ...
    'Title', '', 'BorderType', 'line', ...
    'HighlightColor', zef_ui_theme_local.color.border, ...
    'ForegroundColor', zef_ui_theme_local.color.text, ...
    'BackgroundColor', zef_ui_theme_local.color.panel, ...
    'Tag', 'figure_lists');

sb = zef.h_panel_sidebar;
ls = zef.h_panel_lists;

uicontrol('Style', 'text', 'Parent', zef.h_zeffiro, 'Units', 'pixels', ...
    'String', '', 'HorizontalAlignment', 'left', 'Position', [20 600 240 20], ...
    'BackgroundColor', zef_ui_theme_local.color.bg, 'Tag', 'time_text', ...
    'Visible', 'off');

zef.h_toggle_controls = uicontrol('Tag', 'togglecontrolsbutton', 'UserData', 1, ...
    'Style', 'pushbutton', 'Parent', zef.h_zeffiro, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [540 570 140 28], 'String', 'Toggle controls', ...
    'Callback', 'zef_toggle_figure_controls;');
zef.h_toggle_edges = uicontrol('Tag', 'toggleedgesbutton', 'UserData', 1, ...
    'Style', 'pushbutton', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [160 360 120 28], 'String', 'Toggle edges', ...
    'Callback', 'zef_toggle_edges;');

uicontrol('Tag', 'section_color', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Color', 'HorizontalAlignment', 'left', 'Position', [10 340 260 16]);
uicontrol('Tag', 'label_time', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Time', 'HorizontalAlignment', 'left', 'Position', [10 316 118 22]);
uicontrol('Tag', 'label_color_min', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Color min', 'HorizontalAlignment', 'left', 'Position', [10 292 118 22]);
uicontrol('Tag', 'label_color_max', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Color max', 'HorizontalAlignment', 'left', 'Position', [10 268 118 22]);
uicontrol('Tag', 'label_distance', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'View distance', 'HorizontalAlignment', 'left', 'Position', [10 244 118 22]);

zef.h_slider = uicontrol('Tag', 'slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 318 150 16], 'Min', 1e-6, 'Max', 1, 'Value', 1e-5, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef_slidding_callback;');
zef.h_colorscale_min_slider = uicontrol('Tag', 'colorscale_min_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 294 150 16], 'Min', -1, 'Max', 1, 'Value', 0, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.colorscale_min_slider = zef_update_colorscale_min(zef.h_zeffiro);');
zef.h_colorscale_min_slider.UserData = zef.colorscale_min_slider;
zef.h_colorscale_max_slider = uicontrol('Tag', 'colorscale_max_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 270 150 16], 'Min', -1, 'Max', 1, 'Value', 0, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.colorscale_max_slider = zef_update_colorscale_max(zef.h_zeffiro);');
zef.h_colorscale_max_slider.UserData = zef.colorscale_max_slider;
zef.h_update_zoom = uicontrol('Tag', 'update_zoom_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 246 150 16], 'Min', 0.1, 'Max', 100, 'Value', zef.update_zoom, 'Sliderstep', [0.001 0.001], ...
    'Callback', 'zef.update_zoom = zef_update_zoom(zef.h_zeffiro);');

uicontrol('Tag', 'section_transparency', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Transparency', 'HorizontalAlignment', 'left', 'Position', [10 222 260 16]);
uicontrol('Tag', 'label_transp_rec', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Reconstruction', 'HorizontalAlignment', 'left', 'Position', [10 198 118 22]);
uicontrol('Tag', 'label_transp_surf', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Surface', 'HorizontalAlignment', 'left', 'Position', [10 174 118 22]);
uicontrol('Tag', 'label_transp_sens', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Sensors', 'HorizontalAlignment', 'left', 'Position', [10 150 118 22]);
uicontrol('Tag', 'label_transp_cones', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Cones', 'HorizontalAlignment', 'left', 'Position', [10 126 118 22]);
uicontrol('Tag', 'label_transp_add', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Additional', 'HorizontalAlignment', 'left', 'Position', [10 102 118 22]);

zef.h_update_transparency_reconstruction = uicontrol('Tag', 'transparency_reconstruction_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 200 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_transparency_reconstruction, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_transparency_reconstruction = zef_update_transparency_reconstruction(zef.h_zeffiro);');
zef.h_update_transparency_surface = uicontrol('Tag', 'transparency_surface_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 176 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_transparency_surface, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_transparency_surface = zef_update_transparency_surface(zef.h_zeffiro);');
zef.h_update_transparency_sensor = uicontrol('Tag', 'transparency_sensor_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 152 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_transparency_sensor, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_transparency_sensor = zef_update_transparency_sensor(zef.h_zeffiro);');
zef.h_update_transparency_cones = uicontrol('Tag', 'transparency_cones_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 128 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_transparency_cones, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_transparency_cones = zef_update_transparency_cones(zef.h_zeffiro);');
zef.h_update_transparency_additional = uicontrol('Tag', 'transparency_additional_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 104 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_transparency_additional, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_transparency_additional = zef_update_transparency_additional(zef.h_zeffiro);');

uicontrol('Tag', 'section_lighting', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Lighting', 'HorizontalAlignment', 'left', 'Position', [10 80 260 16]);
uicontrol('Tag', 'label_brightness', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Brightness', 'HorizontalAlignment', 'left', 'Position', [10 56 118 22]);
uicontrol('Tag', 'label_contrast', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Contrast', 'HorizontalAlignment', 'left', 'Position', [10 32 118 22]);
uicontrol('Tag', 'label_ambience', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Ambient', 'HorizontalAlignment', 'left', 'Position', [10 8 118 22]);
uicontrol('Tag', 'label_diffusion', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Diffuse', 'HorizontalAlignment', 'left', 'Position', [10 8 118 22]);
uicontrol('Tag', 'label_specular', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Specular', 'HorizontalAlignment', 'left', 'Position', [10 8 118 22]);

zef.h_update_brightness = uicontrol('Tag', 'update_brightness_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 58 150 16], 'Min', 0, 'Max', 5, 'Value', zef.update_brightness, 'Sliderstep', [0.01 0.01], ...
    'Callback', '[zef.update_contrast, zef.update_brightness] = zef_update_contrast_and_brightness(zef.h_zeffiro);');
zef.h_update_contrast = uicontrol('Tag', 'update_contrast_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 34 150 16], 'Min', -1, 'Max', 1, 'Value', zef.update_contrast, 'Sliderstep', [0.01 0.01], ...
    'Callback', '[zef.update_contrast, zef.update_brightness] = zef_update_contrast_and_brightness(zef.h_zeffiro);');
zef.h_update_ambience = uicontrol('Tag', 'update_ambience_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 10 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_ambience, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_ambience = zef_update_ambience(zef.h_zeffiro);');
zef.h_update_diffusion = uicontrol('Tag', 'update_diffusion_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 10 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_diffusion, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_diffusion = zef_update_diffusion(zef.h_zeffiro);');
zef.h_update_specular = uicontrol('Tag', 'update_specular_slider', 'Style', 'slider', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 10 150 16], 'Min', 0, 'Max', 1, 'Value', zef.update_specular, 'Sliderstep', [0.01 0.01], ...
    'Callback', 'zef.update_specular = zef_update_specular(zef.h_zeffiro);');

uicontrol('Tag', 'section_appearance', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Appearance', 'HorizontalAlignment', 'left', 'Position', [10 8 260 16]);
uicontrol('Tag', 'label_lights', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Lights', 'HorizontalAlignment', 'left', 'Position', [10 8 118 22]);
uicontrol('Tag', 'label_colormap', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Colormap', 'HorizontalAlignment', 'left', 'Position', [10 8 118 22]);
uicontrol('Tag', 'label_scale', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Scale', 'HorizontalAlignment', 'left', 'Position', [10 8 118 22]);

zef.h_update_lights = uicontrol('Tag', 'lightsselection', 'Style', 'popupmenu', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 8 150 22], 'String', {'Default', 'Lights off', 'Add X', 'Add Y', 'Add Z', 'Headlight'}, ...
    'Callback', 'zef.update_lights = zef_update_lights(zef.h_zeffiro);');
zef.h_update_colormap = uicontrol('Tag', 'colormapselection', 'Style', 'popupmenu', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 8 150 22], 'String', zef.colormap_items, 'Value', zef.update_colormap, ...
    'Callback', 'zef.update_colormap = zef.h_update_colormap.Value; zef_update_contrast_and_brightness(zef.h_zeffiro);');
zef.h_update_colorscale = uicontrol('Tag', 'colorscaleselection', 'Style', 'popupmenu', 'Parent', sb, 'Units', 'pixels', ...
    'Position', [130 8 150 22], 'String', {'Linear', 'Logarithmic'}, 'Value', zef.update_colorscale, ...
    'Callback', 'zef.update_colorscale = zef_update_colorscale(zef.h_zeffiro);');

uicontrol('Tag', 'label_loop', 'Style', 'text', 'Parent', sb, 'Units', 'pixels', ...
    'String', 'Loop', 'HorizontalAlignment', 'left', 'Position', [10 40 44 22]);
zef.h_loop_movie = uicontrol('Style', 'Checkbox', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [58 42 22 18], ...
    'Callback', 'zef.loop_movie = get(gcbo,''value''); set(gcbo,''UserData'',get(gcbo,''value''));', ...
    'HorizontalAlignment', 'left', 'Tag', 'loop_movie');
zef.h_loop_movie_count = uicontrol('Style', 'Edit', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [84 40 48 22], 'String', 'Loop visualization', ...
    'Callback', 'zef.loop_movie_count = str2num(get(gcbo,''string'')); set(gcbo,''UserData'',str2num(get(gcbo,''string'')));', ...
    'HorizontalAlignment', 'right', 'Tag', 'loop_count');

zef.h_reset_figure_tool_sliders = uicontrol('Style', 'togglebutton', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [10 8 65 28], 'String', 'Reset', 'Tag', 'resetbutton', ...
    'Callback', 'zef = zef_set_figure_tool_sliders(zef,0);zef.h_reset_figure_tool_sliders.Value=0;');
zef.h_play_movie = uicontrol('Style', 'pushbutton', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [80 8 65 28], 'String', 'Play', 'Tag', 'playbutton', ...
    'Callback', 'zef_play_cdata(max(1,double(get(findall(zef.h_zeffiro,''Tag'',''loop_movie''),''UserData''))*get(findall(zef.h_zeffiro,''Tag'',''loop_count''),''UserData'')));');
zef.h_stop_movie = uicontrol('Style', 'togglebutton', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [150 8 65 28], 'String', 'Stop', 'Tag', 'stopbutton', ...
    'Callback', @zef_callbackstop);
zef.h_logoplot = uicontrol('Style', 'pushbutton', 'Parent', sb, 'Visible', 'on', 'Units', 'pixels', ...
    'Position', [220 8 65 28], 'String', 'Logo', 'Tag', 'logobutton', ...
    'Callback', @zef_logoplot);

set(zef.h_loop_movie_count, 'String', num2str(zef.loop_movie_count));

zef.h_compartment_visible_color = zef_colored_list('create', ls, ...
    [10 28 150 110], 'compartment_visible_color', ...
    'Callback', 'zef_set_compartment_color; zef_update;', ...
    'Multiselect', false, ...
    'Trigger', 'buttondown');
zef.h_sensor_visible_color = zef_colored_list('create', ls, ...
    [170 28 150 110], 'sensor_visible_color', ...
    'Callback', 'zef_set_sensor_color; zef_update;', ...
    'Multiselect', true, ...
    'Trigger', 'buttondown', ...
    'ShowSwatches', false, ...
    'ShowChecks', true);
zef.h_system_information = zef_colored_list('create', ls, ...
    [330 28 150 110], 'system_information', ...
    'ShowSwatches', false);
if make_shell
    try
        zef.h_system_information.Visible = 'off';
        info_host = zef.h_system_information.Parent;
        if ~isempty(info_host) && info_host ~= ls
            info_host.Visible = 'off';
        end
    catch
    end
end

uicontrol('Parent', ls, 'Units', 'pixels', 'HorizontalAlignment', 'left', ...
    'String', 'Compartments', 'Style', 'text', 'Position', [10 140 150 18], ...
    'Tag', 'label_compartments', 'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Parent', ls, 'Units', 'pixels', 'HorizontalAlignment', 'left', ...
    'String', 'Sensors', 'Style', 'text', 'Position', [170 140 150 18], ...
    'Tag', 'label_sensors', 'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Parent', ls, 'Units', 'pixels', 'HorizontalAlignment', 'left', ...
    'String', 'Details', 'Style', 'text', 'Position', [330 140 150 18], ...
    'Tag', 'label_details', 'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', 'Copyright © 2018– Sampsa Pursiainen & ZI Development Team', ...
    'HorizontalAlignment', 'left', 'Position', [10 4 470 16], 'Tag', 'copyright_text', ...
    'BackgroundColor', zef_ui_theme_local.color.panel);

uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', '0', 'HorizontalAlignment', 'right', 'FontWeight', 'bold', ...
    'Position', [120 140 40 18], 'Tag', 'status_compartments_count', ...
    'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', '0', 'HorizontalAlignment', 'right', 'FontWeight', 'bold', ...
    'Position', [270 140 40 18], 'Tag', 'status_sensors_count', ...
    'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', 'Ready', 'HorizontalAlignment', 'right', 'FontWeight', 'bold', ...
    'Position', [400 4 80 16], 'Tag', 'status_ready', ...
    'ForegroundColor', zef_ui_theme_local.color.ready, ...
    'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Style', 'pushbutton', 'Parent', ls, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'status_ready_dot', ...
    'BackgroundColor', zef_ui_theme_local.color.panelAlt);
uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'status_sep_1', ...
    'BackgroundColor', zef_ui_theme_local.color.border);
uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'status_sep_2', ...
    'BackgroundColor', zef_ui_theme_local.color.border);
uicontrol('Style', 'text', 'Parent', ls, 'Units', 'pixels', ...
    'String', {'Nodes: 0'; 'Tetrahedra: 0'; 'Visualization: -'; 'Scale: Linear'}, ...
    'Max', 4, 'Min', 0, 'HorizontalAlignment', 'left', 'Tag', 'status_details_text', ...
    'Visible', 'off', 'Position', [1 1 1 1], ...
    'BackgroundColor', zef_ui_theme_local.color.panel, ...
    'ForegroundColor', zef_ui_theme_local.color.text);
uicontrol('Style', 'pushbutton', 'Parent', ls, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'status_ready_pill', ...
    'BackgroundColor', zef_ui_theme_local.color.panelAlt);
uicontrol('Style', 'pushbutton', 'Parent', ls, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'status_comp_icon', ...
    'BackgroundColor', zef_ui_theme_local.color.panel);
uicontrol('Style', 'pushbutton', 'Parent', ls, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'status_sens_icon', ...
    'BackgroundColor', zef_ui_theme_local.color.panel);

zef = zef_update_fig_details(zef);

set(zef.h_zeffiro, 'HandleVisibility', 'on');
set(zef.h_zeffiro, 'WindowButtonDownFcn', 'zef.h_zeffiro = zef.h_zeffiro; zef.h_axes1 = zef_ui_axes(zef.h_zeffiro);');

if make_shell
    zef_ui_shell('build', zef.h_zeffiro);
    zef.h_zeffiro.CloseRequestFcn = 'zef_close_all;';
    zef.h_zeffiro.DeleteFcn = '';
end

zef.h_zeffiro.GraphicsSmoothing = 'off';

h_loop_count = findall(zef.h_zeffiro, 'Tag', 'loop_count');
if ~isempty(h_loop_count)
    loop_str = get(h_loop_count(1), 'String');
    if iscell(loop_str)
        loop_str = loop_str{1};
    end
    set(h_loop_count(1), 'UserData', str2double(loop_str));
end
h_loop_movie = findall(zef.h_zeffiro, 'Tag', 'loop_movie');
if ~isempty(h_loop_movie)
    set(h_loop_movie(1), 'UserData', get(h_loop_movie(1), 'Value'));
end

set(zef.h_zeffiro, 'PaperPosition', [0 0 zef.snapshot_horizontal_resolution / 200 zef.snapshot_vertical_resolution / 200]);
set(zef.h_zeffiro, 'PaperSize', [zef.snapshot_vertical_resolution / 200 zef.snapshot_horizontal_resolution / 200]);

if zef.clear_axes1
    zef.h_colorbar = findobj(zef.h_zeffiro, 'Tag', 'Colorbar');
    if ~isempty(zef.h_colorbar)
        colorbar(zef.h_colorbar, 'delete');
    end
else
    zef.clear_axes1 = 1;
end

if isfield(zef, 'zeffiro_current_size')
    if ~iscell(zef.zeffiro_current_size)
        zef = rmfield(zef, 'zeffiro_current_size');
    end
end

% Keep the primary unified window untitled-by-index. Extra Figure-tool
% copies (imported .fig, a second view) still get " 2", " 3", ...
if zef_fig_num > 1
    set(zef.h_zeffiro, 'Name', ['ZEFFIRO Interface: Figure tool ' num2str(zef_fig_num)]);
else
    set(zef.h_zeffiro, 'Name', 'ZEFFIRO Interface: Figure tool');
end

if ~ismember('ZefFig', properties(zef.h_zeffiro))
    addprop(zef.h_zeffiro, 'ZefFig');
end
set(zef.h_zeffiro, 'ZefFig', zef_fig_num);

zef.h_zeffiro.SizeChangedFcn = @(src, evt) zef_figure_tool_layout(src, 'defer');
if make_shell
    zef_ui_apply_size(zef.h_zeffiro, zef_ui_theme_local.space.shellDefW, ...
        zef_ui_theme_local.space.shellDefH, zef_ui_theme_local.space.shellMinW, ...
        zef_ui_theme_local.space.shellMinH);
else
    zef_ui_apply_size(zef.h_zeffiro, 900, 720, 760, 580);
end
try
    zef_ui_place_window(zef.h_zeffiro);
catch
end
zef_ui_apply_theme(zef.h_zeffiro, zef_ui_theme_local);
try
    if isfield(zef, 'h_zeffiro_menu') && isvalid(zef.h_zeffiro_menu)
        zef_ui_shell('bind', zef);
    end
catch
end

zef = rmfield(zef, 'size_temp');
clear zef_ui_theme_local sb ls;

zef_logoplot;

if isfield(zef, 'h_zeffiro_menu') && isvalid(zef.h_zeffiro_menu)
    zef.h_zeffiro.Visible = zef.use_display;
else
    zef.h_zeffiro.Visible = 'off';
end
zef_window_manager('standalone', zef.h_zeffiro);

try
    assignin('base', 'zef', zef);
catch
end

zef.h_axes1.Units = 'pixels';
zef_figure_tool_layout(zef.h_zeffiro);
try
    setappdata(zef.h_zeffiro, 'ZefUiThemed', true);
    zef_ui_interact(zef.h_zeffiro);
catch
end

function zef_logoplot(o, e, h) %#ok<INUSD>

if nargin == 0
    h_axes = evalin('caller', 'zef.h_axes1');
else
    h_fig = ancestor(o, 'figure');
    h_axes = zef_ui_axes(h_fig);
end
if isempty(h_axes) || ~isvalid(h_axes(1))
    return
end
h_axes = h_axes(1);

bg = [1 1 1];
try
    th = zef_ui_theme();
    bg = th.color.axesBg;
catch
end

img = [];
try
    img = local_logo_image(bg);
catch
    try
        img = imread('zeffiro_interface_compass.png', 'BackgroundColor', bg);
    catch
    end
end
if isempty(img)
    return
end

cla(h_axes, 'reset');
try
    if isappdata(h_axes, 'ZefHasVolumePlot')
        rmappdata(h_axes, 'ZefHasVolumePlot');
    end
    if isappdata(h_axes, 'ZefAxesDressed')
        rmappdata(h_axes, 'ZefAxesDressed');
    end
    if isappdata(h_axes, 'ZefLogoSlot')
        rmappdata(h_axes, 'ZefLogoSlot');
    end
catch
end
try
    h_fig_logo = ancestor(h_axes, 'figure');
    zef_figure_interact(h_fig_logo, 'set', 'none');
    zef_figure_interact(h_fig_logo, 'forget_home');
catch
end
h_axes.Tag = 'axes1';
imh = image(h_axes, img);
try
    imh.Tag = 'zef_logo_img';
    setappdata(imh, 'ZefLogoSrc', im2double(img));
catch
end
h_axes.YDir = 'reverse';
h_axes.XTick = [];
h_axes.YTick = [];
h_axes.Box = 'off';
h_axes.Color = bg;
try
    h_axes.XColor = 'none';
    h_axes.YColor = 'none';
catch
end
try
    disableDefaultInteractivity(h_axes);
catch
end
try
    if isempty(h_axes.Toolbar)
        axtoolbar(h_axes, {'restoreview'});
    end
catch
end
try
    h_axes.Toolbar.Visible = 'off';
catch
end
h_axes.Visible = 'on';
try
    tt = findall(ancestor(h_axes, 'figure'), 'Tag', 'time_text');
    if ~isempty(tt) && isvalid(tt(1))
        set(tt(1), 'String', '', 'Visible', 'off');
    end
catch
end
try
    delete(h_axes.Legend);
    delete(h_axes.XLabel);
    delete(h_axes.YLabel);
    delete(h_axes.ZLabel);
catch
end

try
    if nargin > 0
        zef_figure_tool_layout(ancestor(h_axes, 'figure'));
    end
catch
end
h_axes.Tag = 'axes1';

end

function img = local_logo_image(bg)

persistent logo_bg logo_img
bg = reshape(double(bg(1:3)), 1, 3);
if ~isempty(logo_img) && isequal(logo_bg, bg)
    img = logo_img;
    return
end

fname = 'zeffiro_interface_compass.png';
alpha = [];
try
    [img, ~, alpha] = imread(fname);
catch
    img = imread(fname, 'BackgroundColor', bg);
end
if size(img, 3) == 1
    img = repmat(img, [1 1 3]);
end
if ~isempty(alpha)
    a = im2double(alpha);
    if size(a, 3) > 1
        a = a(:, :, 1);
    end
    bg8 = reshape(double(uint8(max(0, min(255, round(255 * bg))))), 1, 1, 3);
    img = uint8(double(img) .* a + bg8 .* (1 - a));
end
tol = 14;
bg8 = reshape(double(uint8(max(0, min(255, round(255 * bg))))), 1, 1, 3);
mask = max(abs(double(img) - bg8), [], 3) > tol;
white = max(abs(double(img) - 255), [], 3) < 8;
mask = mask & ~white;
if ~any(mask(:))
    logo_bg = bg;
    logo_img = img;
    return
end
[r, c] = find(mask);
pad = 12;
r1 = max(1, min(r) - pad);
r2 = min(size(img, 1), max(r) + pad);
c1 = max(1, min(c) - pad);
c2 = min(size(img, 2), max(c) + pad);
img = img(r1:r2, c1:c2, :);
bg8 = uint8(max(0, min(255, round(255 * bg))));
near_white = max(abs(double(img) - 255), [], 3) < 28;
for k = 1:size(img, 3)
    ch = img(:, :, k);
    ch(near_white) = bg8(k);
    img(:, :, k) = ch;
end
logo_bg = bg;
logo_img = img;

end
