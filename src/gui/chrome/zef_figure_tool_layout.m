function zef_figure_tool_layout(h_fig)
%ZEF_FIGURE_TOOL_LAYOUT  Pixel layout for the Figure tool (design reference).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Places the visualization axes, a card-style control sidebar, and the
%   three bottom lists. Called at creation and from SizeChangedFcn. Toggle
%   controls hides the sidebar and widens the axes. The sidebar card
%   stays full-height; Loop/Reset/Play/Stop/Logo pin to the bottom and
%   leftover height is distributed through slider and section gaps.
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

shell = false;
try
    shell = zef_ui_is_unified(h_fig);
catch
end

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

nav_w = 0;
if shell
    nav_w = theme.space.navW;
    if W < 860
        nav_w = theme.space.navWCompact;
    end
end
plot_min = 280;
if sidebar_on && (W - nav_w - 2 * pad - sidebar_w) < plot_min
    sidebar_w = max(220, W - nav_w - 2 * pad - plot_min);
end

if shell
    right_inset = 0;
    if sidebar_on
        right_inset = sidebar_w + 2 * theme.space.cardGap;
    end
    try
        setappdata(h_fig, 'ZefShellRightInset', right_inset);
    catch
    end
    try
        zef_ui_shell('layout', h_fig);
    catch
    end
    [cx, cy, cw, ch] = zef_ui_shell('content_rect', h_fig, theme);
else
    cx = 0;
    cy = 0;
    cw = W;
    ch = H;
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
if ch < 640
    min_lists = 72;
end
if ch <= 540
    min_lists = 32;
end
lists_cap = theme.space.bottomH;
if shell
    lists_cap = theme.space.statusH;
    min_lists = max(64, min_lists);
end
if shell
    lists_h = lists_cap;
else
    lists_h = min(lists_cap, max(min_lists, ch - 2 * pad - gap - needed_sidebar));
    lists_h = min(lists_h, max(min_lists, ch - 2 * pad - gap - must_have));
end
if shell
    axes_w = max(180, cw);
    axes_x = cx;
    sidebar_x = W - theme.space.cardGap - sidebar_w;
    content_bottom = cy;
    content_h = max(180, ch);
else
    content_bottom = cy + pad + lists_h + gap;
    content_h = max(180, ch - lists_h - gap - 2 * pad);
    if sidebar_on
        axes_w = max(180, cw - pad - gap - sidebar_w - pad);
        sidebar_x = cx + cw - pad - sidebar_w;
    else
        axes_w = max(180, cw - 2 * pad);
        sidebar_x = cx + cw;
    end
    axes_x = cx + pad;
end
axes_h = content_h;
btn_h = min(theme.space.btnH, max(24, round(content_h * 0.06)));

if ~isempty(ax) && isvalid(ax)
    ax.Units = 'pixels';
    slot = [axes_x, content_bottom, axes_w, axes_h];
    view = local_ensure_figure_view(h_fig, theme);
    if ~isempty(view) && isvalid(view)
        view.Units = 'pixels';
        local_set_pos(view, slot);
        try
            if ~isequal(ax.Parent, view)
                ax.Parent = view;
            end
        catch
        end
        inner = [1, 1, max(1, slot(3) - 2), max(1, slot(4) - 2)];
        local_axes_position(ax, inner);
    else
        local_axes_position(ax, slot);
    end
end

tt = zef_ui_find(h_fig, 'time_text');
if ~isempty(tt) && isvalid(tt)
    local_place_time_text(tt, theme, axes_x, content_bottom, axes_w, content_h);
end

cb = findall(h_fig, 'Tag', 'rightColorbar');
if ~isempty(cb) && isvalid(cb(1)) && sidebar_on
    try
        cb(1).Units = 'pixels';
        cb_w = 18;
        cb(1).Position = [axes_x + axes_w - cb_w - 4, content_bottom + 24, cb_w, max(80, axes_h - 48)];
    catch
    end
end

if ~isempty(lists) && isvalid(lists)
    if shell
        local_set_pos(lists, [cx, theme.space.footerH + theme.space.cardGap, cw, lists_h]);
        lists.BackgroundColor = theme.color.panel;
        try
            lists.BorderType = 'none';
        catch
        end
        try
            zef_ui_card(lists, theme);
        catch
        end
        copy = zef_ui_find(lists, 'copyright_text');
        if ~isempty(copy) && isvalid(copy)
            copy.Visible = 'off';
        end
    else
        local_set_pos(lists, [pad, pad, max(200, W - 2 * pad), lists_h]);
    end
    local_layout_lists(lists, theme);
