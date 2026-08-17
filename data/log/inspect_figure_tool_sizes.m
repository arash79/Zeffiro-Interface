function inspect_figure_tool_sizes()
%INSPECT_FIGURE_TOOL_SIZES  Snapshot the figure tool across window sizes.

out = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(out, '..', '..', 'src', 'gui')));
addpath(fullfile(out, '..', '..', 'assets', 'fig'));

f = local_build(out);
sizes = { ...
    [900 720], 'inspect_figure_tool.png'; ...
    [760 580], 'inspect_figure_tool_min.png'; ...
    [760 580], 'inspect_figure_tool_small.png'; ...
    [1100 820], 'inspect_figure_tool_large.png'; ...
    [1100 500], 'inspect_figure_tool_wideshort.png'; ...
    [880 900], 'inspect_figure_tool_tall.png'};
for i = 1:size(sizes, 1)
    f.Position(3:4) = sizes{i, 1};
    zef_figure_tool_layout(f);
    drawnow;
    pause(0.15);
    local_snap(f, fullfile(out, sizes{i, 2}));
    sl = findall(f, 'Tag', 'slider');
    lights = findall(f, 'Tag', 'lightsselection');
    cmap = findall(f, 'Tag', 'colormapselection');
    scale = findall(f, 'Tag', 'colorscaleselection');
    sb = findall(f, 'Tag', 'figure_sidebar');
    ls = findall(f, 'Tag', 'figure_lists');
    fprintf('%s slider=%s popup_gap=%g popup_h=%g sidebar=%gx%g lists_h=%g\n', ...
        sizes{i, 2}, mat2str(sl(1).Position), ...
        lights(1).Position(2) - (cmap(1).Position(2) + cmap(1).Position(4)), ...
        lights(1).Position(4), sb(1).Position(3), sb(1).Position(4), ls(1).Position(4));
    fprintf('  lights=%s cmap=%s scale=%s\n', mat2str(lights(1).Position), ...
        mat2str(cmap(1).Position), mat2str(scale(1).Position));
end

close(f);
fprintf('done\n');
end

function f = local_build(out)
f = figure('Visible', 'on', 'Units', 'pixels', 'Position', [40 80 900 720], ...
    'MenuBar', 'none', 'Name', 'ZEFFIRO Interface: Figure tool', ...
    'AutoResizeChildren', 'off', 'Color', [0.97 0.975 0.978]);
sb = uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', 'Position', [650 200 292 400]);
ls = uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', 'Position', [20 12 500 118]);
uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', 'Position', [20 200 500 400]);
uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
    'Tag', 'togglecontrolsbutton', 'UserData', 1);
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Toggle edges', 'Tag', 'toggleedgesbutton');
uicontrol(sb, 'Style', 'text', 'String', 'Color', 'Tag', 'section_color');
uicontrol(sb, 'Style', 'text', 'String', 'Time', 'Tag', 'label_time');
uicontrol(sb, 'Style', 'slider', 'Tag', 'slider');
uicontrol(sb, 'Style', 'text', 'String', 'Color min', 'Tag', 'label_color_min');
uicontrol(sb, 'Style', 'slider', 'Tag', 'colorscale_min_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Color max', 'Tag', 'label_color_max');
uicontrol(sb, 'Style', 'slider', 'Tag', 'colorscale_max_slider');
uicontrol(sb, 'Style', 'text', 'String', 'View distance', 'Tag', 'label_distance');
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_zoom_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Transparency', 'Tag', 'section_transparency');
uicontrol(sb, 'Style', 'text', 'String', 'Reconstruction', 'Tag', 'label_transp_rec');
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_reconstruction_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Surface', 'Tag', 'label_transp_surf');
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_surface_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Sensors', 'Tag', 'label_transp_sens');
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_sensor_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Cones', 'Tag', 'label_transp_cones');
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_cones_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Additional', 'Tag', 'label_transp_add');
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_additional_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Lighting', 'Tag', 'section_lighting');
uicontrol(sb, 'Style', 'text', 'String', 'Brightness', 'Tag', 'label_brightness');
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_brightness_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Contrast', 'Tag', 'label_contrast');
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_contrast_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Ambient', 'Tag', 'label_ambience');
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_ambience_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Diffuse', 'Tag', 'label_diffusion');
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_diffusion_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Specular', 'Tag', 'label_specular');
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_specular_slider');
uicontrol(sb, 'Style', 'text', 'String', 'Appearance', 'Tag', 'section_appearance');
uicontrol(sb, 'Style', 'text', 'String', 'Lights', 'Tag', 'label_lights');
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'lightsselection', ...
    'String', {'Default', 'Lights off', 'Add X', 'Add Y', 'Add Z', 'Headlight'});
