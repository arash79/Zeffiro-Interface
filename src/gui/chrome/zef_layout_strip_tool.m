function zef_layout_strip_tool(fig)
%ZEF_LAYOUT_STRIP_TOOL  Pixel layout for the Strip tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional figure() window. Geometry and encapsulation sit in two
%   aligned bands; the colored strip list absorbs extra height on resize.
%
%   See also zef_strip_tool_window, zef_ui_ready.

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

if isappdata(fig, 'ZefStripLayout')
    local_place(fig, theme);
    return
end

zef_ui_apply_size(fig, 900, 560, 780, 480);
fig.SizeChangedFcn = @(src, ~) local_place(src, theme);
setappdata(fig, 'ZefPixelResize', @(src) local_place(src, theme));
local_place(fig, theme);
zef_ui_bind_min_size(fig, 780, 480);
setappdata(fig, 'ZefStripLayout', true);

end

function local_place(fig, theme)

if ~isgraphics(fig) || ~isvalid(fig)
    return
end
st = local_strip();
try
    fig.Units = 'pixels';
catch
end
p = fig.Position;
W = p(3);
H = p(4);
pad = 14;
gap = 10;
row_h = 26;
hdr_h = 20;
btn_h = 30;
lab_l = min(188, max(156, round(0.21 * W)));
xyz = 50;
xyz_gap = 4;
left_block = lab_l + 8 + 3 * xyz + 2 * xyz_gap;
rest = max(280, W - pad - left_block - pad - gap);
mid_lab = min(128, max(100, round(0.28 * rest)));
mid_fld = 72;
r_lab = min(168, max(118, round(0.36 * rest)));
r_fld = max(72, rest - mid_lab - 8 - mid_fld - 12 - r_lab - 8);

x0 = pad;
x_xyz = x0 + lab_l + 8;
x_mid = x0 + left_block + gap;
x_mid_f = x_mid + mid_lab + 8;
x_r = x_mid_f + mid_fld + 12;
x_r_f = x_r + r_lab + 8;
inner = W - 2 * pad;

y = H - pad - hdr_h;
local_header(fig, 'zef_strip_sec_strip', 'Strip', x0, y, inner, hdr_h, theme);
y = y - hdr_h - 4;

local_label(fig, 'Strip tip point (mm):', x0, y, lab_l, row_h, theme, ...
    'zef_strip_lab_tip', 'Tip point (mm):');
local_xyz(fig, st, 'h_tip_point', x_xyz, y, xyz, xyz_gap, row_h);
local_label(fig, 'Roll (rad):', x_mid, y, mid_lab, row_h, theme);
local_field(fig, st, 'h_strip_angle', x_mid_f, y, mid_fld, row_h);
local_label(fig, 'Conductivity (S/m):', x_r, y, r_lab, row_h, theme, 'zef_strip_lab_cond');
local_field(fig, st, 'h_strip_conductivity', x_r_f, y, r_fld, row_h);
y = y - row_h - 6;

local_label(fig, 'Strip orientation:', x0, y, lab_l, row_h, theme, ...
    'zef_strip_lab_ori', 'Orientation:');
local_xyz(fig, st, 'h_orientation_axis', x_xyz, y, xyz, xyz_gap, row_h);
local_label(fig, 'Length (mm):', x_mid, y, mid_lab, row_h, theme, 'zef_strip_lab_len');
local_field(fig, st, 'h_strip_length', x_mid_f, y, mid_fld, row_h);
local_label(fig, 'Impedance (Ohm):', x_r, y, r_lab, row_h, theme);
local_field(fig, st, 'h_strip_impedance', x_r_f, y, r_fld, row_h);
y = y - row_h - 6;

local_label(fig, 'Model:', x0, y, lab_l, row_h, theme);
local_field(fig, st, 'h_strip_model', x_xyz, y, 3 * xyz + 2 * xyz_gap, row_h);
local_label(fig, 'Number of sectors:', x_mid, y, mid_lab, row_h, theme, ...
    'zef_strip_lab_sec', 'Sectors:');
local_field(fig, st, 'h_strip_n_sectors', x_mid_f, y, mid_fld, row_h);
local_label(fig, 'Tag:', x_r, y, r_lab, row_h, theme);
local_field(fig, st, 'h_strip_tag', x_r_f, y, r_fld, row_h);
y = y - row_h - gap;

local_header(fig, 'zef_strip_sec_encap', 'Encapsulation', x0, y, inner, hdr_h, theme);
y = y - hdr_h - 4;

local_label(fig, 'Encapsulation shift (mm):', x0, y, lab_l, row_h, theme, ...
    'zef_strip_lab_esh', 'Shift (mm):');
local_xyz(fig, st, 'h_encapsulation_shift', x_xyz, y, xyz, xyz_gap, row_h);
local_label(fig, 'Thickness (mm):', x_mid, y, mid_lab, row_h, theme);
local_field(fig, st, 'h_encapsulation_thickness', x_mid_f, y, mid_fld, row_h);
local_label(fig, 'Encapsulation conductivity (S/m):', x_r, y, r_lab, row_h, theme, ...
    'zef_strip_lab_ec', 'Conductivity (S/m):');
local_field(fig, st, 'h_encapsulation_conductivity', x_r_f, y, r_fld, row_h);
y = y - row_h - 6;

