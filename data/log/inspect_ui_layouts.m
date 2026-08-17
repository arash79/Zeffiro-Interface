function inspect_ui_layouts()
%INSPECT_UI_LAYOUTS  Snapshot core windows for layout review.

out = fullfile(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(out, '..', '..', 'src', 'gui')));
addpath(fullfile(out, '..', '..', 'assets', 'fig'));

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
uicontrol(sb, 'Style', 'edit', 'Tag', 'loop_count', 'String', '1');
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
zef_colored_list('set', findall(f, 'Tag', 'compartment_visible_color'), {'White matter', 'Gray matter', 'CSF'}, [0.9 0.9 0.85; 0.7 0.55 0.5; 0.6 0.75 0.85]);
zef_colored_list('set', findall(f, 'Tag', 'sensor_visible_color'), {'EEG', 'MEG mag.'}, [0.2 0.6 0.55; 0.85 0.45 0.2]);
zef_colored_list('set', h_det, {'Nodes: 0', 'Tetrahedra: 0', 'Visualization:'}, zeros(3, 3));
ax = findall(f, 'Tag', 'axes1');
try
    img = imread(fullfile(out, '..', '..', 'assets', 'fig', 'zeffiro_interface_compass.png'));
    % Approximate the runtime crop so the inspect snapshot matches logoplot.
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
drawnow;
pause(0.2);
local_snap(f, fullfile(out, 'inspect_figure_tool.png'));
lp = findall(f, 'Tag', 'figure_lists');
sp = findall(f, 'Tag', 'figure_sidebar');
fprintf('figure lists_h=%g sidebar=%gx%g axes=%s\n', lp(1).Position(4), ...
    sp(1).Position(3), sp(1).Position(4), mat2str(findall(f, 'Tag', 'axes1').Position));
for tg = ["lightsselection","colormapselection","colorscaleselection"]
    p = findall(f, 'Tag', char(tg));
    fprintf('  %s pos=%s right=%g sidebar_inner=%g\n', char(tg), mat2str(p(1).Position), ...
        p(1).Position(1)+p(1).Position(3), sp(1).Position(3)-10);
end
hdr = findall(f, 'Tag', 'section_color');
fprintf('  color_header h=%g y=%g sidebar_h=%g\n', hdr(1).Position(4), hdr(1).Position(2), sp(1).Position(4));
sl = findall(f, 'Tag', 'slider');
lights = findall(f, 'Tag', 'lightsselection');
cmap = findall(f, 'Tag', 'colormapselection');
fprintf('  slider_h=%g slider_y=%g popup_h=%g popup_gap=%g\n', sl(1).Position(4), sl(1).Position(2), ...
    lights(1).Position(4), lights(1).Position(2) - (cmap(1).Position(2) + cmap(1).Position(4)));
lp_ed = findall(f, 'Tag', 'loop_count');
if ~isempty(lp_ed)
    fprintf('  loop_count pos=%s\n', mat2str(lp_ed(1).Position));
end
comp = findall(f, 'Tag', 'compartment_visible_color');
if ~isempty(comp)
    host = comp(1);
    try
        if strcmpi(char(host.Type), 'uihtml') && isvalid(host.Parent) ...
                && host.Parent ~= f
            host = host.Parent;
        end
    catch
    end
    fprintf('  list_host h=%g lists_h=%g\n', host.Position(4), lp(1).Position(4));
end
f.Position(3:4) = [760 580];
zef_figure_tool_layout(f);
drawnow;
pause(0.15);
local_snap(f, fullfile(out, 'inspect_figure_tool_small.png'));
fprintf('figure small lists_h=%g sidebar_h=%g\n', findall(f, 'Tag', 'figure_lists').Position(4), ...
    findall(f, 'Tag', 'figure_sidebar').Position(4));
f.Position(3:4) = [1100 820];
zef_figure_tool_layout(f);
drawnow;
pause(0.15);
local_snap(f, fullfile(out, 'inspect_figure_tool_large.png'));
extra = {[760 580], [1100 500], [880 900], [1200 520]};
extra_name = {'min', 'wideshort', 'tall', 'wideshort2'};
for e = 1:numel(extra)
    f.Position(3:4) = extra{e};
    zef_figure_tool_layout(f);
    drawnow;
    pause(0.12);
    local_snap(f, fullfile(out, ['inspect_figure_tool_' extra_name{e} '.png']));
    sl = findall(f, 'Tag', 'slider');
    lights = findall(f, 'Tag', 'lightsselection');
    cmap = findall(f, 'Tag', 'colormapselection');
    fprintf('figure %s lists_h=%g sidebar_h=%g slider_h=%g popup_gap=%g\n', extra_name{e}, ...
        findall(f, 'Tag', 'figure_lists').Position(4), ...
        findall(f, 'Tag', 'figure_sidebar').Position(4), sl(1).Position(4), ...
        lights(1).Position(2) - (cmap(1).Position(2) + cmap(1).Position(4)));
