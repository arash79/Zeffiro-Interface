function zef_figure_tool_layout(h_fig)
%ZEF_FIGURE_TOOL_LAYOUT  Pixel layout for the Figure tool (design reference).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Places the 3-D axes, a card-style control sidebar, and the three
%   bottom lists. Called at creation and from SizeChangedFcn. Toggle
%   controls hides the sidebar and widens the axes.
%
%   zef_figure_tool_layout
%   zef_figure_tool_layout(h_fig)
%
%   See also zef_figure_tool, zef_toggle_figure_controls.

if nargin < 1 || isempty(h_fig)
    h_fig = [];
    try
        h_fig = evalin('base', 'zef.h_zeffiro');
    catch
    end
end
if isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end

if isappdata(h_fig, 'ZefLayoutBusy') && isequal(getappdata(h_fig, 'ZefLayoutBusy'), true)
    return
end
setappdata(h_fig, 'ZefLayoutBusy', true);

try
    local_layout(h_fig);
catch
end
setappdata(h_fig, 'ZefLayoutBusy', false);

end

function local_layout(h_fig)

theme = zef_ui_theme();
pad = theme.space.pad;
gap = theme.space.gap;
sidebar_w = theme.space.sidebarW;
btn_h = theme.space.btnH;

orig_units = h_fig.Units;
h_fig.Units = 'pixels';
fig_pos = h_fig.Position;
W = max(fig_pos(3), 1);
H = max(fig_pos(4), 1);

sidebar = zef_ui_find(h_fig, 'figure_sidebar');
lists = zef_ui_find(h_fig, 'figure_lists');
ax = zef_ui_find(h_fig, 'axes1');
tgb = zef_ui_find(h_fig, 'togglecontrolsbutton');

sidebar_on = true;
if ~isempty(tgb) && isprop(tgb, 'UserData') && isequal(tgb.UserData, 2)
    sidebar_on = false;
end

if ~isempty(sidebar) && isvalid(sidebar)
    sidebar.Units = 'pixels';
    sidebar.Visible = onoff(sidebar_on);
end
if ~isempty(lists) && isvalid(lists)
    lists.Units = 'pixels';
end

plot_min = 280;
if sidebar_on && W < pad + gap + sidebar_w + pad + plot_min
    sidebar_w = max(220, W - pad - gap - pad - plot_min);
end

% Native slider/popup stack is ~522 px. Lists take leftover
% height, then shrink first when the window is short so the
% sidebar never has to clip Java slider arrows.
needed_sidebar = 2 * pad + 2 * theme.space.btnH + 3 * gap ...
    + 4 * 22 + 14 * theme.space.sliderH + 14 * theme.space.sliderGap ...
    + 3 * theme.space.popupH + 2 * theme.space.rowGap + theme.space.row;
must_have = 2 * pad + 2 * 24 + 3 * gap ...
    + 4 * 20 + 14 * theme.space.sliderH ...
    + 3 * 20 + 2 * theme.space.rowGap + theme.space.row;
min_lists = 96;
if H < 640
    min_lists = 72;
end
if H <= 540
    min_lists = 32;
end
lists_h = min(theme.space.bottomH, max(min_lists, H - 2 * pad - gap - needed_sidebar));
lists_h = min(lists_h, max(min_lists, H - 2 * pad - gap - must_have));
content_bottom = pad + lists_h + gap;
content_h = max(180, H - content_bottom - pad);
if sidebar_on
    axes_w = max(180, W - pad - gap - sidebar_w - pad);
    sidebar_x = W - pad - sidebar_w;
else
    axes_w = max(180, W - 2 * pad);
    sidebar_x = W;
end
axes_h = content_h;
btn_h = min(theme.space.btnH, max(24, round(content_h * 0.06)));

if ~isempty(ax) && isvalid(ax)
    ax.Units = 'pixels';
    ax.Position = local_axes_position(ax, [pad, content_bottom, axes_w, axes_h]);
end

