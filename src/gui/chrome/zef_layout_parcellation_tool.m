function zef_layout_parcellation_tool(fig)
%ZEF_LAYOUT_PARCELLATION_TOOL  Pixel layout for the Parcellation tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional figure() window. SizeChangedFcn keeps form fields, the
%   ROI list, action grids, and plot controls aligned as the window is
%   resized. Minimum size is taken from the stacked content.
%
%   See also zef_parcellation_tool_window, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end

theme = zef_ui_theme();
try
    fig.Color = theme.color.bg;
    fig.Resize = 'on';
    fig.AutoResizeChildren = 'off';
    fig.Units = 'pixels';
catch
end

if isappdata(fig, 'ZefParcellationLayout')
    try
        mins = [500, 700];
        if isappdata(fig, 'ZefMinSize')
            mins = getappdata(fig, 'ZefMinSize');
        end
        fig.Units = 'pixels';
        p = fig.Position;
        if p(3) < mins(1) || p(4) < mins(2)
            zef_ui_apply_size(fig, max(p(3), 560), max(p(4), 780), mins(1), mins(2));
        end
    catch
    end
    local_place(fig, theme);
    return
end

zef_ui_apply_size(fig, 560, 780, 500, 700);
fig.SizeChangedFcn = @(src, ~) local_place(src, theme);
local_place(fig, theme);
zef_ui_bind_min_size(fig, 500, 700);
setappdata(fig, 'ZefParcellationLayout', true);

end

function local_place(fig, theme)

if ~isgraphics(fig) || ~isvalid(fig)
    return
end
local_tag_from_zef();
tb = findall(fig, 'Tag', 'togglebutton1');
if ~isempty(tb)
    try
        tb(1).Tag = 'h_use_parcellation';
    catch
    end
end
fig.Units = 'pixels';
p = fig.Position;
W = p(3);
H = p(4);
pad = 12;
gap = 10;
row_h = 24;
btn_h = 28;
lab_w = 128;
inner = max(200, W - 2 * pad);

% Vertical budget: form 5, roi add/delete, roi list, embed row, list flex,
% tools 3, plot-type 1, series list flex, plot row 1.
fixed = 5 * (row_h + 6) + 2 + 3 * (btn_h + 6) + (btn_h + gap) ...
    + gap + (3 * btn_h + 18) + (row_h + 6) + gap + btn_h + 2 * pad;
remain = max(80, H - fixed);
list_h = max(56, round(0.62 * remain));
series_h = max(36, remain - list_h);
if list_h + series_h > remain
    list_h = max(48, remain - 36);
    series_h = max(32, remain - list_h);
end

y = H - pad - row_h;
local_tag_from_zef();
pairs = { ...
    'Parcellation name:', 'h_parcellation_name'; ...
    'ROI name:', 'h_parcellation_roi_name'; ...
    'ROI center:', 'h_parcellation_roi_center'; ...
    'ROI radius:', 'h_parcellation_roi_radius'; ...
    'ROI color:', 'h_parcellation_roi_color'};
for i = 1:size(pairs, 1)
    local_label(fig, pairs{i, 1}, pad, y, lab_w, row_h, theme);
    local_field(fig, pairs{i, 2}, pad + lab_w + 8, y, inner - lab_w - 8, row_h);
    y = y - row_h - 6;
end

y = y - 2;
col2 = (inner - gap) / 2;
local_by_string(fig, 'Add ROI', pad, y, col2, btn_h);
local_by_string(fig, 'Delete ROI', pad + col2 + gap, y, col2, btn_h);
y = y - btn_h - 6;
    local_field(fig, 'h_parcellation_roi_list', pad, y, inner, btn_h);
    if isempty(findall(fig, 'Tag', 'h_parcellation_roi_list'))
        local_field(fig, 'popupmenu1', pad, y, inner, btn_h);
    end
y = y - btn_h - 6;

