function zef_layout_guide_window(fig)
%ZEF_LAYOUT_GUIDE_WINDOW  Polish a traditional figure() tool window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   GUIDE windows already use normalized Positions, so they scale with
%   the figure. Theme colors are applied here; the window is not grown.
%   A modest resize floor keeps the layout usable without opening large.
%
%   See also zef_ui_ready, zef_ui_apply_theme.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    if ~isappdata(fig, 'ZefMinSize')
        zef_ui_bind_min_size(fig, 360, 280);
    end
    return
end

theme = zef_ui_theme();
try
    fig.Color = theme.color.bg;
catch
end
try
    fig.Resize = 'on';
    fig.AutoResizeChildren = 'off';
    fig.Units = 'pixels';
    p = fig.Position;
    if numel(p) >= 4
        if p(3) < 200
            fig.Position(3) = 420;
        end
        if p(4) < 120
            fig.Position(4) = 320;
        end
    end
catch
end

% Font theming is independent of Units: getpixelposition reports the
% on-screen height without touching Units, so a control laid out in
% normalized coordinates can still be given the theme font at a fixed pixel
% size. This matters because most GUIDE windows are normalized throughout,
% and leaving FontUnits normalized makes the text rescale with the window
% until it is either unreadable or enormous. Only the slider height fix
% below rewrites Position, so that one stays restricted to pixel-unit
% controls where the rewrite is lossless.
ctrls = findall(fig, 'Type', 'uicontrol');
for i = 1:numel(ctrls)
    try
        pix = getpixelposition(ctrls(i));
        h = pix(4);
        ctrls(i).FontName = theme.font.name;
        if strcmpi(char(ctrls(i).Style), 'slider') ...
                && h < theme.space.sliderH ...
                && strcmpi(char(ctrls(i).Units), 'pixels')
            pos = ctrls(i).Position;
            extra = theme.space.sliderH - pos(4);
            pos(2) = pos(2) - extra / 2;
            pos(4) = theme.space.sliderH;
            ctrls(i).Position = pos;
            h = pos(4);
        end
        if h >= 22
            ctrls(i).FontUnits = 'pixels';
            ctrls(i).FontSize = min(theme.font.size, max(10, h - 10));
        end
    catch
    end
end

try
    panels = findall(fig, 'Type', 'uipanel');
    for i = 1:numel(panels)
        panels(i).BackgroundColor = theme.color.panel;
        panels(i).ForegroundColor = theme.color.text;
        panels(i).FontName = theme.font.name;
        panels(i).FontSize = theme.font.sizeSmall;
    end
catch
end

if ~isappdata(fig, 'ZefMinSize')
    zef_ui_bind_min_size(fig, 360, 280);
end
setappdata(fig, 'ZefUiReady', true);

name = '';
try
    name = char(fig.Name);
catch
end
lname = lower(name);
if contains(lname, 'parcellation')
    zef_ui_apply_size(fig, 560, 780, 500, 700);
else
    if ~contains(lname, 'ias roi') && ~isappdata(fig, 'ZefFssRoiLayout')
        try
            zef_layout_guide_form(fig);
        catch
        end
    end
    try
        local_known_tool_size(fig, lname);
    catch
    end
    if contains(lname, 'ias roi') ...
            || (contains(lname, 'multiresolution') && ~isappdata(fig, 'ZefGuideForm'))
        try
            local_ias_roi_pack(fig);
            setappdata(fig, 'ZefPixelResize', @(src) local_ias_roi_pack(src));
        catch
        end
    end
    if ~local_skip_grow_to_content(lname) && ~isappdata(fig, 'ZefGuideForm')
        try
            local_grow_to_content(fig);
        catch
        end
    end
    if ~local_skip_grow_to_content(lname)
        try
            local_widen_narrow_dropdown_forms(fig);
        catch
        end
    end
    try
        if ~(contains(lname, 'preconditioned') || contains(lname, 'iterative relaxation') ...
                || contains(lname, 'ias roi') || contains(lname, 'multiresolution') ...
                || contains(lname, 'databank') || contains(lname, 'data bank'))
            zef_ui_fit_dropdowns(fig);
        end
    catch
    end
    try
        if matlab.ui.internal.isUIFigure(fig) ...
                && ~contains(lname, 'preconditioned') ...
                && ~contains(lname, 'iterative relaxation') ...
                && ~contains(lname, 'nse tool')
            local_stretch_last_grid_column(fig, false);
        end
    catch
    end
    if contains(lname, 'preconditioned') || contains(lname, 'iterative relaxation')
        try
            local_weight_three_column_grid(fig);
            local_relax_gutters(fig);
        catch
        end
    end
    if contains(lname, 'nse tool')
        try
            local_nse_widen_labels(fig);
            local_nse_shift_right_column(fig);
            local_nse_unclip_labels(fig);
            local_nse_space_dropdowns(fig);
            local_nse_unoverlap(fig);
            local_nse_enable_scroll(fig);
        catch
        end
    end
    if contains(lname, 'databank') || contains(lname, 'data bank')
        try
            local_databank_fit_menus(fig);
        catch
        end
    end
    if contains(lname, 'leadfield') || contains(lname, 'lead field') ...
            || contains(lname, 'reconstruction tool')
        try
            zef_ui_fit_table(findall(fig, 'Type', 'uitable'));
            try
                fig.Units = 'pixels';
                fw = fig.Position(3);
                tbls = findall(fig, 'Type', 'uitable');
                for ti = 1:numel(tbls)
                    p = tbls(ti).Position;
                    if numel(p) >= 4 && p(1) < 0.5 * fw
                        p(3) = max(p(3), fw - p(1) - 20);
                        tbls(ti).Position = p;
                    end
                end
            catch
            end
        catch
        end
    end
    try
        if ~contains(lname, 'dipole scan') && ~contains(lname, 'beamformer') ...
                && ~contains(lname, 'nse tool') && ~contains(lname, 'dti') ...
                && ~contains(lname, 'strip tool') && ~contains(lname, 'databank') ...
                && ~contains(lname, 'data bank') && ~contains(lname, 'lead field') ...
                && ~contains(lname, 'sesame') && ~contains(lname, 'leadfield') ...
                && ~contains(lname, 'reconstruction tool') && ~contains(lname, 'ias roi')
            local_fit_uilabels(fig);
        end
    catch
    end
    if contains(lname, 'sesame') || contains(lname, 'dipole scan') ...
            || contains(lname, 'beamformer') ...
            || (contains(lname, 'ias ') && ~contains(lname, 'roi') ...
            && ~contains(lname, 'multiresolution')) ...
            || (contains(lname, 'ramus') && ~contains(lname, 'multiresolution')) ...
            || contains(lname, 'minimum norm') ...
            || contains(lname, 'hierarchical bayesian') || contains(lname, 'mcmc') ...
            || contains(lname, 'l1 map') || contains(lname, 'l1/l2')
        if ~isappdata(fig, 'ZefGuideForm')
            try
                local_sesame_spread(fig);
            catch
            end
        end
    end
    if contains(lname, 'sesame')
        try
            local_sesame_fill_panel(fig);
        catch
        end
    end
    try
        drawnow;
    catch
    end
    try
        local_recapture_fitted_layout(fig, lname);
    catch
    end
    if ~isappdata(fig, 'ZefMinSize')
        zef_ui_bind_min_size(fig, 360, 280);
    end