end

if sidebar_on && ~isempty(sidebar) && isvalid(sidebar)
    if shell
    sidebar_h = max(180, H - theme.space.headerH - theme.space.footerH ...
        - theme.space.headerGap - theme.space.cardGap);
    local_set_pos(sidebar, [sidebar_x, theme.space.footerH + theme.space.cardGap, sidebar_w, sidebar_h]);
        try
            zef_ui_card(sidebar, theme);
        catch
        end
        pad = max(pad, theme.space.cardRadius);
    else
        local_set_pos(sidebar, [sidebar_x, content_bottom, sidebar_w, content_h]);
    end
    try
        sidebar.AutoResizeChildren = 'off';
        sidebar.Clipping = 'on';
        sidebar.Scrollable = 'off';
    catch
    end
    local_layout_sidebar(sidebar, theme, btn_h, pad, gap);
    if shell
        local_round_sidebar_buttons(sidebar, theme);
    end
end

if ~isempty(tgb) && isvalid(tgb)
    tgb.Units = 'pixels';
    if sidebar_on && ~isempty(sidebar) && isvalid(sidebar)
        tgb.Parent = sidebar;
    else
        tgb.Parent = h_fig;
        tgb.Visible = 'on';
        tgb.Position = [cx + cw - pad - 128, cy + ch - pad - btn_h, 128, btn_h];
    end
end

if shell
    local_place_gizmo(h_fig, theme, [axes_x, content_bottom, axes_w, axes_h]);
end

h_fig.Units = orig_units;

end

function local_round_sidebar_buttons(panel, theme)

tags = {'togglecontrolsbutton', 'toggleedgesbutton', 'resetbutton', ...
    'playbutton', 'stopbutton', 'logobutton'};
for i = 1:numel(tags)
    b = zef_ui_find(panel, tags{i});
    if ~isempty(b) && isvalid(b)
        try
            zef_ui_round_button(b, theme);
        catch
        end
    end
end

end

function local_layout_sidebar(panel, theme, btn_h, pad, gap)

panel.Units = 'pixels';
p = panel.Position;
inner_w = max(40, p(3) - 2 * pad);
inner_h = p(4);
x0 = pad;
label_w = min(theme.space.labelW, max(88, round(inner_w * 0.50)));
popup_label_w = label_w;

loop_h = theme.space.row;
top_y = inner_h - pad - btn_h;
btn_y = pad;
loop_y = btn_y + btn_h + gap;
content_top = top_y - gap;
content_floor = loop_y + loop_h + gap;
avail = max(40, content_top - content_floor);

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

y = content_top;
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
y = local_labeled_popup(panel, 'label_scale', 'colorscaleselection', 'Scale', x0, y, inner_w, popup_label_w, popup_h, 0);

local_playback(panel, x0, inner_w, btn_h, loop_h, gap, pad, label_w);

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
n_popup_gap = max(0, n_popup - 1);
max_popup_gap = 8;

    function u = used()
        u = n_headers * (pack.header_h + pack.header_gap + pack.header_above) ...
            + n_slider * (pack.slider_h + pack.slider_gap) ...
            + n_popup * pack.popup_h + n_popup_gap * pack.popup_gap;
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

progressed = true;
iter = 0;
while progressed && iter < 400
    iter = iter + 1;
    progressed = false;
    if used() + n_slider <= avail
        pack.slider_gap = pack.slider_gap + 1;
        progressed = true;
    end
    if used() + n_headers <= avail
        pack.header_above = pack.header_above + 1;
        progressed = true;
    end
    if used() + n_headers <= avail
        pack.header_gap = pack.header_gap + 1;
        progressed = true;
    end
    if n_popup_gap > 0 && pack.popup_gap < max_popup_gap ...
            && used() + n_popup_gap <= avail
        pack.popup_gap = pack.popup_gap + 1;
        progressed = true;
    end
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
    lab.Position = local_inside(x, row_y, label_w - 2, slider_h, x, w);
    if ~isappdata(lab, 'ZefLabelReady')
        lab.String = text;
        lab.HorizontalAlignment = 'right';
        try
            lab.FontUnits = 'pixels';
            lab.FontSize = min(11, max(10, slider_h - 4));
        catch
        end
        setappdata(lab, 'ZefLabelReady', true);
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
    lab.Position = local_inside(x, row_y, label_w - 2, row_h, x, w);
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