tt = zef_ui_find(h_fig, 'time_text');
if ~isempty(tt) && isvalid(tt)
    local_place_time_text(tt, theme, pad, content_bottom, axes_w, content_h);
end

cb = findall(h_fig, 'Tag', 'rightColorbar');
if ~isempty(cb) && isvalid(cb(1)) && sidebar_on
    try
        cb(1).Units = 'pixels';
        cb_w = 18;
        cb(1).Position = [pad + axes_w - cb_w - 4, content_bottom + 24, cb_w, max(80, axes_h - 48)];
    catch
    end
end

if ~isempty(lists) && isvalid(lists)
    lists.Position = [pad, pad, max(200, W - 2 * pad), lists_h];
    local_layout_lists(lists, theme);
end

if sidebar_on && ~isempty(sidebar) && isvalid(sidebar)
    sidebar.Position = [sidebar_x, content_bottom, sidebar_w, content_h];
    try
        sidebar.AutoResizeChildren = 'off';
        sidebar.Clipping = 'on';
        sidebar.Scrollable = 'off';
    catch
    end
    local_layout_sidebar(sidebar, theme, btn_h, pad, gap);
end

if ~isempty(tgb) && isvalid(tgb)
    tgb.Units = 'pixels';
    if sidebar_on && ~isempty(sidebar) && isvalid(sidebar)
        tgb.Parent = sidebar;
    else
        tgb.Parent = h_fig;
        tgb.Visible = 'on';
        tgb.Position = [W - pad - 128, H - pad - btn_h, 128, btn_h];
    end
end

h_fig.Units = orig_units;

end

function local_layout_sidebar(panel, theme, btn_h, pad, gap)

panel.Units = 'pixels';
p = panel.Position;
inner_w = max(40, p(3) - 2 * pad);
inner_h = p(4);
x0 = pad;
label_w = min(theme.space.labelW, max(72, round(inner_w * 0.40)));
popup_label_w = label_w;

play_y = 6;
loop_h = theme.space.row;
loop_y = play_y + btn_h + gap;
top_y = inner_h - pad - btn_h;
reserved_bottom = loop_y + loop_h + gap;
avail = max(80, top_y - gap - reserved_bottom);

n_slider = 14;
n_popup = 3;
n_headers = 4;
pack = local_pack_sidebar(avail, theme, n_slider, n_popup, n_headers);
header_h = pack.header_h;
header_gap = pack.header_gap;
header_above = pack.header_above;
popup_h = pack.popup_h;
popup_gap = pack.popup_gap;
slider_h = pack.slider_h;
slider_gap = pack.slider_gap;

y = top_y;
half = (inner_w - gap) / 2;
tgb = zef_ui_find(panel, 'togglecontrolsbutton');
if isempty(tgb)
    tgb = zef_ui_find(panel.Parent, 'togglecontrolsbutton');
end
if ~isempty(tgb) && isvalid(tgb)
    tgb.Units = 'pixels';
    tgb.Parent = panel;
    tgb.Position = [round(x0), round(y), round(half), round(btn_h)];
end
edges = zef_ui_find(panel, 'toggleedgesbutton');
if ~isempty(edges) && isvalid(edges)
    edges.Units = 'pixels';
    edges.Position = [round(x0 + half + gap), round(y), round(half), round(btn_h)];
end
y = y - gap;