end

end

function local_grow_to_content(fig)

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
try
    fig.Units = 'pixels';
catch
    return
end
objs = [findall(fig, 'Type', 'uicontrol'); findall(fig, 'Type', 'uitable'); ...
    findall(fig, 'Type', 'uipanel'); findall(fig, 'Type', 'axes')];
if isempty(objs)
    return
end
max_r = 0;
max_t = 0;
for i = 1:numel(objs)
    if ~isgraphics(objs(i)) || ~isvalid(objs(i))
        continue
    end
    gp = [];
    try
        gp = getpixelposition(objs(i), true);
    catch
        continue
    end
    if numel(gp) < 4
        continue
    end
    vis = 'on';
    try
        vis = char(objs(i).Visible);
    catch
    end
    if strcmpi(vis, 'off')
        continue
    end
    max_r = max(max_r, gp(1) + gp(3));
    max_t = max(max_t, gp(2) + gp(4));
end
if max_r < 80 || max_t < 80
    return
end
pad = 16;
need_w = max(360, ceil(max_r + pad));
need_h = max(200, ceil(max_t + pad));
scr = get(groot, 'ScreenSize');
need_w = min(need_w, max(360, round(0.90 * scr(3))));
need_h = min(need_h, max(200, round(0.90 * scr(4))));
p = fig.Position;
grew = false;
if need_w > p(3) + 8
    p(3) = need_w;
    grew = true;
end
if need_h > p(4) + 8
    p(4) = need_h;
    grew = true;
end
if grew
    try
        fig.Position = p;
    catch
    end
end
min_w = max(320, min(need_w, round(0.85 * p(3))));
min_h = max(180, min(need_h, round(0.85 * p(4))));
zef_ui_bind_min_size(fig, min_w, min_h);

end

function local_known_tool_size(fig, lname)

if nargin < 2 || isempty(lname)
    return
end
if isappdata(fig, 'ZefGuideForm')
    return
end
p = [0 0 360 360];
try
    orig = fig.Units;
    fig.Units = 'pixels';
    p = fig.Position;
    fig.Units = orig;
catch
end
if contains(lname, 'forward and inverse')
    zef_ui_apply_size(fig, 820, 860, 760, 760);
elseif contains(lname, 'find synthetic source') && ~contains(lname, 'legacy') ...
        && ~contains(lname, 'eit') && ~contains(lname, 'patch') ...
        && ~contains(lname, 'roi') && ~contains(lname, 'gravity')
    zef_ui_apply_size(fig, 580, 520, 500, 420);
elseif contains(lname, 'es workbench')
    zef_ui_apply_size(fig, 580, 900, 500, 760);
elseif contains(lname, 'databank') || contains(lname, 'data bank')
    zef_ui_apply_size(fig, 920, 620, 720, 480);
elseif contains(lname, 'find synthetic') && contains(lname, 'eit')
    zef_ui_apply_size(fig, 680, 460, 580, 420);
elseif contains(lname, 'source tree')
    zef_ui_apply_size(fig, 560, 700, 480, 580);
elseif contains(lname, 'leadfield processing') || contains(lname, 'lead field processing')
    zef_ui_apply_size(fig, 880, 560, 720, 460);
elseif contains(lname, 'reconstruction tool')
    zef_ui_apply_size(fig, 800, 560, 640, 460);
elseif contains(lname, 'nse tool')
    try
        fig.AutoResizeChildren = 'off';
    catch
    end
elseif contains(lname, 'dti conductivity')
    scr = get(groot, 'ScreenSize');
    zef_ui_apply_size(fig, 720, min(1045, round(0.82 * scr(4))), 700, 640);
elseif contains(lname, 'beamformer')
    zef_ui_apply_size(fig, 800, max(p(4), 700), 640, 620);
elseif contains(lname, 'dipole scan')
    zef_ui_apply_size(fig, 640, max(p(4), 680), 520, 580);
elseif contains(lname, 'ias roi')
    zef_ui_apply_size(fig, 660, 640, 600, 520);
elseif contains(lname, 'multiresolution')
    zef_ui_apply_size(fig, 560, 720, 500, 640);
elseif contains(lname, 'preconditioned') || contains(lname, 'iterative relaxation')
    zef_ui_apply_size(fig, 1320, 540, 1080, 460);
elseif contains(lname, 'strip tool')
    zef_ui_apply_size(fig, 920, 600, 800, 580);