end
close(f);

apps = { ...
    @zef_segmentation_tool_app_exported, 'h_zeffiro_window_main', [1280 620], 'inspect_segmentation.png'; ...
    @zef_mesh_tool_app_exported, 'h_mesh_tool', [780 500], 'inspect_mesh_tool.png'; ...
    @zef_mesh_visualization_tool_app_exported, 'h_mesh_visualization_tool', [700 620], 'inspect_mesh_vis.png'; ...
    @zef_menu_tool_app_exported, 'h_zeffiro_menu', [800 40], 'inspect_menu.png'};
for i = 1:size(apps, 1)
    app = apps{i, 1}();
    h = app.(apps{i, 2});
    h.Visible = 'on';
    zef = struct();
    pr = properties(app);
    for k = 1:numel(pr)
        try
            zef.(pr{k}) = app.(pr{k});
        catch
        end
    end
    zef = zef_ui_tag_handles(zef);
    assignin('base', 'zef', zef);
    def = apps{i, 3};
    if ~contains(h.Name, 'Menu')
        zef_ui_apply_size(h, def(1), def(2), round(0.85 * def(1)), round(0.85 * def(2)));
        zef_ui_ready(h);
    else
        h.Position(3) = 680;
        h.Position(4) = 40;
        zef_layout_menu_tool(h);
    end
    if contains(h.Name, 'Segmentation')
        local_fill_segmentation(h);
        hdr = findall(h, 'Tag', 'zef_seg_header');
        if ~isempty(hdr)
            try
                fprintf('  header cols=%s\n', strjoin(string(hdr(1).ColumnWidth), ','));
            catch
            end
        end
        logo = findall(h, 'Tag', 'h_axes2');
        tagf = findall(h, 'Tag', 'h_project_tag');
        if ~isempty(logo)
            fprintf('  logo pos=%s vis=%s align=%s\n', mat2str(logo(1).Position), ...
                char(string(logo(1).Visible)), char(string(logo(1).HorizontalAlignment)));
        end
        if ~isempty(tagf)
            fprintf('  project_tag pos=%s\n', mat2str(tagf(1).Position));
        end
    elseif contains(h.Name, 'Mesh tool') && ~contains(h.Name, 'visualization')
        local_fill_mesh_tool(h);
    end
    drawnow;
    pause(0.3);
    try
        zef_ui_adapt_grid(h);
        drawnow;
        pause(0.1);
    catch
    end
    local_snap(h, fullfile(out, apps{i, 4}));
    scr = 'n/a';
    try
        scr = char(h.Scrollable);
    catch
    end
    fprintf('%s size=%gx%g scroll=%s\n', h.Name, h.Position(3), h.Position(4), scr);
    if contains(h.Name, 'Mesh visualization')
        leftg = findall(h, 'Tag', 'zef_mv_left');
        clipg = findall(h, 'Tag', 'zef_mv_clip');
        if ~isempty(leftg)
            fprintf('  left rows=%s pos=%s\n', strjoin(string(leftg(1).RowHeight), ','), mat2str(leftg(1).Position));
        end
        if ~isempty(clipg)
            fprintf('  clip pos=%s rows=%s\n', mat2str(clipg(1).Position), strjoin(string(clipg(1).RowHeight), ','));
        end
        sc = findall(h, 'Tag', 'h_show_contour');
        if ~isempty(sc)
            try
                fprintf('  contour_array parent=%s layout=%s\n', class(sc(1).Parent), ...
                    mat2str([sc(1).Layout.Row, sc(1).Layout.Column]));
            catch
            end
        end
    end
    tbls = findall(h, 'Type', 'uitable');
    for k = 1:numel(tbls)
        try
            cw = tbls(k).ColumnWidth;
            bits = cell(size(cw));
            for c = 1:numel(cw)
                if isnumeric(cw{c})
                    bits{c} = num2str(cw{c});
                else
                    bits{c} = char(string(cw{c}));
                end
            end
            parent_w = NaN;
            try
                p = tbls(k).Parent;
                p.Units = 'pixels';
                parent_w = p.Position(3);
            catch
            end
            fprintf('  table %s pos=%gx%g parent_w=%g cols=%s sum=%g names=%s\n', ...
                char(string(tbls(k).Tag)), tbls(k).Position(3), tbls(k).Position(4), ...
                parent_w, strjoin(bits, ','), local_col_sum(cw), ...
                strjoin(cellstr(string(tbls(k).ColumnName)), '|'));
        catch err
            fprintf('  table dump skip: %s\n', err.message);
        end
    end
    if ~contains(h.Name, 'Menu')
        mins = [round(0.85 * def(1)), round(0.85 * def(2))];
        if isappdata(h, 'ZefMinSize')
            mins = getappdata(h, 'ZefMinSize');
        end
        h.Position(3:4) = mins;
        drawnow;
        try
            zef_ui_adapt_grid(h);
        catch
        end
        drawnow;
        pause(0.2);
        [~, base, ext] = fileparts(apps{i, 4});
        local_snap(h, fullfile(out, [base '_small' ext]));
        fprintf('  small=%gx%g\n', h.Position(3), h.Position(4));
        tbls = findall(h, 'Type', 'uitable');
        for k = 1:numel(tbls)
            try
                cw = tbls(k).ColumnWidth;
                bits = cell(size(cw));
                for c = 1:numel(cw)
                    if isnumeric(cw{c})
                        bits{c} = num2str(cw{c});
                    else
                        bits{c} = char(string(cw{c}));
                    end
                end
                fprintf('  small table %s pos_w=%g cols=%s sum=%g\n', char(string(tbls(k).Tag)), ...
                    tbls(k).Position(3), strjoin(bits, ','), local_col_sum(cw));
            catch
            end
        end
        h.Position(3:4) = [round(1.15 * def(1)), round(1.2 * def(2))];
        drawnow;
        try
            zef_ui_adapt_grid(h);
        catch
        end
        drawnow;
        pause(0.2);
        local_snap(h, fullfile(out, [base '_large' ext]));
        fprintf('  large=%gx%g\n', h.Position(3), h.Position(4));
        if contains(h.Name, 'Segmentation')
            extra = {[1600 520], [1020 780], [1480 500], [1100 900]};
            extra_name = {'wideshort', 'tall', 'ultrawide', 'portrait'};
            for e = 1:numel(extra)
                h.Position(3:4) = extra{e};
                drawnow;
                try
                    zef_ui_adapt_grid(h);
                catch
                end
                drawnow;
                pause(0.15);
                local_snap(h, fullfile(out, [base '_' extra_name{e} ext]));
                fprintf('  %s=%gx%g\n', extra_name{e}, h.Position(3), h.Position(4));
                tbls = findall(h, 'Type', 'uitable');
                for k = 1:numel(tbls)
                    try
                        cw = tbls(k).ColumnWidth;
                        bits = cell(size(cw));
                        for c = 1:numel(cw)
                            if isnumeric(cw{c})
                                bits{c} = num2str(cw{c});
                            else
                                bits{c} = char(string(cw{c}));
                            end
                        end
                        fprintf('    %s pos=%gx%g cols=%s\n', char(string(tbls(k).Tag)), ...
                            tbls(k).Position(3), tbls(k).Position(4), strjoin(bits, ','));
                    catch
                    end
                end
            end
        end
    end
