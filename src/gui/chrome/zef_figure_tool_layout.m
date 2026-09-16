function zef_figure_tool_layout(h_fig, mode)
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
%   zef_figure_tool_layout(h_fig, 'defer')
%   zef_figure_tool_layout(h_fig, 'sizechange')  % no-op if size unchanged
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
if nargin >= 2 && (ischar(mode) || isstring(mode)) && strcmpi(char(mode), 'defer')
    local_defer_layout(h_fig);
    return
end
if nargin >= 2 && (ischar(mode) || isstring(mode)) && strcmpi(char(mode), 'sizechange')
    try
        orig = h_fig.Units;
        h_fig.Units = 'pixels';
        sz = round(h_fig.Position(3:4));
        h_fig.Units = orig;
        prev = getappdata(h_fig, 'ZefLaidSize');
        if ~isempty(prev) && isequal(prev, sz)
            return
        end
        setappdata(h_fig, 'ZefLaidSize', sz);
    catch
    end
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

try
    orig = h_fig.Units;
    h_fig.Units = 'pixels';
    setappdata(h_fig, 'ZefLaidSize', round(h_fig.Position(3:4)));
    h_fig.Units = orig;
catch
end

end

function local_defer_layout(h_fig)

try
    t = getappdata(h_fig, 'ZefLayoutTimer');
    if isempty(t) || ~isvalid(t)
        t = timer('Name', 'ZefFigureLayout', 'ExecutionMode', 'singleShot', ...
            'StartDelay', 0.04, 'TimerFcn', @(~, ~) local_deferred_fire(h_fig));
        setappdata(h_fig, 'ZefLayoutTimer', t);
        try
            addlistener(h_fig, 'ObjectBeingDestroyed', @(s, ~) local_kill_layout_timer(s));
        catch
        end
    else
        try
            stop(t);
        catch
        end
    end
    start(t);
catch
    zef_figure_tool_layout(h_fig);
end

end

function local_deferred_fire(h_fig)

if isgraphics(h_fig) && isvalid(h_fig)
    zef_figure_tool_layout(h_fig, 'sizechange');
end

end

function local_kill_layout_timer(h_fig)

try
    t = getappdata(h_fig, 'ZefLayoutTimer');
    if ~isempty(t) && isvalid(t)
        stop(t);
        delete(t);
    end
catch
end

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

sidebar_on = local_controls_on(h_fig, tgb);

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
    if shell
        work = zef_ui_find(h_fig, 'zef_shell_card');
        if ~isempty(work) && isvalid(work) && ~isempty(view) && isvalid(view)
            [slot, axes_x, content_bottom, axes_w, axes_h] = ...
                local_workspace_view_slot(work, view, theme);
            content_h = axes_h;
        end
    end
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
            zef_ui_card(lists, theme, 16);
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
        sidebar_y = theme.space.footerH + theme.space.cardGap;
        header_h = theme.space.headerH;
        top_gap = theme.space.headerGap;
        try
            if isappdata(h_fig, 'ZefShellHeaderH')
                header_h = getappdata(h_fig, 'ZefShellHeaderH');
            end
            if isappdata(h_fig, 'ZefShellHeaderGap')
                top_gap = getappdata(h_fig, 'ZefShellHeaderGap');
            end
        catch
        end
        sidebar_h = max(180, H - header_h - theme.space.footerH ...
            - top_gap - theme.space.cardGap);
        nav = zef_ui_find(h_fig, 'zef_shell_nav');
        if ~isempty(nav) && isvalid(nav)
            try
                nav.Units = 'pixels';
                np = double(nav.Position);
                if numel(np) >= 4 && np(4) > 1
                    sidebar_y = np(2);
                    sidebar_h = max(180, np(4));
                end
            catch
            end
        end
        local_set_pos(sidebar, [sidebar_x, sidebar_y, sidebar_w, sidebar_h]);
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
    try
        local_layout_sidebar(sidebar, theme, btn_h, pad, gap);
        if shell
            local_round_sidebar_buttons(sidebar, theme);
        end
    catch
    end
end

local_place_persistent_toggle(h_fig, tgb, theme, sidebar_on, sidebar, ...
    cx, cy, cw, ch, pad, btn_h, gap, shell);

if shell
    local_place_gizmo(h_fig, theme, [axes_x, content_bottom, axes_w, axes_h]);
end