uicontrol(sb, 'Style', 'text', 'String', 'Colormap', 'Tag', 'label_colormap');
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'colormapselection', ...
    'String', {'Monterosso', 'Intensity I', 'Blue brain III', 'Parcellation'});
uicontrol(sb, 'Style', 'text', 'String', 'Scale', 'Tag', 'label_scale');
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'colorscaleselection', ...
    'String', {'Linear', 'Logarithmic'});
uicontrol(sb, 'Style', 'text', 'String', 'Loop', 'Tag', 'label_loop');
uicontrol(sb, 'Style', 'checkbox', 'Tag', 'loop_movie');
uicontrol(sb, 'Style', 'edit', 'Tag', 'loop_count', 'String', '5');
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Play', 'Tag', 'playbutton');
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Reset', 'Tag', 'resetbutton');
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Stop', 'Tag', 'stopbutton');
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Logo', 'Tag', 'logobutton');
uicontrol(ls, 'Style', 'text', 'String', 'Compartments', 'Tag', 'label_compartments');
uicontrol(ls, 'Style', 'text', 'String', 'Sensors', 'Tag', 'label_sensors');
uicontrol(ls, 'Style', 'text', 'String', 'Details', 'Tag', 'label_details');
uicontrol(ls, 'Style', 'text', 'String', 'Copyright', 'Tag', 'copyright_text');
zef_colored_list('create', ls, [10 28 150 80], 'compartment_visible_color');
zef_colored_list('create', ls, [170 28 150 80], 'sensor_visible_color');
h_det = zef_colored_list('create', ls, [330 28 150 80], 'system_information', 'ShowSwatches', false);
zef_colored_list('set', findall(f, 'Tag', 'compartment_visible_color'), ...
    {'White matter', 'Gray matter', 'CSF'}, [0.9 0.9 0.85; 0.7 0.55 0.5; 0.6 0.75 0.85]);
zef_colored_list('set', findall(f, 'Tag', 'sensor_visible_color'), {'EEG', 'MEG mag.'}, ...
    [0.2 0.6 0.55; 0.85 0.45 0.2]);
zef_colored_list('set', h_det, {'Nodes: 0', 'Tetrahedra: 0', 'Visualization:'}, zeros(3, 3));
ax = findall(f, 'Tag', 'axes1');
try
    img = imread(fullfile(out, '..', '..', 'assets', 'fig', 'zeffiro_interface_compass.png'));
    mask = max(abs(double(img) - 255), [], 3) > 12;
    if any(mask(:))
        [r, c] = find(mask);
        img = img(max(1, min(r)-12):min(size(img,1), max(r)+12), ...
            max(1, min(c)-12):min(size(img,2), max(c)+12), :);
        bg8 = uint8(round(255 * [0.970 0.975 0.978]));
        nw = max(abs(double(img) - 255), [], 3) < 18;
        for k = 1:size(img, 3)
            ch = img(:, :, k);
            ch(nw) = bg8(k);
            img(:, :, k) = ch;
        end
    end
    image(ax, img);
    axis(ax, 'image');
    ax.YDir = 'reverse';
    ax.XTick = [];
    ax.YTick = [];
    ax.Box = 'off';
    ax.Color = [0.970 0.975 0.978];
catch
end
zef_figure_tool_layout(f);
zef_ui_apply_theme(f);
zef_figure_tool_layout(f);
end

function local_snap(h, file)
try
    exportapp(h, file);
catch
    try
        exportgraphics(h, file);
    catch
        fr = getframe(h);
        imwrite(fr.cdata, file);
    end
end
end