function local_playback(panel, x, w, btn_h, row_h, gap, pad, label_w)

if nargin < 8 || isempty(label_w)
    label_w = 88;
end
if nargin < 7 || isempty(pad)
    pad = 10;
end
loop_lab = zef_ui_find(panel, 'label_loop');
loop_cb = zef_ui_find(panel, 'loop_movie');
loop_ed = zef_ui_find(panel, 'loop_count');
if isempty(loop_ed) || ~isvalid(loop_ed)
    loop_ed = zef_ui_find(panel.Parent, 'loop_count');
end
btn_y = pad;
row_y = btn_y + btn_h + gap;
ctrl_x = x + label_w;
if ~isempty(loop_lab) && isvalid(loop_lab)
    loop_lab.Units = 'pixels';
    loop_lab.String = 'Loop';
    loop_lab.HorizontalAlignment = 'right';
    loop_lab.Position = local_inside(x, row_y, label_w - 2, row_h, x, w);
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
fig = ancestor(panel, 'figure');
if ~isempty(fig) && isvalid(fig)
    try
        if zef_ui_is_unified(fig)
            local_layout_status_strip(panel, theme);
            return
        end
    catch
    end
end
p = panel.Position;
extras = {'status_comp_icon', 'status_sens_icon', 'status_sep_1', ...
    'status_sep_2', 'status_details_text', 'status_ready_dot', 'status_ready_pill'};
for i = 1:numel(extras)
    ex = zef_ui_find(panel, extras{i});
    if ~isempty(ex) && isvalid(ex)
        ex.Visible = 'off';
    end
end
pad = 10;
gap = 10;
label_h = 18;
copy_h = 16;
ready_h = 0;
copy = zef_ui_find(panel, 'copyright_text');
if isempty(copy)
    copy = zef_ui_find(panel.Parent, 'copyright_text');
end
if ~isempty(copy) && isvalid(copy)
    try
        if strcmpi(char(copy.Visible), 'off')
            copy_h = 0;
        end
    catch
    end
end
rd = zef_ui_find(panel, 'status_ready');
if isempty(rd)
    rd = zef_ui_find(panel.Parent, 'status_ready');
end
if ~isempty(rd) && isvalid(rd)
    ready_h = 16;
end
label_gap = 4;
top_inset = 8;
inner_w = p(3) - 2 * pad;
inner_h = max(40, p(4) - pad - top_inset);
status_h = max(copy_h, ready_h);
list_h = max(40, inner_h - label_h - status_h - label_gap - 4);
weights = [0.38 0.31 0.31];
usable = max(120, inner_w - 2 * gap);

try
    panel.Clipping = 'on';
catch
end

labels = {'label_compartments', 'label_sensors', 'label_details'};
lists = {'compartment_visible_color', 'sensor_visible_color', 'system_information'};
titles = {'Compartments', 'Sensors', 'Details'};
counts = {'status_compartments_count', 'status_sensors_count', ''};
x = pad;
status_h = max(copy_h, ready_h);
label_y = pad + status_h + list_h + label_gap;
if label_y + label_h > p(4) - top_inset
    label_y = max(pad, p(4) - top_inset - label_h);
    list_h = max(40, label_y - label_gap - status_h - pad);
end
for i = 1:3
    col_w = usable * weights(i);
    lab = zef_ui_find(panel, labels{i});
    if isempty(lab)
        lab = zef_ui_find(panel.Parent, labels{i});
    end
    count_w = 0;
    cnt = gobjects(0);
    if ~isempty(counts{i})
        cnt = zef_ui_find(panel, counts{i});
        if isempty(cnt)
            cnt = zef_ui_find(panel.Parent, counts{i});
        end
        if ~isempty(cnt) && isvalid(cnt)
            count_w = 28;
        end
    end
    if ~isempty(lab) && isvalid(lab)
        lab.Units = 'pixels';
        lab.Parent = panel;
        lab.String = titles{i};
        lab.HorizontalAlignment = 'left';
        lab.Position = [x, label_y, max(48, col_w - count_w), label_h];
        try
            lab.FontUnits = 'pixels';
            lab.FontSize = min(12, max(10, label_h - 6));
            lab.FontWeight = 'bold';
        catch
        end
    end
    if ~isempty(cnt) && isvalid(cnt)
        cnt.Units = 'pixels';
        cnt.Parent = panel;
        cnt.Visible = 'on';
        cnt.HorizontalAlignment = 'right';
        cnt.FontWeight = 'bold';
        cnt.ForegroundColor = theme.color.text;
        cnt.BackgroundColor = theme.color.panel;
        cnt.Position = [x + col_w - count_w, label_y, count_w, label_h];
        try
            cnt.FontUnits = 'pixels';
            cnt.FontSize = min(14, max(11, label_h - 4));
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
            host.Position = [x, pad + status_h, col_w, max(48, list_h)];
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
    copy.Position = [pad, 4, max(80, inner_w - 88), max(copy_h, 1)];
    copy.ForegroundColor = theme.color.textMuted;
    try
        copy.FontUnits = 'pixels';
        copy.FontSize = 11;
        copy.HorizontalAlignment = 'left';
        copy.FontWeight = 'normal';
    catch
    end