elseif contains(lname, 'wireframe')
    zef_ui_apply_size(fig, 520, 420, 440, 340);
elseif contains(lname, 'multi lead field')
    zef_ui_apply_size(fig, 880, 420, 760, 360);
elseif contains(lname, 'topography')
    zef_ui_apply_size(fig, 500, 440, 440, 360);
elseif contains(lname, 'find synthetic source (legacy)')
    zef_ui_apply_size(fig, 540, 400, 480, 360);
elseif contains(lname, 'source patch')
    zef_ui_apply_size(fig, 700, 440, 580, 400);
elseif contains(lname, 'find synthetic') && contains(lname, 'roi')
    zef_ui_apply_size(fig, 680, 540, 560, 480);
elseif contains(lname, 'filter tool')
    zef_ui_apply_size(fig, 720, 860, 700, 720);
    try
        local_unclip_top(fig);
    catch
    end
elseif contains(lname, 'sesame')
    zef_ui_apply_size(fig, 540, 560, 520, 520);
elseif contains(lname, 'dynamical plot') || contains(lname, 'plot queue')
    zef_ui_apply_size(fig, 720, 560, 600, 480);
end

end

function tf = local_skip_grow_to_content(lname)

tf = contains(lname, 'dti conductivity') || contains(lname, 'nse tool') ...
    || contains(lname, 'databank') || contains(lname, 'data bank') ...
    || contains(lname, 'filter tool') || contains(lname, 'kalman') ...
    || contains(lname, 'es workbench') || contains(lname, 'beamformer') ...
    || contains(lname, 'dipole scan') || contains(lname, 'preconditioned') ...
    || contains(lname, 'iterative relaxation') || contains(lname, 'source tree') ...
    || contains(lname, 'leadfield processing') || contains(lname, 'lead field processing') ...
    || contains(lname, 'reconstruction tool') || contains(lname, 'eit') ...
    || contains(lname, 'strip tool') || contains(lname, 'topography') ...
    || contains(lname, 'wireframe') || contains(lname, 'sesame') ...
    || contains(lname, 'multi lead field') || contains(lname, 'forward and inverse') ...
    || contains(lname, 'processing options') || contains(lname, 'mixture') ...
    || contains(lname, 'gmm plot') || contains(lname, 'gmm modeling') ...
    || contains(lname, 'gm modeling') || contains(lname, 'ias roi') ...
    || contains(lname, 'multiresolution') ...
    || contains(lname, 'source patch') || contains(lname, 'source (legacy)') ...
    || contains(lname, 'source roi') || contains(lname, 'strip tool') ...
    || contains(lname, 'find synthetic') && contains(lname, 'roi');

end

function local_ias_roi_pack(fig)

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if isappdata(fig, 'ZefIasRoiBusy') && isequal(getappdata(fig, 'ZefIasRoiBusy'), true)
    return
end
setappdata(fig, 'ZefIasRoiBusy', true);
try
    theme = zef_ui_theme();
    fig.Units = 'pixels';
    fig.AutoResizeChildren = 'off';
    W = fig.Position(3);
    H = fig.Position(4);
    ctrls = findall(fig, 'Type', 'uicontrol');
    hs = gobjects(0, 1);
    ys = zeros(0, 1);
    hts = zeros(0, 1);
    for i = 1:numel(ctrls)
        h = ctrls(i);
        try
            if ~isequal(h.Parent, fig)
                continue
            end
            h.Units = 'pixels';
            h.FontUnits = 'pixels';
            h.FontName = theme.font.name;
            st = lower(char(h.Style));
            min_h = 22;
            fs = theme.font.size;
            if any(strcmp(st, {'popupmenu', 'edit'}))
                min_h = 30;
            elseif strcmp(st, 'pushbutton')
                min_h = 30;
            elseif strcmp(st, 'text')
                fs = max(11, theme.font.size - 1);
                min_h = 20;
            end
            h.FontSize = fs;
            p = h.Position;
            p(4) = max(p(4), min_h);
            h.Position = p;
            hs(end+1, 1) = h; %#ok<AGROW>
            ys(end+1, 1) = p(2); %#ok<AGROW>
            hts(end+1, 1) = p(4); %#ok<AGROW>
        catch
        end
    end
    if numel(hs) < 6
        setappdata(fig, 'ZefIasRoiBusy', false);
        return
    end
    [~, ord] = sort(ys, 'descend');
    hs = hs(ord);
    ys = ys(ord);
    hts = hts(ord);
    row_id = zeros(numel(hs), 1);
    n_row = 0;
    row_y = zeros(0, 1);
    row_h = zeros(0, 1);
    for i = 1:numel(hs)
        placed = false;
        for r = 1:n_row
            if abs(ys(i) - row_y(r)) <= 14
                row_id(i) = r;
                row_y(r) = (row_y(r) + ys(i)) / 2; %#ok<AGROW>
                row_h(r) = max(row_h(r), hts(i)); %#ok<AGROW>
                placed = true;
                break
            end
        end
        if ~placed
            n_row = n_row + 1;
            row_id(i) = n_row;
            row_y(n_row) = ys(i); %#ok<AGROW>
            row_h(n_row) = hts(i); %#ok<AGROW>
        end
    end
    pad = 18;
    gap = 8;
    y = H - pad;
    for r = 1:n_row
        rh = max(22, row_h(r));
        y = y - rh;
        for i = 1:numel(hs)
            if row_id(i) ~= r
                continue
            end
            try
                p = hs(i).Position;
                p(2) = y;
                p(4) = rh;
                if p(1) + p(3) > W - 8
                    p(3) = max(40, W - 8 - p(1));
                end
                hs(i).Position = p;
            catch
            end
        end
        y = y - gap;
    end
    if y < pad
        extra = ceil(pad - y);
        fig.Position(4) = H + extra;
        for i = 1:numel(hs)
            try
                hs(i).Position(2) = hs(i).Position(2) + extra;
            catch
            end
        end
        zef_ui_bind_min_size(fig, 600, min(fig.Position(4), 640));
    elseif y > pad + 20
        delta = floor(y - pad);
        new_h = max(520, H - delta);
        delta = H - new_h;
        if delta > 8
            fig.Position(4) = new_h;
            for i = 1:numel(hs)
                try
                    hs(i).Position(2) = hs(i).Position(2) - delta;
                catch
                end
            end
            zef_ui_bind_min_size(fig, 600, min(new_h, 560));
        end
    end