local_label(fig, 'Encapsulation orientation:', x0, y, lab_l, row_h, theme, ...
    'zef_strip_lab_eo', 'Orientation:');
local_xyz(fig, st, 'h_encapsulation_orientation_axis', x_xyz, y, xyz, xyz_gap, row_h);
local_label(fig, 'Encapsulation length (mm):', x_mid, y, mid_lab, row_h, theme, ...
    'zef_strip_lab_el', 'Length (mm):');
local_field(fig, st, 'h_encapsulation_length', x_mid_f, y, mid_fld, row_h);
local_label(fig, 'Include encapsulation:', x_r, y, r_lab, row_h, theme, ...
    'zef_strip_lab_inc', 'Include:');
local_field(fig, st, 'h_encapsulation_on', x_r_f, y, 22, row_h);
y = y - row_h - gap;

btn_y = pad;
list_y = btn_y + btn_h + gap;
list_h = max(96, y - list_y);
local_list(fig, st, x0, list_y, inner, list_h);

nb = 5;
bw = max(88, min(140, (inner - (nb - 1) * 8) / nb));
total = nb * bw + (nb - 1) * 8;
bx = x0 + max(0, (inner - total) / 2);
btns = {'Add', 'Embed', 'Add contacts', 'Delete', 'Plot'};
for i = 1:nb
    local_by_string(fig, btns{i}, bx + (i - 1) * (bw + 8), btn_y, bw, btn_h);
end

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

function st = local_strip()

st = struct();
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, 'strip_tool')
        st = zef.strip_tool;
    end
catch
end

end

function local_header(fig, tag, str, x, y, w, h, theme)

lab = findall(fig, 'Tag', tag);
if isempty(lab)
    lab = uicontrol(fig, 'Style', 'text', 'Tag', tag, 'Units', 'pixels', ...
        'HorizontalAlignment', 'left', 'HitTest', 'off');
end
lab = lab(1);
lab.Units = 'pixels';
lab.Position = [x, y, w, h];
lab.String = str;
try
    lab.FontUnits = 'pixels';
    lab.FontSize = theme.font.size;
    lab.FontWeight = 'bold';
    lab.ForegroundColor = theme.color.header;
    lab.BackgroundColor = theme.color.bg;
catch
end

end

function local_label(fig, str, x, y, w, h, theme, tag, short)

if nargin < 8 || isempty(tag)
    tag = '';
end
if nargin < 9
    short = '';
end
lab = gobjects(0);
if ~isempty(tag)
    lab = findall(fig, 'Tag', tag);
end
if isempty(lab)
    lab = findall(fig, 'Style', 'text', 'String', str);
end
if isempty(lab) && ~isempty(short)
    lab = findall(fig, 'Style', 'text', 'String', short);
end
if isempty(lab)
    return
end
lab = lab(1);
try
    tg = char(lab.Tag);
    if strcmp(tg, 'zef_strip_sec_strip') || strcmp(tg, 'zef_strip_sec_encap')
        return
    end
catch
end
if ~isempty(tag)
    try
        lab.Tag = tag;
    catch
    end
end
if ~isempty(short)
    try
        lab.String = short;
    catch
    end
end
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

function local_xyz(fig, st, prefix, x, y, xyz, gap, h)

for i = 1:3
    name = sprintf('%s_%d', prefix, i);
    local_field(fig, st, name, x + (i - 1) * (xyz + gap), y, xyz, h);
end

end

function local_field(fig, st, name, x, y, w, h)

hnd = gobjects(0);
if isstruct(st) && isfield(st, name)
    hnd = st.(name);
end
if isempty(hnd) || ~(isgraphics(hnd(1)) && isvalid(hnd(1)))
    hnd = findall(fig, 'Tag', name);
end
if isempty(hnd) || ~(isgraphics(hnd(1)) && isvalid(hnd(1)))
    return
end
hnd = hnd(1);
try
    hnd.Units = 'pixels';
    if isprop(hnd, 'FontUnits')
        hnd.FontUnits = 'pixels';
        hnd.FontSize = 11;
    end
    hnd.Position = [x, y, max(18, w), h];
catch
end

end

function local_list(fig, st, x, y, w, h)

hnd = gobjects(0);
if isstruct(st) && isfield(st, 'h_strip_list')
    hnd = st.h_strip_list;
end
if isempty(hnd) || ~(isgraphics(hnd(1)) && isvalid(hnd(1)))
    hnd = findall(fig, 'Tag', 'h_strip_list');
end
if isempty(hnd)
    hnd = findall(fig, 'Tag', 'strip_list');
end
if isempty(hnd) || ~(isgraphics(hnd(1)) && isvalid(hnd(1)))
    return
end
host = hnd(1);
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
    host.Position = [x, y, max(80, w), max(48, h)];
catch
end

end

function local_by_string(fig, str, x, y, w, ht)

found = findall(fig, 'Type', 'uicontrol', 'Style', 'pushbutton');
h = gobjects(0);
for i = 1:numel(found)
    lab = '';
    try
        lab = strtrim(char(found(i).String));
    catch
    end
    if strcmp(lab, str)
        h = found(i);
        break
    end
end
if isempty(h) || ~isgraphics(h)
    return
end
try
    h.Units = 'pixels';
    h.Position = [x, y, max(48, w), ht];
    h.FontUnits = 'pixels';
    h.FontSize = 11;
catch
end

end