end
if ~isempty(rd) && isvalid(rd)
    rd.Units = 'pixels';
    rd.Parent = panel;
    rd.Visible = 'on';
    rd.String = 'Ready';
    rd.HorizontalAlignment = 'right';
    rd.ForegroundColor = theme.color.ready;
    rd.BackgroundColor = theme.color.panel;
    rd.Position = [p(3) - pad - 72, 4, 72, max(16, ready_h)];
    try
        rd.FontUnits = 'pixels';
        rd.FontSize = 11;
        rd.FontWeight = 'bold';
    catch
    end
end

end

function local_layout_status_strip(panel, theme)

panel.Units = 'pixels';
p = panel.Position;
pad = 12;
gap = 8;
inner_w = max(80, p(3) - 2 * pad);
inner_h = max(40, p(4) - 8);
copy = zef_ui_find(panel, 'copyright_text');
if ~isempty(copy) && isvalid(copy)
    copy.Visible = 'off';
end
n_comp = 0;
n_sens = 0;
try
    cv0 = zef_ui_find(panel, 'status_compartments_count');
    n_comp = str2double(char(string(cv0.String)));
catch
end
try
    sv0 = zef_ui_find(panel, 'status_sensors_count');
    n_sens = str2double(char(string(sv0.String)));
catch
end
if (isfinite(n_comp) && n_comp > 0) || (isfinite(n_sens) && n_sens > 0)
    weights = [0.34 0.26 0.40];
else
    weights = [0.20 0.20 0.60];