catch
end
setappdata(fig, 'ZefIasRoiBusy', false);

end

function local_recapture_fitted_layout(fig, lname)

if isappdata(fig, 'ZefGuideForm')
    return
end
if contains(lname, 'ias roi') || contains(lname, 'multiresolution')
    return
end
if contains(lname, 'figure tool') && ~contains(lname, 'axes popup')
    return
end
if contains(lname, 'mesh visualization') || contains(lname, 'segmentation tool') ...
        || contains(lname, 'parcellation')
    return
end
try
    if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
        return
    end
catch
end
% Modern App Designer uifigures manage their own layout with uigridlayout
% and AutoResizeChildren.  Applying the legacy GUIDE proportional-scaling
% callback destroys their responsive layout and reintroduces clipping and
% wasted space.  Skip the recapture for uifigures so the tool-specific
% layout or the App Designer grid remains in control.
try
    if matlab.ui.internal.isUIFigure(fig)
        return
    end
catch
end
if contains(lname, 'sesame')
    try
        fig.AutoResizeChildren = 'off';
    catch
    end
    try
        setappdata(fig, 'ZefPixelResize', @(src) local_sesame_on_resize(src));
        fig.SizeChangedFcn = @(src, ~) local_sesame_on_resize(src);
        local_sesame_on_resize(fig);
    catch
    end
    return
end
try
    gs = findall(fig, 'Type', 'uigridlayout');
    for i = 1:numel(gs)
        if isequal(gs(i).Parent, fig)
            return
        end
    end
catch
end
try
    zef_set_size_change_function(fig, 2);
    setappdata(fig, 'ZefPixelResize', @(src) zef_window_manager('on_size_changed', src));
catch
end

end

function local_sesame_on_resize(fig)

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
try
    fig.AutoResizeChildren = 'off';
catch
end
try
    local_sesame_spread(fig);
    local_sesame_fill_panel(fig);
catch
end

end

function local_widen_narrow_dropdown_forms(fig)

n_dd = numel(findall(fig, 'Type', 'uidropdown'));
if n_dd < 2
    n_dd = numel(findall(fig, 'Style', 'popupmenu'));
end
if n_dd < 2
    return
end
try
    orig = fig.Units;
    fig.Units = 'pixels';
    p = fig.Position;
    fig.Units = orig;
catch
    return
end
if numel(p) < 4 || p(3) >= 640
    return
end
target_w = 560;
dds = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(dds)
    try
        items = dds(i).Items;
        for k = 1:numel(items)
            if numel(char(string(items{k}))) > 28
                target_w = 640;
            end
        end
    catch
    end
end
if p(3) >= target_w
    return
end
zef_ui_apply_size(fig, target_w, max(p(4), 360), max(460, round(0.82 * target_w)), ...
    max(280, round(0.85 * p(4))));

end

function local_nse_shift_right_column(fig)

try
    fig.Units = 'pixels';
    fw = fig.Position(3);
catch
    return
end
min_w = 300;
dds = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(dds)
    dd = dds(i);
    try
        gp = getpixelposition(dd, true);
        if gp(1) < 0.48 * fw
            continue
        end
        local_set_grid_col_min(dd, min_w);
        pr = dd.Parent;
        in_grid = false;
        try
            in_grid = isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout');
        catch
        end
        if in_grid
            try
                if isprop(dd, 'Items') && ~isempty(dd.Items)
                    dd.Tooltip = strjoin(string(dd.Items), newline);
                end
            catch
            end
            continue
        end
        extra = min_w - gp(3);
        if extra > 4
            p = dd.Position;
            room_right = fw - 12 - (p(1) + p(3));
            grow = min(extra, max(0, room_right));
            if grow > 4
                p(3) = p(3) + grow;
                p(3) = min(p(3), max(80, fw - 8 - p(1)));
                dd.Position = p;
            end
        end
        try
            if isprop(dd, 'Items') && ~isempty(dd.Items)
                dd.Tooltip = strjoin(string(dd.Items), newline);
            end
        catch
        end
    catch
    end
end

end

function local_set_grid_col_min(obj, min_w)

child = obj;
pr = obj.Parent;
depth = 0;
while isgraphics(pr) && isvalid(pr) && depth < 6
    t = '';
    try
        t = lower(char(pr.Type));
    catch
    end
    if strcmp(t, 'uigridlayout')
        try
            col = child.Layout.Column;
            if ~isempty(col)
                col = col(end);
                cw = pr.ColumnWidth;
                if iscell(cw) && col >= 1 && col <= numel(cw)
                    cur = cw{col};
                    if isnumeric(cur)
                        cw{col} = max(cur, min_w);
                    elseif ischar(cur) && ~contains(cur, 'x')
                        cw{col} = min_w;
                    end
                    pr.ColumnWidth = cw;
                end
            end
        catch
        end
        child = pr;
    elseif strcmp(t, 'figure') || strcmp(t, 'uifigure')
        break
    end
    pr = pr.Parent;
    depth = depth + 1;
end

end

function local_stretch_last_grid_column(fig, all_cols)

if nargin < 2 || isempty(all_cols)
    all_cols = false;
end
gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        cw = gs(i).ColumnWidth;
        if ~iscell(cw) || numel(cw) < 2
            continue
        end
        if all_cols
            for k = 1:numel(cw)
                cw{k} = '1x';
            end
        else
            cw = local_pair_field_columns(cw);
        end
        gs(i).ColumnWidth = cw;
    catch
    end
