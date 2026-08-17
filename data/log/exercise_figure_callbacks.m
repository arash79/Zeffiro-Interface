% Exercise figure-tool callbacks after cla('reset') drops Tag='axes1'.
addpath(genpath('src/gui'));
addpath(pwd);
addpath('assets/fig');

f = figure('Visible', 'off', 'Units', 'pixels', 'Position', [40 40 900 680], ...
    'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
sb = uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', 'Position', [650 200 292 400]);
ax = uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', 'Position', [20 200 500 400]);
uicontrol(sb, 'Style', 'slider', 'Tag', 'colorscale_min_slider', 'Min', -1, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'colorscale_max_slider', 'Min', -1, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_ambience_slider', 'Min', 0, 'Max', 1, 'Value', 0.5);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_diffusion_slider', 'Min', 0, 'Max', 1, 'Value', 0.5);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_specular_slider', 'Min', 0, 'Max', 1, 'Value', 0.1);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_contrast_slider', 'Min', -1, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_brightness_slider', 'Min', 0, 'Max', 5, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_zoom_slider', 'Min', 0.1, 'Max', 100, 'Value', 7);
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_surface_slider', 'Min', 0, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_sensor_slider', 'Min', 0, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_cones_slider', 'Min', 0, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_additional_slider', 'Min', 0, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_reconstruction_slider', 'Min', 0, 'Max', 1, 'Value', 0);
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'colormapselection', 'String', {'Monterosso'}, 'Value', 1);
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'colorscaleselection', 'String', {'Linear', 'Logarithmic'}, 'Value', 1);
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'lightsselection', 'String', {'Default', 'Off'}, 'Value', 1);
uicontrol(f, 'Style', 'text', 'Tag', 'time_text', 'String', '');

cla(ax, 'reset');
assert(~strcmp(char(ax.Tag), 'axes1'), 'cla reset should drop Tag');

zef = struct();
zef.h_zeffiro = f;
zef.h_axes1 = ax;
zef.show_contour = false;
zef.update_lights = 1;
zef.movie_fps = 30;
zef.stop_movie = 0;
zef.orbit_1 = 0;
zef.orbit_2 = 0;
zef.store_cdata = true;
assignin('base', 'zef', zef);

h = zef_ui_axes(f);
assert(isvalid(h) && strcmp(h.Tag, 'axes1'));
h.CLim = [1 10];

zef_update_colorscale_min(f);
zef_update_colorscale_max(f);
zef_update_ambience(f);
zef_update_diffusion(f);
zef_update_specular(f);
zef_update_zoom(f);
zef_update_transparency_surface(f);
zef_update_transparency_sensor(f);
zef_update_transparency_cones(f);
zef_update_transparency_additional(f);
zef_update_transparency_reconstruction(f);
zef_update_colorscale(f);
zef_update_lights(f);
zef_play_cdata(1, 0.5);

fprintf('callback chain ok clim=%s tag=%s\n', mat2str(h.CLim), h.Tag);
close(f);