end
usable = max(80, inner_w - 2);
x = pad;
col_w = usable .* weights;
titles = {'Compartments', 'Sensors', 'Details'};
labs = {'label_compartments', 'label_sensors', 'label_details'};
icons = {'status_comp_icon', 'status_sens_icon', ''};
icon_keys = {'cube', 'sensors', ''};
counts = {'status_compartments_count', 'status_sensors_count', ''};
lists = {'compartment_visible_color', 'sensor_visible_color', 'system_information'};
header_h = 15;
label_y = p(4) - 5 - header_h;
body_y = pad;
body_h = max(24, label_y - 2 - body_y);
for i = 1:3
    wcol = col_w(i);
    cnt = [];
    lab = zef_ui_find(panel, labs{i});
    if ~isempty(lab) && isvalid(lab)
        lab.Units = 'pixels';
        lab.Parent = panel;
        lab.String = titles{i};
        lab.HorizontalAlignment = 'left';
        lab.FontWeight = 'bold';
        lab.ForegroundColor = theme.color.text;
        lab.BackgroundColor = theme.color.panel;
        lab.Position = [x, label_y, wcol - 4, header_h];
        try
            lab.FontUnits = 'pixels';
            lab.FontSize = 11;
        catch
        end
    end
    if ~isempty(icons{i})
        ic = zef_ui_find(panel, icons{i});
        if ~isempty(ic) && isvalid(ic)
            ic.Units = 'pixels';
            ic.Parent = panel;
            ic.Visible = 'on';
            ic.Enable = 'inactive';
            ic.String = '';
            ic.Position = [x, body_y + max(0, (body_h - 28) / 2), 28, 28];
            ic.BackgroundColor = theme.color.panel;
            try
                ikey = [i, 28];
                prev = getappdata(ic, 'ZefStatusIconKey');
                if ~isequal(prev, ikey)
                    if i == 1
                        boxc = zef_ui_roundrect(28, 28, 6, theme.color.panelAlt, ...
                            theme.color.border, theme.color.panel);
                        ink = zef_ui_icons(icon_keys{i}, 16, theme.color.text, theme.color.panelAlt);
                        if ~isempty(ink)
                            r0 = 6; c0 = 6;
                            boxc(r0:r0 + 15, c0:c0 + 15, :) = ink;
                        end
                        ic.CData = boxc;
                    else
                        ink = zef_ui_icons(icon_keys{i}, 18, theme.color.text, theme.color.panel);
                        full = repmat(reshape(theme.color.panel, 1, 1, 3), 28, 28);
                        if ~isempty(ink)
                            r0 = 5; c0 = 5;
                            ih = min(18, size(ink, 1));
                            iw = min(18, size(ink, 2));
                            full(r0:r0 + ih - 1, c0:c0 + iw - 1, :) = ink(1:ih, 1:iw, :);
                        end
                        ic.CData = full;
                    end
                    setappdata(ic, 'ZefStatusIconKey', ikey);
                end
            catch
            end
        end
        cnt = zef_ui_find(panel, counts{i});
        if ~isempty(cnt) && isvalid(cnt)
            cnt.Units = 'pixels';
            cnt.Parent = panel;
            cnt.Visible = 'on';
            cnt.HorizontalAlignment = 'left';
            cnt.FontWeight = 'bold';
            cnt.ForegroundColor = theme.color.text;
            cnt.BackgroundColor = theme.color.panel;
            cnt.Position = [x + 36, body_y + max(0, (body_h - 28) / 2), max(36, wcol - 42), 28];
            try
            cnt.FontUnits = 'pixels';
            cnt.FontSize = 24;
            catch
            end
        end
    end
    lst = zef_ui_find(panel, lists{i});
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
            n_items = 0;
            try
                udl = lst.UserData;
                if isstruct(udl) && isfield(udl, 'N')
                    n_items = double(udl.N);
                end
            catch
            end
            if ~(isfinite(n_items) && n_items > 0) && i < 3
                try
                    ctag = counts{i};
                    cv = zef_ui_find(panel, ctag);
                    n_items = str2double(char(string(cv.String)));
                catch
                end
            end
            if i == 3
                host.Visible = 'off';
            elseif ~isempty(n_items) && n_items > 0
                host.Visible = 'on';
                host.Position = [x, body_y, max(40, wcol - 8), body_h];
                local_fill_list_host(host);
                if ~isempty(cnt) && isvalid(cnt)
                    cnt.Visible = 'off';
                end
                if ~isempty(icons{i})
                    ic2 = zef_ui_find(panel, icons{i});
                    if ~isempty(ic2) && isvalid(ic2)
                        ic2.Visible = 'off';
                    end
                end
                if ~isempty(lab) && isvalid(lab)
                    lab.String = sprintf('%s   %d', titles{i}, n_items);
                end
            else
                host.Visible = 'off';
            end
        catch
        end
    end
    if i < 3
        sep = zef_ui_find(panel, sprintf('status_sep_%d', i));
        if ~isempty(sep) && isvalid(sep)
            sep.Units = 'pixels';
            sep.Parent = panel;
            sep.Visible = 'on';
            sep.BackgroundColor = theme.color.border;
            sep.Position = [x + wcol - 1, pad, 1, inner_h - 4];
        end
    end
    x = x + wcol + gap;
end
dt = zef_ui_find(panel, 'status_details_text');
if ~isempty(dt) && isvalid(dt)
    dt.Units = 'pixels';
    dt.Parent = panel;
    dt.Visible = 'on';
    dt.HorizontalAlignment = 'left';
    dt.ForegroundColor = theme.color.text;
    dt.BackgroundColor = theme.color.panel;
    det_x = pad + col_w(1) + gap + col_w(2) + gap;
    dt_h = min(body_h, 52);
    dt.Position = [det_x, label_y - 2 - dt_h, max(80, col_w(3) - 110), dt_h];
    try
        dt.FontUnits = 'pixels';
        dt.FontSize = 10;
    catch
    end
end
pill_w = 78;
pill_h = 26;
pill_x = p(3) - pad - pill_w;
pill_y = pad + max(0, (body_h - pill_h) / 2);
if ~isempty(dt) && isvalid(dt)
    pill_y = dt.Position(2) + max(0, dt.Position(4) - pill_h);