end

dlg = uifigure('Visible', 'on', 'Name', 'ZEFFIRO Interface: Graphics processing options', ...
    'Position', [80 80 420 380]);
uilabel(dlg, 'Text', 'Colormap size:', 'Position', [20 300 140 22]);
uieditfield(dlg, 'Position', [180 300 80 22]);
uilabel(dlg, 'Text', 'Streamline width:', 'Position', [20 270 140 22]);
uieditfield(dlg, 'Position', [180 270 80 22]);
uilabel(dlg, 'Text', 'Cone scale:', 'Position', [20 240 140 22]);
uieditfield(dlg, 'Position', [180 240 80 22]);
uibutton(dlg, 'Text', 'Apply');
zef_layout_form_dialog(dlg);
zef_ui_apply_theme(dlg);
zef_ui_ready(dlg);
drawnow;
pause(0.2);
local_snap(dlg, fullfile(out, 'inspect_form_dialog.png'));
fprintf('form dialog %gx%g\n', dlg.Position(3), dlg.Position(4));
try
    g = findall(dlg, 'Type', 'uigridlayout');
    for i = 1:numel(g)
        fprintf('  form grid %d size=%s cols=%s pad=%s\n', i, mat2str(size(g(i).ColumnWidth)), ...
            strjoin(string(g(i).ColumnWidth), ','), mat2str(g(i).Padding));
    end