end

end

function cw = local_pair_field_columns(cw)

if numel(cw) == 2
    cw = {'fit', '1x'};
elseif numel(cw) == 4
    cw = {'fit', '1x', 'fit', '1x'};
elseif numel(cw) == 6
    cw = {'fit', '1x', 'fit', '1x', 'fit', '1x'};
else
    cw{end} = '1x';
end

end

function local_stretch_field_columns(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        cw = gs(i).ColumnWidth;
        if ~iscell(cw) || numel(cw) < 2
            continue
        end
        gs(i).ColumnWidth = local_pair_field_columns(cw);
    catch
    end
end

end

function local_weight_three_column_grid(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        pr = gs(i).Parent;
        pt = '';
        if isgraphics(pr)
            pt = lower(char(pr.Type));
        end
        if ~(strcmp(pt, 'figure') || strcmp(pt, 'uifigure'))
            continue
        end
        cw = gs(i).ColumnWidth;
        if ~iscell(cw) || numel(cw) ~= 3
            continue
        end
        gs(i).ColumnWidth = {'1.05x', '1.12x', '1.12x'};
        try
            gs(i).ColumnSpacing = max(28, gs(i).ColumnSpacing);
        catch
        end
    catch
    end
end

end

function local_relax_gutters(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        cw = gs(i).ColumnWidth;
        if ~iscell(cw)
            continue
        end
        if numel(cw) == 4
            gs(i).ColumnWidth = {'fit', '1x', 'fit', '1x'};
            gs(i).ColumnSpacing = max(28, gs(i).ColumnSpacing);
        elseif numel(cw) == 2
            gs(i).ColumnWidth = {'fit', '1x'};
            gs(i).ColumnSpacing = max(12, gs(i).ColumnSpacing);
        end
    catch
    end
end

end

function local_nse_widen_labels(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        if isempty(findall(gs(i), 'Type', 'uilabel'))
            continue
        end
        if ~isempty(findall(gs(i), 'Type', 'uidropdown')) ...
                && ~isempty(findall(gs(i), 'Type', 'uibutton'))
            continue
        end
        cw = gs(i).ColumnWidth;
        if ~iscell(cw) || numel(cw) < 2
            continue
        end
        cw{1} = 200;
        cw{end} = '1x';
        gs(i).ColumnWidth = cw;
    catch
    end
end

end

function local_nse_unclip_labels(fig)

labs = findall(fig, 'Type', 'uilabel');
for i = 1:numel(labs)
    lab = labs(i);
    try
        txt = strtrim(char(string(lab.Text)));
        if numel(txt) < 4
            continue
        end
        lab.WordWrap = 'off';
        need = min(280, 10 + round(7.4 * numel(txt)));
        pr = lab.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            try
                col = lab.Layout.Column;
                if ~isempty(col)
                    col = col(1);
                    cw = pr.ColumnWidth;
                    if iscell(cw) && col <= numel(cw) && isnumeric(cw{col}) ...
                            && cw{col} < need
                        cw{col} = need;
                        pr.ColumnWidth = cw;
                    end
                end
            catch
            end
            continue
        end
        try
            lab.Units = 'pixels';
            p = lab.Position;
            if p(3) < need
                lab.Position(3) = need;
            end
        catch
        end
    catch
    end
end

end

function local_databank_fit_menus(fig)

fw = 1280;
try
    fig.Units = 'pixels';
    fw = fig.Position(3);
catch
end
try
    gs = findall(fig, 'Type', 'uigridlayout');
    for i = 1:numel(gs)
        cw = gs(i).ColumnWidth;
        if iscell(cw) && numel(cw) >= 3
            cw{end} = '1x';
            gs(i).ColumnWidth = cw;
        end
    end
catch
end
dds = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(dds)
    dd = dds(i);
    try
        items = dd.Items;
        longest = 0;
        for k = 1:numel(items)
            longest = max(longest, numel(char(string(items{k}))));
        end
        if longest < 18
            continue
        end
        need = min(520, 36 + round(7.2 * longest));
        local_set_grid_col_min(dd, need);
        try
            dd.Tooltip = strjoin(string(items), newline);
        catch
        end
        pr = dd.Parent;
        if ~(isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout'))
            p = dd.Position;
            extra = need - p(3);
            if extra > 0
                room = max(0, fw - 16 - (p(1) + p(3)));
                grow = min(extra, room);
                if grow > 0
                    dd.Position = [p(1) p(2) p(3) + grow p(4)];
                end
            end
        end
        pan = [];
        try
            pan = ancestor(dd, 'uipanel');
        catch
        end
        if ~isempty(pan) && isgraphics(pan)
            try
                pan.Units = 'pixels';
                gp = getpixelposition(pan, true);
                remain = max(200, fw - gp(1) - 12);
                pan.Position(3) = max(pan.Position(3), min(remain, max(need + 20, 360)));
            catch
            end
        end
    catch
    end
end
try
    labs = findall(fig, 'Type', 'uilabel');
    for i = 1:numel(labs)
        txt = '';
        try
            txt = strtrim(char(string(labs(i).Text)));
        catch
            continue
        end
        if numel(txt) < 28
            continue
        end
        try
            labs(i).WordWrap = 'on';
            labs(i).VerticalAlignment = 'top';
            lp = labs(i).Position;
            labs(i).Position(4) = max(lp(4), 44);
        catch
        end
    end
catch
end
try
    cbs = findall(fig, 'Type', 'uicheckbox');
    for i = 1:numel(cbs)
        txt = '';
        try
            txt = strtrim(char(string(cbs(i).Text)));
        catch
            continue
        end
        if numel(txt) < 22
            continue
        end
        try
            cbs(i).WordWrap = 'on';
            pr = cbs(i).Parent;
            if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
                rh = pr.RowHeight;
                rr = 1;
                try
                    rr = cbs(i).Layout.Row;
                    if isnumeric(rr)
                        rr = rr(1);
                    end
                catch
                end
                if iscell(rh) && rr >= 1 && rr <= numel(rh)
                    rh{rr} = max(44, local_numeric_col(rh{rr}));
                    if ischar(rh{rr}) && strcmp(rh{rr}, 'fit')
                        rh{rr} = 44;
                    elseif isnumeric(rh{rr})
                        rh{rr} = max(44, rh{rr});
                    end
                    pr.RowHeight = rh;
                end
            else
                p = cbs(i).Position;
                cbs(i).Position(4) = max(p(4), 40);
            end
        catch
        end
    end
catch
end
try
    pans = findall(fig, 'Type', 'uipanel');
    for i = 1:numel(pans)
        gp = getpixelposition(pans(i), true);
        if gp(1) > 0.55 * fw
            pans(i).Units = 'pixels';
            pp = pans(i).Position;
            remain = max(160, fw - gp(1) - 12);
            pans(i).Position(3) = min(max(pp(3), 280), remain);
        end
    end
    % Dropdowns that live inside panels must not be wider than the panel.
    dds = findall(fig, 'Type', 'uidropdown');
    for i = 1:numel(dds)
        dd = dds(i);
        try
            pan = ancestor(dd, 'uipanel');
            if isempty(pan) || ~isscalar(pan) || ~isgraphics(pan) || ~strcmpi(char(pan.Type), 'uipanel')
                continue
            end
            pp = getpixelposition(pan, true);
            p = dd.Position;
            max_w = max(40, pp(3) - p(1) - 12);
            max_w = min(max_w, max(40, fw - 16 - (pp(1) + p(1))));
            if p(3) > max_w
                dd.Position = [p(1) p(2) max_w p(4)];
            end
        catch
        end
    end
catch
end

end

function n = local_numeric_col(val)

n = 0;
if isnumeric(val)
    n = val;
end

end

function local_fit_uilabels(fig)

try
    if ~matlab.ui.internal.isUIFigure(fig)
        return
    end
catch
    return
end
labs = findall(fig, 'Type', 'uilabel');
flds = local_cat_ui(findall(fig, 'Type', 'uieditfield'), ...
    findall(fig, 'Type', 'uinumericeditfield'), ...
    findall(fig, 'Type', 'uidropdown'));
for i = 1:numel(labs)
    lab = labs(i);
    try
        pr = lab.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            cw = pr.ColumnWidth;
            if iscell(cw) && (numel(cw) == 2 || numel(cw) == 4 || numel(cw) == 6)
                pr.ColumnWidth = local_pair_field_columns(cw);
            end
            continue
        end
        txt = strtrim(char(string(lab.Text)));
        if numel(txt) < 4
            continue
        end
        need = min(280, 10 + round(7.4 * numel(txt)));
        lp = lab.Position;
        gp = getpixelposition(lab, true);
        field_left = inf;
        for k = 1:numel(flds)
            try
                fgp = getpixelposition(flds(k), true);
            catch
                continue
            end
            if fgp(2) + fgp(4) < gp(2) + 4 || fgp(2) > gp(2) + gp(4) - 4
                continue
            end
            if fgp(1) > gp(1) + 8
                field_left = min(field_left, fgp(1));
            end
        end
        if isfinite(field_left)
            room = field_left - gp(1) - 8;
            if room < need
                shift = min(need - room, 140);
                n_same = 0;
                same = [];
                for k = 1:numel(flds)
                    try
                        fgp = getpixelposition(flds(k), true);
                    catch
                        continue
                    end
                    if fgp(2) + fgp(4) < gp(2) + 4 || fgp(2) > gp(2) + gp(4) - 4
                        continue
                    end
                    if fgp(1) > gp(1) + 8
                        n_same = n_same + 1;
                        same(end+1) = k; %#ok<AGROW>
                    end
                end
                if n_same == 1
                    try
                        fk = flds(same(1));
                        fp = fk.Position;
                        fk.Position(1) = fp(1) + shift;
                        field_left = field_left + shift;
                        room = field_left - gp(1) - 8;
                    catch
                    end
                end
            end
            lab.Position(3) = max(lp(3), min(need, max(lp(3), room)));
        elseif lp(3) < need
            lab.Position(3) = need;
        end
    catch
    end
end

end

function local_widen_long_dropdowns(fig, left_frac)

if nargin < 2 || isempty(left_frac)
    left_frac = 0.5;
end
try
    fig.Units = 'pixels';
    fw = fig.Position(3);
catch
    return
end
dds = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(dds)
    dd = dds(i);
    try
        gp = getpixelposition(dd, true);
        if gp(1) > left_frac * fw
            continue
        end
        items = dd.Items;
        longest = 0;
        for k = 1:numel(items)
            longest = max(longest, numel(char(string(items{k}))));
        end
        if longest < 16
            continue
        end
        need = min(280, 36 + round(7.2 * longest));
        extra = need - gp(3);
        if extra < 6
            continue
        end
        local_set_grid_col_min(dd, need);
        p = dd.Position;
        room_right = fw - 12 - (p(1) + p(3));
        grow = min(extra, max(0, room_right));
        if grow > 4
            p(3) = p(3) + grow;
            dd.Position = p;
        end
        try
            dd.Tooltip = strjoin(string(items), newline);
        catch
        end
    catch
    end
end

end

function local_sesame_spread(fig)

try
    fig.Units = 'pixels';
    fw = fig.Position(3);
catch
    return
end
gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        cw = gs(i).ColumnWidth;
        if iscell(cw) && numel(cw) == 2
            gs(i).ColumnWidth = {220, '1x'};
        end
    catch
    end
end
labs = findall(fig, 'Type', 'uilabel');
flds = local_cat_ui(findall(fig, 'Type', 'uieditfield'), ...
    findall(fig, 'Type', 'uinumericeditfield'), ...
    findall(fig, 'Type', 'uidropdown'));
lab_w = 200;
for i = 1:numel(labs)
    try
        txt = strtrim(char(string(labs(i).Text)));
        lab_w = max(lab_w, min(260, 12 + round(7.6 * numel(txt))));
    catch
    end
end
x_lab = 16;
x_fld = x_lab + lab_w + 10;
fld_w = max(160, min(320, fw - x_fld - 20));
for i = 1:numel(labs)
    lab = labs(i);
    try
        pr = lab.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            continue
        end
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uipanel')
            pp = getpixelposition(pr, true);
            if pp(3) < 0.62 * fw
                continue
            end
        end
        gp = getpixelposition(lab, true);
        if gp(1) > 0.45 * fw
            continue
        end
        p = lab.Position;
        try
            lab.Units = 'pixels';
            p = lab.Position;
        catch
        end
        lab.Position = [x_lab, p(2), lab_w, p(4)];
    catch
    end
end
for i = 1:numel(flds)
    fld = flds(i);
    try
        pr = fld.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            continue
        end
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uipanel')
            pp = getpixelposition(pr, true);
            if pp(3) < 0.62 * fw
                continue
            end
        end
        gp = getpixelposition(fld, true);
        if gp(1) < 0.15 * fw || gp(1) > 0.90 * fw
            continue
        end
        p = fld.Position;
        try
            fld.Units = 'pixels';
            p = fld.Position;
        catch
        end
        fld.Position = [x_fld, p(2), fld_w, p(4)];
    catch
    end
end
local_widen_clipped_buttons(fig, fw);
try
    local_sesame_stack_from_top(fig);
catch
end

end

function local_sesame_stack_from_top(fig)

try
    fig.Units = 'pixels';
    fw = fig.Position(3);
    fh = fig.Position(4);
catch
    return
end
row_h = 24;
gap = 6;
pad = 16;
pan = gobjects(0);
panels = findall(fig, 'Type', 'uipanel');
for i = 1:numel(panels)
    try
        if isequal(panels(i).Parent, fig)
            pan = panels(i);
            break
        end
    catch
    end
end

labs = findall(fig, 'Type', 'uilabel');
form_labs = gobjects(0, 1);
ys = [];
for i = 1:numel(labs)
    try
        if ~isequal(labs(i).Parent, fig)
            continue
        end
        gp = getpixelposition(labs(i), true);
        if gp(1) > 0.45 * fw
            continue
        end
        form_labs(end+1, 1) = labs(i); %#ok<AGROW>
        ys(end+1, 1) = gp(2); %#ok<AGROW>
    catch
    end
end
if numel(form_labs) < 3
    return
end
[~, ord] = sort(ys, 'descend');
form_labs = form_labs(ord);

flds = local_cat_ui(findall(fig, 'Type', 'uieditfield'), ...
    findall(fig, 'Type', 'uinumericeditfield'), ...
    findall(fig, 'Type', 'uidropdown'));
form_flds = gobjects(0, 1);
fys = [];
for i = 1:numel(flds)
    try
        if ~isequal(flds(i).Parent, fig)
            continue
        end
        gp = getpixelposition(flds(i), true);
        if gp(1) < 0.12 * fw
            continue
        end
        form_flds(end+1, 1) = flds(i); %#ok<AGROW>
        fys(end+1, 1) = gp(2); %#ok<AGROW>
    catch
    end
end
if ~isempty(fys)
    [~, ford] = sort(fys, 'descend');
    form_flds = form_flds(ford);
end

y = fh - pad - row_h;
n = min(numel(form_labs), max(numel(form_flds), numel(form_labs)));
for i = 1:numel(form_labs)
    try
        form_labs(i).Units = 'pixels';
        lp = form_labs(i).Position;
        form_labs(i).Position(2) = y;
        if i <= numel(form_flds)
            form_flds(i).Units = 'pixels';
            fp = form_flds(i).Position;
            form_flds(i).Position(2) = y;
            y = y - max([row_h, lp(4), fp(4)]) - gap;
        else
            y = y - max(row_h, lp(4)) - gap;
        end
    catch
    end
end

btns = findall(fig, 'Type', 'uibutton');
act = gobjects(0, 1);
for i = 1:numel(btns)
    try
        if ~isequal(btns(i).Parent, fig)
            continue
        end
        txt = lower(strtrim(char(string(btns(i).Text))));
        if contains(txt, 'apply') || strcmp(txt, 'start') || contains(txt, 'close')
            act(end+1, 1) = btns(i); %#ok<AGROW>
        end
    catch
    end
end
if ~isempty(act)
    y = y - 8;
    xs = zeros(numel(act), 1);
    for i = 1:numel(act)
        try
            xs(i) = act(i).Position(1);
        catch
        end
    end
    [~, bo] = sort(xs);
    act = act(bo);
    x0 = 16 + 200 + 10;
    for i = 1:numel(act)
        try
            act(i).Units = 'pixels';
            p = act(i).Position;
            act(i).Position = [x0 + (i - 1) * (p(3) + 8), y, p(3), max(p(4), 28)];
        catch
        end
    end
    y = y - 36;
end

if ~isempty(pan) && isgraphics(pan) && isvalid(pan)
    pan.Units = 'pixels';
    pan_h = max(96, min(180, y - pad));
    if pan_h < 80
        pan_h = 96;
    end
    pan.Position = [16, pad, max(200, fw - 32), pan_h];
end

end

function local_sesame_fill_panel(fig)

try
    fig.Units = 'pixels';
    fw = fig.Position(3);
    fh = fig.Position(4);
catch
    return
end
panels = findall(fig, 'Type', 'uipanel');
for i = 1:numel(panels)
    pan = panels(i);
    try
        pr = pan.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            continue
        end
        gp = getpixelposition(pan, true);
        if gp(2) > 0.45 * fh
            continue
        end
        pan.Units = 'pixels';
        p = pan.Position;
        p(1) = 16;
        p(3) = max(200, fw - 32);
        pan.Position = p;
        gs = findall(pan, 'Type', 'uigridlayout');
        for gi = 1:numel(gs)
            try
                cw = gs(gi).ColumnWidth;
                if iscell(cw) && numel(cw) >= 2
                    cw{end} = '1x';
                    gs(gi).ColumnWidth = cw;
                end
            catch
            end
        end
    catch
    end
end

end

function local_widen_clipped_buttons(fig, fw)

btns = [findall(fig, 'Type', 'uibutton'); findall(fig, 'Style', 'pushbutton')];
for i = 1:numel(btns)
    btn = btns(i);
    try
        pr = btn.Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            continue
        end
        txt = '';
        if isprop(btn, 'Text')
            txt = char(string(btn.Text));
        elseif isprop(btn, 'String')
            txt = char(string(btn.String));
        end
        txt = strtrim(regexprep(txt, '\s+', ' '));
        if numel(txt) < 18
            continue
        end
        need = min(fw - 32, 16 + round(7.2 * numel(txt)));
        u = '';
        try
            u = btn.Units;
            btn.Units = 'pixels';
        catch
        end
        p = btn.Position;
        if p(3) + 8 >= need
            if ~isempty(u)
                btn.Units = u;
            end
            continue
        end
        p(3) = min(need, max(80, fw - p(1) - 16));
        btn.Position = p;
        if ~isempty(u)
            try
                btn.Units = u;
            catch
            end
        end
    catch
    end
end

end

function local_nse_space_dropdowns(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        n_dd = numel(findall(gs(i), 'Type', 'uidropdown'));
        if n_dd < 4
            continue
        end
        gs(i).RowSpacing = max(8, gs(i).RowSpacing);
        rh = gs(i).RowHeight;
        for r = 1:numel(rh)
            if isnumeric(rh{r})
                rh{r} = max(28, rh{r});
            elseif ischar(rh{r}) && strcmp(rh{r}, 'fit')
                rh{r} = 28;
            end
        end
        gs(i).RowHeight = rh;
    catch
    end
end
dds = findall(fig, 'Type', 'uidropdown');
for i = 1:numel(dds)
    try
        pr = dds(i).Parent;
        if isgraphics(pr) && strcmpi(char(pr.Type), 'uigridlayout')
            continue
        end
        p = dds(i).Position;
        if p(4) < 22
            dds(i).Position(4) = 22;
        end
    catch
    end
end

end

function local_unclip_top(fig)

try
    orig = fig.Units;
    fig.Units = 'pixels';
    H = fig.Position(4);
    max_top = 0;
    kids = fig.Children;
    for i = 1:numel(kids)
        try
            vis = 'on';
            if isprop(kids(i), 'Visible')
                vis = char(string(kids(i).Visible));
            end
            if strcmpi(vis, 'off')
                continue
            end
            gp = getpixelposition(kids(i), true);
            max_top = max(max_top, gp(2) + gp(4));
        catch
        end
    end
    labs = findall(fig, 'Type', 'uilabel');
    for i = 1:numel(labs)
        try
            gp = getpixelposition(labs(i), true);
            max_top = max(max_top, gp(2) + gp(4));
        catch
        end
    end
    need = ceil(max_top + 10);
    if need > H + 2
        scr = get(groot, 'ScreenSize');
        fig.Position(4) = min(need, min(round(0.99 * scr(4)), scr(4) - 8));
        try
            gs = findall(fig, 'Type', 'uigridlayout');
            for i = 1:numel(gs)
                if isequal(gs(i).Parent, fig)
                    pad = gs(i).Padding;
                    if numel(pad) >= 4
                        gs(i).Padding = [pad(1), pad(2), pad(3), max(pad(4), 14)];
                    end
                end
            end
        catch
        end
    end
    if need > fig.Position(4) + 2
        try
            fig.Scrollable = 'on';
        catch
        end
    end
    fig.Units = orig;
catch
end

end

function local_nse_unoverlap(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        n_dd = numel(findall(gs(i), 'Type', 'uidropdown'));
        if n_dd < 2
            continue
        end
        gs(i).RowSpacing = max(12, gs(i).RowSpacing);
        rh = gs(i).RowHeight;
        for r = 1:numel(rh)
            if isnumeric(rh{r})
                rh{r} = max(32, rh{r});
            end
        end
        gs(i).RowHeight = rh;
    catch
    end
end
dds = findall(fig, 'Type', 'uidropdown');
pos = zeros(numel(dds), 4);
for i = 1:numel(dds)
    try
        gp = getpixelposition(dds(i), true);
        pos(i, :) = gp;
    catch
    end
end
[~, ord] = sort(pos(:, 2), 'descend');
for k = 1:numel(ord)-1
    a = ord(k);
    b = ord(k+1);
    try
        if abs(pos(a, 1) - pos(b, 1)) > 80
            continue
        end
        overlap = (pos(b, 2) + pos(b, 4)) - pos(a, 2);
        if overlap > 2
            pr = dds(b).Parent;
            if isgraphics(pr) && ~strcmpi(char(pr.Type), 'uigridlayout')
                p = dds(b).Position;
                dds(b).Position(2) = p(2) - overlap - 6;
            end
        end
    catch
    end
end

end

function local_nse_enable_scroll(fig)

try
    fig.Scrollable = 'on';
catch
end
gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        if isequal(gs(i).Parent, fig)
            gs(i).Tag = 'zef_nse_scroll';
            pad = gs(i).Padding;
            if numel(pad) >= 4
                gs(i).Padding = [max(pad(1), 10), max(pad(2), 28), ...
                    max(pad(3), 10), max(pad(4), 20)];
            end
            gs(i).Scrollable = 'on';
        end
    catch
    end
end

end

function objs = local_cat_ui(varargin)

objs = gobjects(0, 1);
for i = 1:nargin
    a = varargin{i};
    if isempty(a)
        continue
    end
    objs = [objs; a(:)]; %#ok<AGROW>
end

end