end
pill = zef_ui_find(panel, 'status_ready_pill');
restack = false;
if ~isempty(pill) && isvalid(pill)
    pill.Units = 'pixels';
    restack = local_adopt(pill, panel) || restack;
    pill.Visible = 'on';
    pill.Enable = 'inactive';
    try
        pill.HitTest = 'off';
    catch
    end
    pill.BackgroundColor = theme.color.panel;
    pill.Position = [pill_x, pill_y, pill_w, pill_h];
    try
        pkey = [pill_w, pill_h];
        prev = getappdata(pill, 'ZefPillKey');
        if ~isequal(prev, pkey)
            pill.CData = zef_ui_roundrect(pill_w, pill_h, max(8, round(pill_h / 2)), ...
                theme.color.panelAlt, theme.color.border, theme.color.panel);
            setappdata(pill, 'ZefPillKey', pkey);
        end
        pill.String = '';
    catch
    end
end
dot = zef_ui_find(panel, 'status_ready_dot');
rd = zef_ui_find(panel, 'status_ready');
rx = pill_x + 10;
if ~isempty(dot) && isvalid(dot)
    dot.Units = 'pixels';
    restack = local_adopt(dot, panel) || restack;
    dot.Visible = 'on';
    dot.Enable = 'inactive';
    try
        dot.HitTest = 'off';
    catch
    end
    dot.String = '';
    dot.BackgroundColor = theme.color.panelAlt;
    dsz = 12;
    dot.Position = [rx, pill_y + max(0, (pill_h - dsz) / 2), dsz, dsz];
    try
        prev = getappdata(dot, 'ZefDotKey');
        if ~isequal(prev, dsz)
            dot.CData = local_status_dot(dsz, theme.color.ready, theme.color.panelAlt);
            setappdata(dot, 'ZefDotKey', dsz);
        end
    catch
        dot.BackgroundColor = theme.color.ready;
    end
    rx = rx + dsz + 5;
end
if ~isempty(rd) && isvalid(rd)
    rd.Units = 'pixels';
    restack = local_adopt(rd, panel) || restack;
    rd.Visible = 'on';
    rd.String = 'Ready';
    rd.HorizontalAlignment = 'left';
    rd.ForegroundColor = theme.color.textMuted;
    rd.BackgroundColor = theme.color.panelAlt;
    rd.FontWeight = 'normal';
    rd.Position = [rx, pill_y + max(0, (pill_h - 16) / 2), 50, 16];
    try
        rd.FontUnits = 'pixels';
        rd.FontSize = 11;
    catch
    end
end
try
    if restack || ~(isappdata(panel, 'ZefReadyStacked') ...
            && isequal(getappdata(panel, 'ZefReadyStacked'), true))
        local_stack_ready(pill, dot, rd);
        setappdata(panel, 'ZefReadyStacked', true);
    end
catch
end

end

function view = local_ensure_figure_view(h_fig, theme)

view = zef_ui_find(h_fig, 'figure_view');
if ~isempty(view) && isvalid(view)
    return
end
view = uipanel('Parent', h_fig, 'Units', 'pixels', ...
    'Title', '', 'BorderType', 'none', 'Tag', 'figure_view', ...
    'BackgroundColor', theme.color.axesBg, 'ForegroundColor', theme.color.text);
try
    view.Clipping = 'on';
catch
end
try
    view.AutoResizeChildren = 'off';
catch
end

end

function pos = local_axes_position(ax, slot)

pos = slot;
if isempty(ax) || ~isvalid(ax)
    return
end
dressed = false;
try
    dressed = isappdata(ax, 'ZefAxesDressed') && isequal(getappdata(ax, 'ZefAxesDressed'), true);
catch
end
if ~dressed
    try
        try
            th = zef_ui_theme();
            ax.Color = th.color.axesBg;
        catch
            ax.Color = [1 1 1];
        end
        ax.Box = 'off';
        ax.XTick = [];
        ax.YTick = [];
        ax.XColor = 'none';
        ax.YColor = 'none';
        try
            ax.XAxis.Visible = 'off';
            ax.YAxis.Visible = 'off';
            ax.ZAxis.Visible = 'off';
        catch
        end
        try
            ax.Title.String = '';
            ax.Title.Visible = 'off';
            ax.XLabel.String = '';
            ax.YLabel.String = '';
            ax.ZLabel.String = '';
        catch
        end
        try
            ax.Toolbar = [];
        catch
        end
        try
            ax.Clipping = 'on';
        catch
        end
        try
            ax.PositionConstraint = 'innerposition';
        catch
        end
        setappdata(ax, 'ZefAxesDressed', true);
    catch
    end
end
ax.Units = 'pixels';
cur = [];
try
    cur = double(ax.InnerPosition);
catch
    try
        cur = double(ax.Position);
    catch
    end