catch
end
close(dlg);

tblf = uifigure('Visible', 'on', 'Name', 'ZEFFIRO Interface: System settings', ...
    'Position', [80 80 500 360]);
uitable(tblf, 'Data', {1, 2; 3, 4}, 'ColumnName', {'A', 'B'});
uibutton(tblf, 'Text', 'Save');
zef_layout_table_dialog(tblf);
zef_ui_apply_theme(tblf);
drawnow;
pause(0.2);
local_snap(tblf, fullfile(out, 'inspect_table_dialog.png'));
fprintf('table dialog %gx%g\n', tblf.Position(3), tblf.Position(4));
close(tblf);

fprintf('done\n');
end

function local_fill_segmentation(h)

ct = findall(h, 'Tag', 'h_compartment_table');
if ~isempty(ct)
    ct(1).ColumnName = {'Index', 'On', 'Name', 'Visible', 'Surface nodes', ...
        'Surface triangles', 'Merge', 'Invert normal', 'Activity', 'Electrical conductivity'};
    ct(1).Data = { ...
        1, true, 'White matter', true, 45210, 90420, true, false, 'Constrained field', '0.14'; ...
        2, true, 'Gray matter', true, 38102, 76204, true, false, 'Unconstrained field', '0.33'; ...
        3, true, 'CSF', true, 12004, 24008, true, false, 'Inactive', '1.79'; ...
        4, true, 'Skull', true, 8900, 17800, true, false, 'Inactive', '0.006'; ...
        5, true, 'Scalp', true, 7200, 14400, true, false, 'Inactive', '0.43'; ...
        6, true, 'CTX_BAs_L_thalamic', true, 5100, 10200, false, false, 'Active surface', '0.33'; ...
        7, true, 'CTX_CA1_L_hippocampus', true, 4800, 9600, false, false, 'Active surface', '0.33'};
end
st = findall(h, 'Tag', 'h_sensors_table');
if ~isempty(st)
    st(1).ColumnName = {'ID', 'Name', 'Modality', 'On', 'Visible', 'Tags', 'Points', 'Directions'};
    st(1).Data = {1, 'Electrodes', 'Scalar field', true, true, true, true, true};
end
tr = findall(h, 'Tag', 'h_transform_table');
if ~isempty(tr)
    tr(1).Data = {1, 'Transform 1'};
end
pr = findall(h, 'Tag', 'h_parameters_table');
if ~isempty(pr)
    pr(1).ColumnName = {'Parameter', 'Value'};
    pr(1).Data = {'Affine transform', '[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]'; ...
        'Scale', '1.0000'; 'X-shift', '0.0000'; 'Y-shift', '0.0000'};
end
nt = findall(h, 'Tag', 'h_sensors_name_table');
if ~isempty(nt)
    rows = cell(24, 3);
    for i = 1:24
        rows{i, 1} = i;
        rows{i, 2} = sprintf('EEG_%02d', i);
        rows{i, 3} = true;
    end
    nt(1).ColumnName = {'ID', 'Tag', 'Visible'};
    nt(1).Data = rows;
end
info = findall(h, 'Tag', 'h_project_information');
if ~isempty(info)
    info(1).Items = { ...
        'App folder: /Users/hsc476/Projects/MainZeffiroProject'; ...
        'Current path: /Users/hsc476/Projects/MainZeffiroProject/data'; ...
        'Project file: default_project.mat'; ...
        'Project folder: /Users/hsc476/Projects/MainZeffiroProject/data'; ...
        'Number of nodes: 0'; 'Number of tetrahedra: 0'};
end
notes = findall(h, 'Tag', 'h_project_notes');
if ~isempty(notes)
    notes(1).Value = 'Project notes go here.';
end
drawnow;
zef_ui_adapt_grid(h);

end

function local_fill_mesh_tool(h)

t = findall(h, 'Tag', 'h_forward_simulation_table');
if ~isempty(t)
    t(1).ColumnName = {'Name', 'Description', 'Script'};
    t(1).Data = { ...
        'Lead field', 'EEG forward map', 'zef_eeg_lead_field'; ...
        'Source space', 'Cortical sources', 'zef_source_space'};
    zef_ui_fit_table(t(1));
end

end

function local_snap(h, file)
try
    exportapp(h, file);
catch
    exportgraphics(h, file);
end
end

function s = local_col_sum(cw)
s = 0;
for i = 1:numel(cw)
    if isnumeric(cw{i})
        s = s + cw{i};
    end
end
end