col4 = (inner - 3 * gap) / 4;
roi_btns = {'Embed ROIs', 'Pick ROI center', 'Pick ROI color', 'Plot ROIs'};
for i = 1:4
    local_by_string(fig, roi_btns{i}, pad + (i - 1) * (col4 + gap), y, col4, btn_h);
end
y = y - btn_h - gap;

local_list(fig, 'listbox1', pad, y - list_h, inner, list_h);
y = y - list_h - gap;

left_pair_w = max(80, (inner * 0.46 - gap) / 2);
right_x = pad + 2 * (left_pair_w + gap);
right_w = max(120, inner - 2 * (left_pair_w + gap));
seg_lab = 78;
tool_rows = { ...
    'Colortable', 'Reset'; ...
    'Points', 'Interpolate'; ...
    'Segmentation', 'Time series'};
yy = y;
for i = 1:3
    local_by_string(fig, tool_rows{i, 1}, pad, yy - btn_h, left_pair_w, btn_h);
    local_by_string(fig, tool_rows{i, 2}, pad + left_pair_w + gap, yy - btn_h, left_pair_w, btn_h);
    yy = yy - btn_h - 6;
end
local_label(fig, 'Segment:', right_x, y - btn_h, seg_lab, btn_h, theme);
local_field(fig, 'h_parcellation_segment', right_x + seg_lab + 4, y - btn_h, ...
    right_w - seg_lab - 4, btn_h);
local_label(fig, 'Span (mm):', right_x, y - 2 * btn_h - 6, seg_lab, btn_h, theme);
local_field(fig, 'h_parcellation_tolerance', right_x + seg_lab + 4, ...
    y - 2 * btn_h - 6, right_w - seg_lab - 4, btn_h);
act_y = y - 3 * btn_h - 18;
local_by_string(fig, 'Activate', right_x, act_y, right_w, btn_h);
local_field(fig, 'h_use_parcellation', right_x, act_y, right_w, btn_h);
row3_bottom = yy + 6;
y = row3_bottom - gap - row_h;

local_label(fig, 'Plot type:', pad, y, 90, row_h, theme);
local_field(fig, 'h_parcellation_time_series_mode', pad + 96, y, inner - 96, row_h);
y = y - row_h - 6;

min_series_y = pad + btn_h + gap;
series_h = min(series_h, max(32, y - min_series_y));
local_field(fig, 'h_time_series_tools_list', pad, y - series_h, inner, series_h);
y = y - series_h - gap;

plot_w = 108;
local_by_string(fig, 'Plot', pad, pad, plot_w, btn_h);
local_field(fig, 'h_parcellation_plot_type', pad + plot_w + gap, pad, inner - plot_w - gap, btn_h);

ctrls = findall(fig, 'Type', 'uicontrol');
for i = 1:numel(ctrls)
    try
        if isprop(ctrls(i), 'FontUnits')
            ctrls(i).FontUnits = 'pixels';
            if ctrls(i).FontSize > 16 || ctrls(i).FontSize < 9
                ctrls(i).FontSize = 11;
            end
        end
    catch
    end
end

end

function local_tag_from_zef()

try
    zef = evalin('base', 'zef');
catch
    return
end
names = { ...
    'h_parcellation_name', 'h_parcellation_roi_name', 'h_parcellation_roi_center', ...
    'h_parcellation_roi_radius', 'h_parcellation_roi_color', 'h_parcellation_roi_list', ...
    'h_parcellation_segment', 'h_parcellation_tolerance', 'h_use_parcellation', ...
    'h_parcellation_time_series_mode', 'h_time_series_tools_list', 'h_parcellation_plot_type'};
for i = 1:numel(names)
    nm = names{i};
    try
        if isfield(zef, nm) && isgraphics(zef.(nm)) && isvalid(zef.(nm))
            zef.(nm).Tag = nm;
        end
    catch
    end
end

end