end
slot = double(slot);
same = numel(cur) >= 4 && max(abs(cur(:) - slot(:))) < 0.51;
if same
    pos = cur;
else
    try
        ax.InnerPosition = slot;
        pos = ax.InnerPosition;
    catch
        try
            ax.Position = slot;
            pos = slot;
        catch
        end
    end
end
has_volume = false;
try
    has_volume = isappdata(ax, 'ZefHasVolumePlot') ...
        && isequal(getappdata(ax, 'ZefHasVolumePlot'), true);
catch
end
if has_volume
    return
end
logo_key = round(slot(3:4));
try
    if isappdata(ax, 'ZefLogoSlot') && ~isempty(getappdata(ax, 'ZefLogoSlot'))
        setappdata(ax, 'ZefLogoSlot', logo_key);
        return
    end
catch
end
others = [];
try
    others = findall(ax, 'Type', 'patch', '-or', 'Type', 'surface', ...
        '-or', 'Type', 'line', '-or', 'Type', 'scatter');
catch
end
if ~isempty(others)
    try
        setappdata(ax, 'ZefHasVolumePlot', true);
    catch
    end
    try
        local_clear_gizmo(ax);
    catch
    end
    try
        delete(findall(ax, 'Tag', 'zef_axes_fill'));
    catch
    end
    return
end
imgs = [];
try
    imgs = findall(ax, 'Type', 'image');
catch
end
try
    keep = true(size(imgs));
    for i = 1:numel(imgs)
        keep(i) = ~strcmp(char(imgs(i).Tag), 'zef_axes_gizmo_img') ...
            && ~strcmp(char(imgs(i).Tag), 'zef_axes_fill');
    end
    imgs = imgs(keep);
catch
end
if isempty(imgs)
    try
        local_clear_gizmo(ax);
    catch
    end
    return
end
cdata = [];
logo = [];
try
    for i = 1:numel(imgs)
        if strcmp(char(imgs(i).Tag), 'zef_logo_img')
            logo = imgs(i);
            break
        end
    end
catch
end
if ~isempty(logo)
    imgs = logo;
end
try
    cdata = imgs(1).CData;
catch
end
if isempty(cdata)
    return
end
is_logo = false;
try
    is_logo = strcmp(char(imgs(1).Tag), 'zef_logo_img');
catch
end
if is_logo
    local_compose_logo(ax, imgs(1));
    cdata = imgs(1).CData;
    ih = size(cdata, 1);
    iw = size(cdata, 2);
    extra_x = 0;
    extra_y = 0;
    try
        ax.XLim = [1, iw];
        ax.YLim = [1, ih];
        ax.DataAspectRatio = [1 1 1];
    catch
    end
else
ih = size(cdata, 1);
iw = size(cdata, 2);
if ih < 2 || iw < 2
    return
end
frac = 0.72;
extra_x = iw * (1 / frac - 1) / 2;
extra_y = ih * (1 / frac - 1) / 2;
try
    ax.XLim = [1 - extra_x, iw + extra_x];
    ax.YLim = [1 - extra_y, ih + extra_y];
    ax.DataAspectRatio = [1 1 1];
catch
end
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
try
    local_overlay_gizmo(ax, extra_x, extra_y, iw, ih);
catch
end
try
    setappdata(ax, 'ZefLogoSlot', round(slot(3:4)));
catch
end

end

function local_compose_logo(ax, imh)

src = [];
try
    src = getappdata(imh, 'ZefLogoSrc');
catch
end
if isempty(src)
    try
        src = imread('zeffiro_interface_compass.png');
    catch
        src = imh.CData;
    end
    try
        setappdata(imh, 'ZefLogoSrc', im2double(src));
    catch
    end
end
try
    src = im2double(src);
catch
end
if size(src, 3) == 1
    src = repmat(src, [1 1 3]);
end
ax.Units = 'pixels';
p = ax.Position;
try
    p = ax.InnerPosition;
catch
end
tw = max(8, round(p(3)));
th = max(8, round(p(4)));
bg = [1 1 1];
try
    thm = zef_ui_theme();
    bg = thm.color.axesBg;
    ax.Color = bg;
catch
    try
        bg = ax.Color;
    catch
    end
end
key = [tw, th, 58, 62, round(bg * 1000)];
try
    prev = getappdata(imh, 'ZefLogoKey');
    if isequal(prev, key) && isequal(size(imh.CData, 1), th) ...
            && isequal(size(imh.CData, 2), tw)
        return
    end