y = local_header(panel, 'section_color', 'Color', x0, y, inner_w, theme, header_h, header_gap, header_above);
y = local_slider_row(panel, 'label_time', 'slider', 'Time', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_color_min', 'colorscale_min_slider', 'Color min', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_color_max', 'colorscale_max_slider', 'Color max', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_distance', 'update_zoom_slider', 'View distance', x0, y, inner_w, label_w, slider_h, slider_gap);

y = local_header(panel, 'section_transparency', 'Transparency', x0, y, inner_w, theme, header_h, header_gap, header_above);
y = local_slider_row(panel, 'label_transp_rec', 'transparency_reconstruction_slider', 'Reconstruction', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_transp_surf', 'transparency_surface_slider', 'Surface', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_transp_sens', 'transparency_sensor_slider', 'Sensors', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_transp_cones', 'transparency_cones_slider', 'Cones', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_transp_add', 'transparency_additional_slider', 'Additional', x0, y, inner_w, label_w, slider_h, slider_gap);

y = local_header(panel, 'section_lighting', 'Lighting', x0, y, inner_w, theme, header_h, header_gap, header_above);
y = local_slider_row(panel, 'label_brightness', 'update_brightness_slider', 'Brightness', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_contrast', 'update_contrast_slider', 'Contrast', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_ambience', 'update_ambience_slider', 'Ambient', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_diffusion', 'update_diffusion_slider', 'Diffuse', x0, y, inner_w, label_w, slider_h, slider_gap);
y = local_slider_row(panel, 'label_specular', 'update_specular_slider', 'Specular', x0, y, inner_w, label_w, slider_h, slider_gap);

y = local_header(panel, 'section_appearance', 'Appearance', x0, y, inner_w, theme, header_h, header_gap, header_above);
y = local_labeled_popup(panel, 'label_lights', 'lightsselection', 'Lights', x0, y, inner_w, popup_label_w, popup_h, popup_gap);
y = local_labeled_popup(panel, 'label_colormap', 'colormapselection', 'Colormap', x0, y, inner_w, popup_label_w, popup_h, popup_gap);
y = local_labeled_popup(panel, 'label_scale', 'colorscaleselection', 'Scale', x0, y, inner_w, popup_label_w, popup_h, popup_gap);

local_playback(panel, x0, inner_w, btn_h, loop_h, gap, play_y, loop_y, label_w);

end

function y = local_header(panel, tag, text, x, y, w, theme, header_h, header_gap, header_above)

if nargin < 8 || isempty(header_h)
    header_h = 20;
end
if nargin < 9 || isempty(header_gap)
    header_gap = 4;
end
if nargin < 10 || isempty(header_above)
    header_above = 4;
end
h = zef_ui_find(panel, tag);
y = y - header_above;
if isempty(h) || ~isvalid(h)
        y = y - header_h - header_gap;
    return
end
h.Units = 'pixels';
h.Position = [round(x), round(y - header_h), round(w), round(header_h)];
h.String = text;
h.HorizontalAlignment = 'left';
h.FontWeight = 'bold';
h.ForegroundColor = theme.color.header;
try
    h.FontUnits = 'pixels';
    h.FontSize = min(theme.font.size, max(10, header_h - 6));
catch
end
y = y - header_h - header_gap;

end

function pack = local_pack_sidebar(avail, theme, n_slider, n_popup, n_headers)

pack = struct();
pack.slider_h = theme.space.sliderH;
pack.slider_gap = theme.space.sliderGap;
pack.popup_h = theme.space.popupH;
pack.popup_gap = theme.space.rowGap;
pack.header_h = 18;
pack.header_gap = 3;
pack.header_above = 4;

    function u = used()
        u = n_headers * (pack.header_h + pack.header_gap + pack.header_above) ...
            + n_slider * (pack.slider_h + pack.slider_gap) ...
            + n_popup * pack.popup_h + max(0, n_popup - 1) * pack.popup_gap;
    end

while used() > avail
    if pack.header_above > 2
        pack.header_above = pack.header_above - 1;
    elseif pack.header_gap > 2
        pack.header_gap = pack.header_gap - 1;
    elseif pack.header_h > 16
        pack.header_h = pack.header_h - 1;
    elseif pack.popup_gap > 3
        pack.popup_gap = pack.popup_gap - 1;
    elseif pack.slider_gap > 1
        pack.slider_gap = pack.slider_gap - 1;
    elseif pack.popup_h > 20
        pack.popup_h = pack.popup_h - 1;
    elseif pack.slider_gap > 0
        pack.slider_gap = pack.slider_gap - 1;
    else
        break
    end
end

while pack.header_above < 6 && used() + 1 <= avail
    pack.header_above = pack.header_above + 1;
end
while pack.slider_gap < theme.space.sliderGap && used() + 1 <= avail
    pack.slider_gap = pack.slider_gap + 1;
end
while pack.popup_gap < theme.space.rowGap && used() + 1 <= avail
    pack.popup_gap = pack.popup_gap + 1;
end
pack.slider_gap = max(0, pack.slider_gap);
pack.popup_gap = max(3, pack.popup_gap);
pack.header_above = max(2, pack.header_above);

end

function y = local_slider_row(panel, label_tag, slider_tag, text, x, y, w, label_w, slider_h, slider_gap)

lab = zef_ui_find(panel, label_tag);
sl = zef_ui_find(panel, slider_tag);
row_y = y - slider_h;
if ~isempty(lab) && isvalid(lab)
    lab.Units = 'pixels';
    lab.String = text;
    lab.HorizontalAlignment = 'right';
    lab.Position = local_inside(x, row_y, label_w - 6, slider_h, x, w);
    try
        lab.FontUnits = 'pixels';
        lab.FontSize = min(12, max(9, slider_h - 4));
    catch
    end
end
if ~isempty(sl) && isvalid(sl)
    sl.Units = 'pixels';
    sl.Position = local_inside(x + label_w, row_y, w - label_w, slider_h, x, w);
end
y = row_y - slider_gap;

end

function y = local_labeled_popup(panel, label_tag, popup_tag, text, x, y, w, label_w, row_h, row_gap)

if nargin < 10 || isempty(row_gap)
    row_gap = 0;
end
lab = zef_ui_find(panel, label_tag);
pop = zef_ui_find(panel, popup_tag);
row_y = y - row_h;
if ~isempty(lab) && isvalid(lab)
    lab.Units = 'pixels';
    lab.String = text;
    lab.HorizontalAlignment = 'right';
    lab.Position = local_inside(x, row_y, label_w - 6, row_h, x, w);
    try
        lab.FontUnits = 'pixels';
        lab.FontSize = min(12, max(9, row_h - 4));
    catch
    end
end
if ~isempty(pop) && isvalid(pop)
    pop.Units = 'pixels';
    pop.Position = local_inside(x + label_w, row_y, w - label_w, row_h, x, w);
    try
        pop.FontUnits = 'pixels';
        pop.FontSize = max(10, min(11, row_h - 8));
        pop.HorizontalAlignment = 'left';
    catch
    end
end
y = row_y - row_gap;

end

function pos = local_inside(x, y, w, h, x0, inner_w)

right = x0 + inner_w;
w = min(max(24, w), max(24, right - x));
if x + w > right + 0.5
    x = max(x0, right - w);
end
pos = [round(x), round(y), round(w), round(h)];

end

function local_playback(panel, x, w, btn_h, row_h, gap, play_y, loop_y, label_w)

if nargin < 9 || isempty(label_w)
    label_w = 88;
end
loop_lab = zef_ui_find(panel, 'label_loop');
loop_cb = zef_ui_find(panel, 'loop_movie');
loop_ed = zef_ui_find(panel, 'loop_count');
if isempty(loop_ed) || ~isvalid(loop_ed)
    loop_ed = zef_ui_find(panel.Parent, 'loop_count');
end
row_y = loop_y;
ctrl_x = x + label_w;
if ~isempty(loop_lab) && isvalid(loop_lab)
    loop_lab.Units = 'pixels';
    loop_lab.String = 'Loop';
    loop_lab.HorizontalAlignment = 'right';
    loop_lab.Position = local_inside(x, row_y, label_w - 6, row_h, x, w);
end
if ~isempty(loop_cb) && isvalid(loop_cb)
    loop_cb.Units = 'pixels';
    loop_cb.Position = local_inside(ctrl_x + 4, row_y + 2, 22, max(14, row_h - 4), x, w);
end
if ~isempty(loop_ed) && isvalid(loop_ed)
    loop_ed.Units = 'pixels';
    edit_x = ctrl_x + 30;
    edit_w = max(52, x + w - edit_x);
    loop_ed.Position = local_inside(edit_x, row_y, edit_w, row_h, x, w);
end

btn_y = play_y;
btns = [local_btn(panel, 'resetbutton', 'Reset'), ...
    local_btn(panel, 'playbutton', 'Play'), ...
    local_btn(panel, 'stopbutton', 'Stop'), ...
    local_btn(panel, 'logobutton', 'Logo')];
valid = false(1, 4);
for i = 1:4
    valid(i) = ~(isempty(btns(i)) || ~isvalid(btns(i)));
end
n_btn = max(1, nnz(valid));
span = w - (n_btn - 1) * gap;
btn_w = floor(span / n_btn);
extra = span - n_btn * btn_w;
x_btn = x;
seen = 0;
for i = 1:4
    if ~valid(i)
        continue
    end
    seen = seen + 1;
    this_w = btn_w;
    if seen == n_btn
        this_w = btn_w + extra;
    end
    b = btns(i);
    b.Units = 'pixels';
    b.Parent = panel;
    b.Position = [round(x_btn), round(btn_y), round(this_w), round(btn_h)];
    x_btn = x_btn + this_w + gap;
end

end

function h = local_btn(panel, tag, str)

h = zef_ui_find(panel, tag);
if isempty(h) || ~isvalid(h)
    h = zef_ui_find(panel.Parent, tag);
end
if isempty(h) || ~isvalid(h)
    h = local_by_string(panel, str);
end
if isempty(h)
    h = gobjects(1);
end

end

function h = local_by_string(panel, str)

h = gobjects(0);
found = findall(panel, 'Style', 'pushbutton', '-or', 'Style', 'togglebutton');
for i = 1:numel(found)
    try
        if strcmp(char(found(i).String), str)
            h = found(i);
            return
        end
    catch
    end
end
found = findall(panel.Parent, 'Style', 'pushbutton', '-or', 'Style', 'togglebutton');
for i = 1:numel(found)
    try
        if strcmp(char(found(i).String), str)
            h = found(i);
            return
        end
    catch
    end
end

end

function local_layout_lists(panel, theme)

panel.Units = 'pixels';
p = panel.Position;
pad = 10;
gap = 10;
label_h = 18;
copy_h = 16;
label_gap = 4;
top_inset = 8;
inner_w = p(3) - 2 * pad;
inner_h = max(40, p(4) - pad - top_inset);
list_h = max(40, inner_h - label_h - copy_h - label_gap - 4);
weights = [0.38 0.31 0.31];
usable = max(120, inner_w - 2 * gap);

try
    panel.Clipping = 'on';
catch
end

labels = {'label_compartments', 'label_sensors', 'label_details'};
lists = {'compartment_visible_color', 'sensor_visible_color', 'system_information'};
titles = {'Compartments', 'Sensors', 'Details'};
x = pad;
label_y = pad + copy_h + list_h + label_gap;
if label_y + label_h > p(4) - top_inset
    label_y = max(pad, p(4) - top_inset - label_h);
    list_h = max(40, label_y - label_gap - copy_h - pad);
end
for i = 1:3
    col_w = usable * weights(i);
    lab = zef_ui_find(panel, labels{i});
    if isempty(lab)
        lab = zef_ui_find(panel.Parent, labels{i});
    end
    if ~isempty(lab) && isvalid(lab)
        lab.Units = 'pixels';
        lab.Parent = panel;
        lab.String = titles{i};
        lab.HorizontalAlignment = 'left';
        lab.Position = [x, label_y, col_w, label_h];
        try
            lab.FontUnits = 'pixels';
            lab.FontSize = min(12, max(10, label_h - 6));
            lab.FontWeight = 'bold';
        catch
        end
    end
    lst = zef_ui_find(panel, lists{i});
    if isempty(lst)
        lst = zef_ui_find(panel.Parent, lists{i});
    end
    if ~isempty(lst) && isvalid(lst)
        host = lst;
        try
            if strcmpi(char(lst.Type), 'uihtml') && ~isempty(lst.Parent) ...
                    && lst.Parent ~= panel.Parent && lst.Parent ~= panel
                host = lst.Parent;
            end
        catch
        end
        try
            if isprop(host, 'Units')
                host.Units = 'pixels';
            end
            host.Parent = panel;
            host.Position = [x, pad + copy_h + 6, col_w, max(48, list_h)];
            local_fill_list_host(host);
        catch
        end
    end
    x = x + col_w + gap;
end

copy = zef_ui_find(panel, 'copyright_text');
if isempty(copy)
    copy = zef_ui_find(panel.Parent, 'copyright_text');
end
if ~isempty(copy) && isvalid(copy)
    copy.Units = 'pixels';
    copy.Parent = panel;
    copy.Position = [pad, 12, inner_w, copy_h];
    copy.ForegroundColor = theme.color.textMuted;
    try
        copy.FontUnits = 'pixels';
        copy.FontSize = 11;
        copy.HorizontalAlignment = 'left';
        copy.FontWeight = 'normal';
    catch
    end
end

end

function pos = local_axes_position(ax, slot)

pos = slot;
if isempty(ax) || ~isvalid(ax)
    return
end
imgs = [];
try
    imgs = findall(ax, 'Type', 'image');
catch
end
if isempty(imgs)
    return
end
others = [];
try
    others = findall(ax, 'Type', 'patch', '-or', 'Type', 'surface', ...
        '-or', 'Type', 'line', '-or', 'Type', 'scatter');
catch
end
if ~isempty(others)
    return
end
cdata = [];
try
    cdata = imgs(1).CData;
catch
end
if isempty(cdata)
    return
end
ih = size(cdata, 1);
iw = size(cdata, 2);
if ih < 2 || iw < 2
    return
end
ar = iw / ih;
margin = max(8, min(18, round(0.03 * min(slot(3), slot(4)))));
uw = max(40, slot(3) - 2 * margin);
uh = max(40, slot(4) - 2 * margin);
if uh * ar <= uw
    h = uh;
    w = h * ar;
else
    w = uw;
    h = w / ar;
end
pos = [slot(1) + (slot(3) - w) / 2, slot(2) + (slot(4) - h) / 2, w, h];
try
    ax.Color = [0.970 0.975 0.978];
    ax.Box = 'off';
    ax.XTick = [];
    ax.YTick = [];
    ax.XColor = 'none';
    ax.YColor = 'none';
catch
end
try
    disableDefaultInteractivity(ax);
catch
end
try
    ax.Toolbar = [];
catch
    try
        ax.Toolbar.Visible = 'off';
    catch
    end
end

end

function local_place_time_text(tt, theme, pad, content_bottom, axes_w, content_h)

tt.Units = 'pixels';
label_h = 20;
tt.Position = [pad, content_bottom + max(0, content_h - label_h), ...
    min(520, max(120, axes_w)), label_h];
try
    tt.BackgroundColor = theme.color.bg;
    tt.ForegroundColor = theme.color.text;
    tt.HorizontalAlignment = 'left';
catch
end
str = '';
try
    str = char(string(tt.String));
catch
end
if isempty(strtrim(str))
    tt.Visible = 'off';
else
    tt.Visible = 'on';
end

end

function local_fill_list_host(host)

try
    fcn = host.SizeChangedFcn;
    if isa(fcn, 'function_handle')
        fcn(host, []);
        return
    end
catch
end
try
    old = host.Units;
    host.Units = 'pixels';
    box = host.Position;
    try
        box = host.InnerPosition;
    catch
    end
    ch = host.Children;
    for i = 1:numel(ch)
        if strcmpi(char(ch(i).Type), 'uihtml')
            try
                ch(i).Units = 'pixels';
            catch
            end
            ch(i).Position = [0 0 max(1, box(3)) max(1, box(4))];
        end
    end
    host.Units = old;
catch
end

end

function s = onoff(tf)

if tf
    s = 'on';
else
    s = 'off';
end

end