function local_label(fig, str, x, y, w, h, theme)

lab = findall(fig, 'Style', 'text', 'String', str);
if isempty(lab)
    return
end
lab = lab(1);
lab.Units = 'pixels';
lab.Position = [x, y, w, h];
lab.HorizontalAlignment = 'right';
try
    lab.FontUnits = 'pixels';
    lab.FontSize = theme.font.size;
    lab.FontWeight = 'normal';
    lab.BackgroundColor = theme.color.bg;
    lab.ForegroundColor = theme.color.text;
catch
end

end

function local_field(fig, name, x, y, w, h)

hnd = findall(fig, 'Tag', name);
if isempty(hnd)
    try
        zef = evalin('base', 'zef');
        if isfield(zef, name)
            hnd = zef.(name);
        end
    catch
        hnd = gobjects(0);
    end
end
if isempty(hnd) || ~isgraphics(hnd(1))
    return
end
hnd = hnd(1);
try
    hnd.Tag = name;
catch
end
try
    if isprop(hnd, 'Units')
        hnd.Units = 'pixels';
    end
    if isprop(hnd, 'FontUnits')
        hnd.FontUnits = 'pixels';
        hnd.FontSize = 11;
    end
    hnd.Position = [x, y, max(40, w), h];
    try
        caps = findall(hnd.Parent, 'Type', 'uicontrol', 'Style', 'text');
        for zef_i = 1:numel(caps)
            ud = [];
            try
                ud = caps(zef_i).UserData;
            catch
            end
            if ~isempty(ud) && isequal(ud, hnd)
                inset = 3;
                caps(zef_i).Units = 'pixels';
                caps(zef_i).Position = [x + inset, y + inset, ...
                    max(8, w - 2 * inset), max(10, h - 2 * inset)];
            end
        end
    catch
    end
catch
end

end

function h = local_by_string(fig, str, x, y, w, ht)

h = gobjects(0);
found = findall(fig, 'Type', 'uicontrol');
for i = 1:numel(found)
    lab = '';
    try
        lab = strtrim(char(found(i).String));
    catch
    end
    if isempty(lab)
        try
            lab = strtrim(char(getappdata(found(i), 'ZefButtonLabel')));
        catch
        end
    end
    if ~strcmp(lab, str)
        continue
    end
    try
        ud = found(i).UserData;
        if ~isempty(ud) && isgraphics(ud) && isvalid(ud) && isappdata(ud, 'ZefRoundKey')
            continue
        end
    catch
    end
    h = found(i);
    break
end
if isempty(h) || ~isgraphics(h)
    return
end
try
    h.Units = 'pixels';
    h.Position = [x, y, max(40, w), ht];
    h.FontUnits = 'pixels';
    h.FontSize = 11;
    try
        caps = findall(h.Parent, 'Type', 'uicontrol', 'Style', 'text');
        for zef_i = 1:numel(caps)
            ud = [];
            try
                ud = caps(zef_i).UserData;
            catch
            end
            if ~isempty(ud) && isequal(ud, h)
                inset = 3;
                caps(zef_i).Units = 'pixels';
                caps(zef_i).Position = [x + inset, y + inset, ...
                    max(8, w - 2 * inset), max(10, ht - 2 * inset)];
            end
        end
    catch
    end
catch
end

end

function local_list(fig, tag, x, y, w, h)

lst = findall(fig, 'Tag', tag);
if isempty(lst)
    return
end
host = lst(1);
try
    if strcmpi(char(host.Type), 'uihtml') && ~isempty(host.Parent) ...
            && host.Parent ~= fig
        host = host.Parent;
    end
catch
end
try
    if isprop(host, 'Units')
        host.Units = 'pixels';
    end
    host.Position = [x, y, w, h];
    if isprop(host, 'FontUnits')
        host.FontUnits = 'pixels';
        host.FontSize = 11;
    end
catch
end

end