h_fig.Units = orig_units;

end

function local_round_sidebar_buttons(panel, theme)

tags = {'toggleedgesbutton', 'resetbutton', ...
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

function on = local_controls_on(h_fig, tgb)

on = true;
try
    if isappdata(h_fig, 'ZefFigureControlsVisible')
        v = getappdata(h_fig, 'ZefFigureControlsVisible');
        if ~isempty(v)
            on = logical(v(1));
            return
        end
    end
catch
end
if ~isempty(tgb) && isvalid(tgb) && isprop(tgb, 'UserData') && isequal(tgb.UserData, 2)
    on = false;
end

end

function local_place_persistent_toggle(h_fig, tgb, theme, sidebar_on, sidebar, ...
    cx, cy, cw, ch, pad, btn_h, gap, shell)

if isempty(tgb) || ~isvalid(tgb)
    return
end
host = local_ensure_toggle_host(h_fig, theme);
if isempty(host) || ~isvalid(host)
    return
end
try
    if ~isequal(tgb.Parent, host)
        tgb.Parent = host;
    end
catch
end
tgb.Units = 'pixels';
tgb.Visible = 'on';
tgb.Enable = 'on';
try
    lab = strtrim(char(tgb.String));
catch
    lab = '';
end
if isempty(lab)
    try
        lab = char(getappdata(tgb, 'ZefButtonLabel'));
    catch
        lab = '';
    end
end
if isempty(strtrim(lab))
    lab = 'Toggle controls';
end
try
    setappdata(tgb, 'ZefButtonLabel', lab);
    tgb.String = lab;
catch
end
try
    tgb.UserData = 1 + double(~sidebar_on);
catch
end

th = max(22, round(btn_h));
tw = 128;
hx = cx + max(0, cw - pad - tw);
hy = cy + max(0, ch - pad - th);
if sidebar_on && ~isempty(sidebar) && isvalid(sidebar)
    try
        sidebar.Units = 'pixels';
        sp = double(sidebar.Position);
        inner_w = max(40, sp(3) - 2 * pad);
        half = (inner_w - gap) / 2;
        tw = max(72, round(half));
        hx = sp(1) + pad;
        hy = sp(2) + sp(4) - pad - th;
    catch
    end
end
try
    host.Units = 'pixels';
    host.Visible = 'on';
    host.Position = [round(hx), round(hy), round(tw), round(th)];
catch
end
tgb.Position = [0, 0, round(tw), round(th)];
local_reclaim_toggle_caption(h_fig, host);
if shell
    try
        zef_ui_round_button(tgb, theme);
    catch
    end
end
local_stack_once(host, 'ZefStacked');
cap = findall(host, 'Tag', 'togglecontrolsbutton_cap');
if ~isempty(cap) && isvalid(cap(1))
    cap(1).Visible = 'on';
    local_stack_once(cap(1), 'ZefStacked');
end
sl = zef_ui_find(h_fig, 'zef_tool_sliders');
if ~isempty(sl) && isvalid(sl)
    try
        sl.UserData = double(~sidebar_on);
    catch
    end
end

end

function host = local_ensure_toggle_host(h_fig, theme)

host = zef_ui_find(h_fig, 'figure_toggle_host');
if ~isempty(host) && isvalid(host)
    try
        host.BackgroundColor = theme.color.panel;
    catch
    end
    return
end
host = uipanel('Parent', h_fig, 'Tag', 'figure_toggle_host', ...
    'Units', 'pixels', 'BorderType', 'none', 'Title', '', ...
    'BackgroundColor', theme.color.panel, 'Visible', 'on', ...
    'AutoResizeChildren', 'off');
try
    host.Clipping = 'off';
catch
end
try
    host.HighlightColor = theme.color.panel;
catch
end

end

function local_reclaim_toggle_caption(h_fig, host)

caps = findall(h_fig, 'Tag', 'togglecontrolsbutton_cap');
for i = 1:numel(caps)
    if ~isvalid(caps(i))
        continue
    end
    if ~isempty(host) && isvalid(host) && isequal(caps(i).Parent, host)
        continue
    end
    try
        delete(caps(i));
    catch
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
pad = 10;
header_h = 18;
header_gap = 4;
inner_w = max(80, p(3) - 2 * pad);
copy = zef_ui_find(panel, 'copyright_text');
if ~isempty(copy) && isvalid(copy)
    copy.Visible = 'off';
end
hide_tags = {'status_comp_icon', 'status_sens_icon'};
for i = 1:numel(hide_tags)
    hx = zef_ui_find(panel, hide_tags{i});
    if ~isempty(hx) && isvalid(hx)
        hx.Visible = 'off';
    end
end

weights = [0.34 0.31 0.35];
col_w = inner_w .* weights;
x0 = pad;
label_y = max(pad, p(4) - pad - header_h);
body_y = pad;
body_h = max(24, label_y - header_gap - body_y);
titles = {'Compartments', 'Sensors', 'Details'};
labs = {'label_compartments', 'label_sensors', 'label_details'};
counts = {'status_compartments_count', 'status_sensors_count', ''};
badges = {'status_compartments_badge', 'status_sensors_badge', ''};
lists = {'compartment_visible_color', 'sensor_visible_color', 'system_information'};
font_name = 'Helvetica Neue';
try
    font_name = theme.font.name;
catch
end
badge_fill = theme.color.badge;
badge_fg = theme.color.badgeText;
ready_bg = theme.color.readyBg;
ready_fg = theme.color.readyText;
hair = theme.color.hairline;
x = x0;
for i = 1:3
    wcol = col_w(i);
    lab = zef_ui_find(panel, labs{i});
    if ~isempty(lab) && isvalid(lab)
        lab.Units = 'pixels';
        lab.Parent = panel;
        lab.String = titles{i};
        lab.HorizontalAlignment = 'left';
        lab.FontWeight = 'bold';
        lab.ForegroundColor = theme.color.text;
        lab.BackgroundColor = theme.color.panel;
        try
            lab.FontName = font_name;
            lab.FontUnits = 'pixels';
            lab.FontSize = 12;
        catch
        end
        lab.Position = [x + 4, label_y, max(48, wcol - 8), header_h];
        tw = 88;
        try
            ext = lab.Extent;
            tw = min(wcol - 16, max(48, ceil(ext(3)) + 2));
        catch
        end
        lab.Position = [x + 4, label_y, tw, header_h];
    else
        tw = 88;
    end
    if ~isempty(counts{i})
        local_place_count_badge(panel, theme, badges{i}, counts{i}, ...
            x + 4 + tw + 6, label_y, header_h, badge_fill, badge_fg, font_name);
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
            try
                host.AutoResizeChildren = 'off';
            catch
            end
            host.Parent = panel;
            if i == 3
                host.Visible = 'off';
                try
                    lst.Visible = 'off';
                catch
                end
                try
                    host.Position = [1, 1, 1, 1];
                catch
                end
            else
                if i == 2
                    local_enable_sensor_checks(lst);
                end
                host.Visible = 'on';
                host.Position = [x + 2, body_y, max(40, wcol - 10), body_h];
                try
                    host.BackgroundColor = theme.color.panel;
                catch
                end
                local_fill_list_host(host);
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
            sep.Enable = 'inactive';
            sep.String = '';
            sep.BackgroundColor = hair;
            sep.Position = [round(x + wcol) - 1, body_y + 2, 1, max(8, body_h - 4)];
        end
    end
    x = x + wcol;
end

dt = zef_ui_find(panel, 'status_details_text');
det_x = x0 + col_w(1) + col_w(2);
local_place_detail_rows(panel, theme, dt, det_x, label_y - header_gap, ...
    col_w(3), body_h, font_name, hair);

pill_w = 62;
pill_h = 18;
pill_x = p(3) - pad - pill_w;
pill_y = label_y + max(0, round((header_h - pill_h) / 2));
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
        pkey = [pill_w, pill_h, round(ready_bg * 1000)];
        prev = getappdata(pill, 'ZefPillKey');
        if ~isequal(prev, pkey)
            pill.CData = zef_ui_roundrect(pill_w, pill_h, round(pill_h / 2), ...
                ready_bg, ready_bg, theme.color.panel);
            setappdata(pill, 'ZefPillKey', pkey);
        end
        pill.String = '';
    catch
    end
end
dot = zef_ui_find(panel, 'status_ready_dot');
rd = zef_ui_find(panel, 'status_ready');
rx = pill_x + 8;
dsz = 7;
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
    dot.BackgroundColor = ready_bg;
    dot.Position = [rx, pill_y + max(0, (pill_h - dsz) / 2), dsz, dsz];
    try
        dkey = [dsz, round(ready_bg * 1000)];
        prev = getappdata(dot, 'ZefDotKey');
        if ~isequal(prev, dkey)
            dot.CData = local_status_dot(dsz, theme.color.ready, ready_bg);
            setappdata(dot, 'ZefDotKey', dkey);
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
    rd.ForegroundColor = ready_fg;
    rd.BackgroundColor = ready_bg;
    rd.FontWeight = 'normal';
    rd.Position = [rx, pill_y + max(0, (pill_h - 14) / 2), 40, 14];
    try
        rd.FontName = font_name;
        rd.FontUnits = 'pixels';
        rd.FontSize = 10;
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

function local_place_count_badge(panel, theme, badge_tag, count_tag, x, y, header_h, fillc, fgc, font_name)

cnt = zef_ui_find(panel, count_tag);
if isempty(cnt) || ~isvalid(cnt)
    return
end
cnt.Units = 'pixels';
cnt.Parent = panel;
cnt.Visible = 'on';
cnt.HorizontalAlignment = 'center';
cnt.FontWeight = 'normal';
cnt.ForegroundColor = fgc;
txt = strtrim(char(string(cnt.String)));
if isempty(txt)
    txt = '0';
    cnt.String = txt;
end
nch = max(1, numel(txt));
bw = max(22, 12 + nch * 6);
bh = 16;
by = y + max(0, round((header_h - bh) / 2));
badge = local_ensure_ctrl(panel, badge_tag, 'pushbutton');
badge.Visible = 'on';
badge.Enable = 'inactive';
badge.String = '';
badge.BackgroundColor = theme.color.panel;
badge.Position = [x, by, bw, bh];
try
    bkey = [bw, bh, round(fillc * 1000)];
    prev = getappdata(badge, 'ZefBadgeKey');
    if ~isequal(prev, bkey)
        badge.CData = zef_ui_roundrect(bw, bh, round(bh / 2), fillc, fillc, theme.color.panel);
        setappdata(badge, 'ZefBadgeKey', bkey);
    end
catch
end
cnt.BackgroundColor = fillc;
cnt.Position = [x + 4, by + 2, max(16, bw - 8), max(12, bh - 4)];
try
    cnt.FontName = font_name;
    cnt.FontUnits = 'pixels';
    cnt.FontSize = 10;
catch
end
local_stack_once(cnt, 'ZefStacked');

end

function local_place_detail_rows(panel, theme, dt, x, y_top, col_w, body_h, font_name, hair)

rows = {'Nodes: 0'; 'Tetrahedra: 0'; 'Visualization: -'; 'Scale: Linear'};
if ~isempty(dt) && isvalid(dt)
    dt.Units = 'pixels';
    dt.Parent = panel;
    dt.Visible = 'off';
    try
        dt.Position = [1, 1, 1, 1];
    catch
    end
    try
        raw = dt.String;
        if ischar(raw) || isstring(raw)
            raw = cellstr(raw);
        end
        if iscell(raw) && ~isempty(raw)
            rows = raw(:);
        end
    catch
    end
end
n = min(4, numel(rows));
row_h = max(16, min(20, floor(body_h / 4)));
inner_x = x + 8;
inner_w = max(48, col_w - 18);
lab_w = round(inner_w * 0.46);
val_w = inner_w - lab_w;
text_h = min(14, row_h - 2);
for i = 1:4
    [lab_s, val_s] = local_split_kv(rows, i);
    if i > n
        lab_s = '';
        val_s = '';
    end
    row_bottom = y_top - i * row_h;
    text_y = row_bottom + max(1, round((row_h - text_h) / 2));
    lab = local_ensure_ctrl(panel, sprintf('status_dlab_%d', i), 'text');
    val = local_ensure_ctrl(panel, sprintf('status_dval_%d', i), 'text');
    lab.Visible = 'on';
    val.Visible = 'on';
    lab.String = lab_s;
    val.String = val_s;
    lab.HorizontalAlignment = 'left';
    val.HorizontalAlignment = 'right';
    lab.ForegroundColor = [0.620 0.655 0.705];
    val.ForegroundColor = theme.color.text;
    lab.BackgroundColor = theme.color.panel;
    val.BackgroundColor = theme.color.panel;
    lab.FontWeight = 'normal';
    val.FontWeight = 'bold';
    lab.Position = [inner_x, text_y, lab_w, text_h];
    val.Position = [inner_x + lab_w, text_y, val_w, text_h];
    try
        lab.FontName = font_name;
        val.FontName = font_name;
        lab.FontUnits = 'pixels';
        val.FontUnits = 'pixels';
        lab.FontSize = 11;
        val.FontSize = 11;
    catch
    end
    rule = local_ensure_ctrl(panel, sprintf('status_drule_%d', i), 'text');
    if i < 4
        rule.Visible = 'on';
        rule.Enable = 'inactive';
        rule.String = '';
        rule.BackgroundColor = hair;
        rule.Position = [inner_x, row_bottom, inner_w, 1];
    else
        rule.Visible = 'off';
    end
end

end

function [lab, val] = local_split_kv(rows, i)

lab = '';
val = '';
if i > numel(rows)
    return
end
s = strtrim(char(string(rows{i})));
k = find(s == ':', 1, 'first');
if isempty(k)
    lab = s;
    return
end
lab = strtrim(s(1:k-1));
val = strtrim(s(k+1:end));

end

function local_enable_sensor_checks(lst)

if isempty(lst) || ~isvalid(lst)
    return
end
try
    if isappdata(lst, 'ZefSensorChecks') && isequal(getappdata(lst, 'ZefSensorChecks'), true)
        return
    end
catch
end
ud = [];
try
    ud = lst.UserData;
catch
end
if ~isstruct(ud)
    return
end
ud.ShowChecks = true;
ud.ShowSwatches = false;
lst.UserData = ud;
try
    setappdata(lst, 'ZefSensorChecks', true);
catch
end
try
    zef_colored_list('theme', lst);
catch
end

end

function h = local_ensure_ctrl(panel, tag, style)

h = zef_ui_find(panel, tag);
if ~isempty(h) && isvalid(h)
    try
        if ~isequal(h.Parent, panel)
            h.Parent = panel;
        end
    catch
    end
    return
end
h = uicontrol('Parent', panel, 'Style', style, 'Tag', tag, ...
    'Units', 'pixels', 'String', '', 'Enable', 'inactive');
try
    h.HitTest = 'off';
catch
end

end

function view = local_ensure_figure_view(h_fig, theme)

view = zef_ui_find(h_fig, 'figure_view');
work = zef_ui_find(h_fig, 'zef_shell_card');
parent = h_fig;
if ~isempty(work) && isvalid(work)
    parent = work;
end
if ~isempty(view) && isvalid(view)
    try
        if ~isequal(view.Parent, parent)
            view.Parent = parent;
        end
    catch
    end
    return
end
view = uipanel('Parent', parent, 'Units', 'pixels', ...
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

function [slot, ax, ay, aw, ah] = local_workspace_view_slot(work, view, theme)

work.Units = 'pixels';
wp = double(work.Position);
rad = 12;
tabH = 28;
toolH = 36;
try
    rad = theme.space.cardRadius;
    tabH = theme.space.tabH;
    toolH = theme.space.toolbarH;
catch
end
try
    if ~isequal(view.Parent, work)
        view.Parent = work;
    end
catch
end
ix = rad;
iy = rad;
iw = max(40, wp(3) - 2 * rad);
ih = max(40, wp(4) - 2 * rad - tabH - toolH);
slot = [ix, iy, iw, ih];
ax = wp(1) + ix;
ay = wp(2) + iy;
aw = iw;
ah = ih;

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
            local_hide_axes_toolbar(ax);
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
    try
        local_clear_gizmo(ax);
    catch
    end
    return
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
logo_key = round(slot(3:4));
same_slot = false;
try
    same_slot = isappdata(ax, 'ZefLogoSlot') ...
        && isequal(getappdata(ax, 'ZefLogoSlot'), logo_key);
catch
end
if is_logo
    if ~same_slot
        local_compose_logo(ax, imgs(1));
        cdata = imgs(1).CData;
        local_fill_logo_axes(ax, size(cdata, 2), size(cdata, 1));
    end
else
    ih = size(cdata, 1);
    iw = size(cdata, 2);
    if ih < 2 || iw < 2
        return
    end
    if ~same_slot
        frac = 0.72;
        extra_x = iw * (1 / frac - 1) / 2;
        extra_y = ih * (1 / frac - 1) / 2;
        try
            ax.XLim = [1 - extra_x, iw + extra_x];
            ax.YLim = [1 - extra_y, ih + extra_y];
        catch
        end
    end
end
try
    disableDefaultInteractivity(ax);
catch
end
try
    local_hide_axes_toolbar(ax);
catch
end
try
    local_overlay_gizmo(ax);
catch
end
try
    setappdata(ax, 'ZefLogoSlot', logo_key);
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
    imh.XData = [1, tw];
    imh.YData = [1, th];
catch
end
try
    setappdata(imh, 'ZefLogoKey', key);
catch
end
try
    delete(findall(ax, 'Tag', 'zef_axes_fill'));
catch
end

end

function local_fill_logo_axes(ax, iw, ih)

iw = max(1, double(iw(1)));
ih = max(1, double(ih(1)));
try
    ax.XLim = [0.5, iw + 0.5];
    ax.YLim = [0.5, ih + 0.5];
catch
    try
        ax.XLim = [1, max(2, iw)];
        ax.YLim = [1, max(2, ih)];
    catch
    end
end
try
    ax.DataAspectRatioMode = 'auto';
catch
end
try
    ax.Units = 'pixels';
    p = ax.InnerPosition;
    ax.PlotBoxAspectRatio = [max(1, p(3)), max(1, p(4)), 1];
    ax.PlotBoxAspectRatioMode = 'manual';
catch
end
try
    ax.Clipping = 'on';
catch
end

end

function local_clear_gizmo(ax)

old = findall(ax, 'Tag', 'zef_axes_gizmo_img');
if ~isempty(old)
    delete(old);
end

end

function local_overlay_gizmo(ax)

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
vw = max(1, double(p(3)));
vh = max(1, double(p(4)));
gizmo_px = 46;
pad = 16;
if vw < gizmo_px + 2 * pad || vh < gizmo_px + 2 * pad
    return
end
xl = [0.5, vw + 0.5];
yl = [0.5, vh + 0.5];
try
    xl = double(ax.XLim);
    yl = double(ax.YLim);
catch
end
if numel(xl) < 2 || numel(yl) < 2
    return
end
sx = (xl(2) - xl(1)) / vw;
sy = (yl(2) - yl(1)) / vh;
px = vw - pad - gizmo_px;
x1 = xl(1) + px * sx;
x2 = xl(1) + (px + gizmo_px) * sx;
ydir = 'normal';
try
    ydir = lower(char(ax.YDir));
catch
end
if strcmp(ydir, 'reverse')
    y1 = yl(1) + pad * sy;
    y2 = yl(1) + (pad + gizmo_px) * sy;
else
    py = vh - pad - gizmo_px;
    y1 = yl(1) + py * sy;
    y2 = yl(1) + (py + gizmo_px) * sy;
end
try
    hold(ax, 'on');
catch
end
h = image(ax, 'XData', [x1, x2], 'YData', [y1, y2], 'CData', rgb);
try
    ax.XLim = xl;
    ax.YLim = yl;
    ax.YDir = ydir;
catch
end
h.Tag = 'zef_axes_gizmo_img';
try
    h.PickableParts = 'none';
    h.HitTest = 'off';
catch
end
try
    uistack(h, 'top');
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
    host.AutoResizeChildren = 'off';
catch
end
try
    fcn = host.SizeChangedFcn;
    if isa(fcn, 'function_handle')
        fcn(host, []);
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
            try
                zef_colored_list('theme', ch(i));
            catch
            end
        end
    end
    host.Units = old;
catch
end

end

function rgb = local_status_dot(sz, fg, bg)

sz = max(8, round(sz));
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

local_stack_once(rd, 'ZefStacked');
local_stack_once(dot, 'ZefStacked');

end

function local_stack_once(h, key)

if isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin < 2 || isempty(key)
    key = 'ZefStacked';
end
try
    if isappdata(h, key) && isequal(getappdata(h, key), true)
        return
    end
catch
end
try
    uistack(h, 'top');
    setappdata(h, key, true);
catch
end

end

function local_hide_axes_toolbar(ax)

if isempty(ax) || ~isgraphics(ax) || ~isvalid(ax)
    return
end
try
    if isempty(ax.Toolbar)
        axtoolbar(ax, {'restoreview'});
    end
catch
end
try
    ax.Toolbar.Visible = 'off';
catch
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