catch
end
canvas = repmat(reshape(double(bg(1:3)), 1, 1, 3), th, tw);
ih = size(src, 1);
iw = size(src, 2);
nw = max(1, round(0.58 * tw));
nh = max(1, round(0.62 * th));
try
    scaled = imresize(src, [nh nw], 'bilinear');
catch
    scaled = src;
    nh = size(src, 1);
    nw = size(src, 2);
end
x0 = max(1, 1 + round((tw - nw) / 2));
y0 = max(1, 1 + round((th - nh) / 2));
x1 = min(tw, x0 + size(scaled, 2) - 1);
y1 = min(th, y0 + size(scaled, 1) - 1);
sh = y1 - y0 + 1;
sw = x1 - x0 + 1;
tile = scaled(1:sh, 1:sw, :);
lum = tile(:, :, 1) * 0.299 + tile(:, :, 2) * 0.587 + tile(:, :, 3) * 0.114;
keep = lum <= 0.88;
for k = 1:3
    ch = canvas(y0:y1, x0:x1, k);
    srcch = tile(:, :, k);
    ch(keep) = srcch(keep);
    canvas(y0:y1, x0:x1, k) = ch;
end
imh.CData = canvas;
try
    setappdata(imh, 'ZefLogoKey', key);
catch
end
try
    delete(findall(ax, 'Tag', 'zef_axes_fill'));
catch
end

end

function local_clear_gizmo(ax)

old = findall(ax, 'Tag', 'zef_axes_gizmo_img');
if ~isempty(old)
    delete(old);
end

end

function local_overlay_gizmo(ax, extra_x, extra_y, iw, ih)

local_clear_gizmo(ax);
theme = zef_ui_theme();
rgb = [];
try
    rgb = zef_ui_icons('gizmo', 96, theme.color.text, theme.color.axesBg);
catch
end
if isempty(rgb)
    return
end
ax.Units = 'pixels';
p = ax.Position;
try
    if isprop(ax, 'InnerPosition')
        p = ax.InnerPosition;
    end
catch
end
span_x = iw + 2 * extra_x;
span_y = ih + 2 * extra_y;
gizmo_px = 46;
gw = span_x * (gizmo_px / max(1, p(3)));
gh = span_y * (gizmo_px / max(1, p(4)));
x1 = 1 - extra_x + span_x - gw - span_x * 0.02;
y1 = 1 - extra_y + span_y * 0.035;
h = image(ax, 'XData', [x1, x1 + gw], 'YData', [y1, y1 + gh], 'CData', rgb);
h.Tag = 'zef_axes_gizmo_img';
try
    h.PickableParts = 'none';
    h.HitTest = 'off';
catch
end

end

function local_place_gizmo(h_fig, theme, slot) %#ok<INUSD>

gizmo = zef_ui_find(h_fig, 'zef_axes_gizmo');
if ~isempty(gizmo) && isvalid(gizmo)
    gizmo.Visible = 'off';
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

function rgb = local_status_dot(sz, fg, bg)

sz = max(10, round(sz));
rgb = repmat(reshape(double(bg(1:3)), 1, 1, 3), sz, sz);
[x, y] = meshgrid(1:sz, 1:sz);
r = hypot(x - (sz + 1) / 2, y - (sz + 1) / 2);
rad = sz / 2 - 1.1;
aa = max(0, min(1, rad + 0.85 - r));
for k = 1:3
    ch = rgb(:, :, k);
    ch = ch .* (1 - aa) + fg(k) * aa;
    rgb(:, :, k) = ch;
end

end

function changed = local_adopt(h, panel)

changed = false;
if isempty(h) || ~isvalid(h) || isempty(panel) || ~isvalid(panel)
    return
end
try
    if isequal(h.Parent, panel)
        return
    end
catch
end
try
    h.Parent = panel;
    changed = true;
catch
end

end

function local_stack_ready(pill, dot, rd) %#ok<INUSD>

if ~isempty(rd) && isvalid(rd)
    try
        uistack(rd, 'top');
    catch
    end
end
if ~isempty(dot) && isvalid(dot)
    try
        uistack(dot, 'top');
    catch
    end
end

end

function local_set_pos(h, pos)

if isempty(h) || ~isvalid(h)
    return
end
try
    cur = double(h.Position);
    if numel(cur) >= 4 && max(abs(cur(:) - pos(:))) < 0.51
        return
    end
catch
end
try
    h.Position = pos;
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
