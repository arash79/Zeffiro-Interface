function zef_layout_fss_roi(fig)
%ZEF_LAYOUT_FSS_ROI  Pixel layout for Find synthetic source ROI.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional figure() window. Geometry, orientation, signal, and
%   plot controls share aligned columns; amplitude/noise sit with the
%   other fields instead of in a detached third column.
%
%   See also zef_find_synthetic_source_ROI_window, zef_ui_ready.

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

if isappdata(fig, 'ZefFssRoiLayout')
    local_place(fig, theme);
    return
end

zef_ui_apply_size(fig, 720, 348, 680, 340);
fig.SizeChangedFcn = @(src, ~) local_place(src, theme);
setappdata(fig, 'ZefPixelResize', @(src) local_place(src, theme));
local_place(fig, theme);
zef_ui_bind_min_size(fig, 680, 340);
setappdata(fig, 'ZefFssRoiLayout', true);

end

function local_place(fig, theme)

if ~isgraphics(fig) || ~isvalid(fig)
    return
end
local_tag_from_zef();
try
    fig.Units = 'pixels';
catch
end
p = fig.Position;
W = p(3);
H = p(4);
pad = 14;
gap = 8;
row_h = 26;
btn_h = 32;
lab_w = min(176, max(148, round(0.26 * W)));
dd_w = min(220, max(148, round(0.30 * W)));
xyz = max(56, min(80, round((W - 2 * pad - lab_w - 8 - dd_w - 16 - 2 * gap) / 3)));
inner = max(240, W - 2 * pad);
x0 = pad;
x_dd = x0 + lab_w + 8;
x_xyz = x_dd + dd_w + 12;
geom_lab = 92;
geom_fld = max(56, min(80, round((inner - 3 * (geom_lab + 6)) / 3)));

y = H - pad - row_h;
local_label(fig, 'ROI shape:', x0, y, lab_w, row_h, theme);
local_field(fig, 'h_synth_source_ROI_style', x_dd, y, dd_w, row_h);
y = y - row_h - 8;

gx = x0;
local_label(fig, 'radius/radii [mm]:', gx, y, geom_lab, row_h, theme, ...
    'zef_fss_roi_lab_rad', 'Radius [mm]:');
local_field(fig, 'h_synth_source_ROI_radius', gx + geom_lab + 6, y, geom_fld, row_h);
gx = gx + geom_lab + 6 + geom_fld + 12;
local_label(fig, 'width(s) [mm]:', gx, y, geom_lab, row_h, theme, ...
    'zef_fss_roi_lab_w', 'Width [mm]:');
local_field(fig, 'h_synth_source_ROI_width', gx + geom_lab + 6, y, geom_fld, row_h);
gx = gx + geom_lab + 6 + geom_fld + 12;
local_label(fig, 'curvature(s):', gx, y, geom_lab, row_h, theme, ...
    'zef_fss_roi_lab_c', 'Curvature:');
local_field(fig, 'h_synth_source_ROI_curvature', gx + geom_lab + 6, y, geom_fld, row_h);
y = y - row_h - 8;

local_label(fig, 'ROI orientation(s):', x0, y, lab_w, row_h, theme, ...
    'zef_fss_roi_lab_ori', 'ROI orientation:');
local_field(fig, 'h_synth_source_ROI_ori_settings', x_dd, y, dd_w, row_h);
local_xyz(fig, {'h_synth_source_ROI_ori_x', 'h_synth_source_ROI_ori_y', ...
    'h_synth_source_ROI_ori_z'}, x_xyz, y, xyz, gap, row_h);
y = y - row_h - 8;

local_label(fig, 'ROI center position(s):', x0, y, lab_w, row_h, theme, ...
    'zef_fss_roi_lab_ctr', 'ROI center:');
local_xyz(fig, {'h_synth_source_ROI_x', 'h_synth_source_ROI_y', ...
    'h_synth_source_ROI_z'}, x_xyz, y, xyz, gap, row_h);
y = y - row_h - 8;

local_label(fig, 'Dipole orientation(s):', x0, y, lab_w, row_h, theme, ...
    'zef_fss_roi_lab_dip', 'Dipole orientation:');
local_field(fig, 'h_synth_source_ROI_dipOri_style', x_dd, y, dd_w, row_h);
local_xyz(fig, {'h_synth_source_ROI_dipOri_x', 'h_synth_source_ROI_dipOri_y', ...
    'h_synth_source_ROI_dipOri_z'}, x_xyz, y, xyz, gap, row_h);
y = y - row_h - 10;

local_label(fig, 'Amplitude(s) (nAm):', x0, y, lab_w, row_h, theme, ...
    'zef_fss_roi_lab_amp', 'Amplitude (nAm):');
amp_w = min(100, dd_w);
local_field(fig, 'h_synth_source_ROI_amp', x_dd, y, amp_w, row_h);
nx = x_dd + amp_w + 16;
nlab = min(140, max(108, inner - (nx - x0) - 88));
local_label(fig, 'Noise STD w.r.t. amplitude:', nx, y, nlab, row_h, theme, ...
    'zef_fss_roi_lab_noise', 'Noise STD (rel.):');
local_field(fig, 'h_synth_source_ROI_noise', nx + nlab + 8, y, ...
    max(56, min(100, inner - (nx + nlab + 8 - x0))), row_h);
y = y - row_h - 8;

local_label(fig, 'Plotting:', x0, y, lab_w, row_h, theme);
plot_dd = min(120, dd_w);
local_field(fig, 'h_synth_source_ROI_plot_style', x_dd, y, plot_dd, row_h);
cx = x_dd + plot_dd + 12;
c_lab = 48;
c_fld = 100;
local_label(fig, 'Color:', cx, y, c_lab, row_h, theme);
local_field(fig, 'h_synth_source_ROI_color', cx + c_lab + 6, y, c_fld, row_h);
lx = cx + c_lab + 6 + c_fld + 12;
len_lab = 88;
local_label(fig, 'Dipole length:', lx, y, len_lab, row_h, theme);
local_field(fig, 'h_synth_source_ROI_length', lx + len_lab + 6, y, ...
    max(56, min(80, inner - (lx + len_lab + 6 - x0))), row_h);
y = y - row_h - 12;

local_hide_coord_captions(fig);

btn_w = max(168, min(220, round((inner - gap) / 2)));
btn_y = max(pad, y - btn_h);
pair = 2 * btn_w + gap;
bx = x0 + max(0, (inner - pair) / 2);
local_button(fig, 'Create synthetic data', bx, btn_y, btn_w, btn_h, theme);
local_button(fig, 'Plot source(s)', bx + btn_w + gap, btn_y, btn_w, btn_h, theme);

ctrls = findall(fig, 'Type', 'uicontrol');
for i = 1:numel(ctrls)
    try
        if isprop(ctrls(i), 'FontUnits')
            ctrls(i).FontUnits = 'pixels';
            if ctrls(i).FontSize > 16 || ctrls(i).FontSize < 9
                ctrls(i).FontSize = theme.font.size;
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
    'h_synth_source_ROI_style', 'h_synth_source_ROI_radius', 'h_synth_source_ROI_width', ...
    'h_synth_source_ROI_curvature', 'h_synth_source_ROI_ori_settings', ...
    'h_synth_source_ROI_ori_x', 'h_synth_source_ROI_ori_y', 'h_synth_source_ROI_ori_z', ...
    'h_synth_source_ROI_x', 'h_synth_source_ROI_y', 'h_synth_source_ROI_z', ...
    'h_synth_source_ROI_dipOri_style', 'h_synth_source_ROI_dipOri_x', ...
    'h_synth_source_ROI_dipOri_y', 'h_synth_source_ROI_dipOri_z', ...
    'h_synth_source_ROI_amp', 'h_synth_source_ROI_noise', ...
    'h_synth_source_ROI_plot_style', 'h_synth_source_ROI_color', ...
    'h_synth_source_ROI_length'};
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

function local_label(fig, str, x, y, w, h, theme, tag, short)

if nargin < 8
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
if isempty(lab)
    found = findall(fig, 'Style', 'text');
    needle = lower(strtrim(regexprep(str, ':$', '')));
    for i = 1:numel(found)
        try
            t = lower(strtrim(regexprep(char(string(found(i).String)), ':$', '')));
            if strcmp(t, needle) || strncmp(t, needle, numel(needle))
                lab = found(i);
                break
            end
        catch
        end
    end
end
if isempty(lab)
    return
end
lab = lab(1);
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
    lab.Visible = 'on';
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
if isempty(hnd) || ~(isgraphics(hnd(1)) && isvalid(hnd(1)))
    return
end
hnd = hnd(1);
try
    hnd.Tag = name;
catch
end
try
    hnd.Units = 'pixels';
    if isprop(hnd, 'FontUnits')
        hnd.FontUnits = 'pixels';
        hnd.FontSize = 11;
    end
    hnd.Position = [x, y, max(36, w), h];
    hnd.Visible = 'on';
catch
end

end

function local_xyz(fig, names, x, y, xyz, gap, h)

for i = 1:numel(names)
    local_field(fig, names{i}, x + (i - 1) * (xyz + gap), y, xyz, h);
end

end

function local_button(fig, str, x, y, w, ht, theme)

found = findall(fig, 'Style', 'pushbutton', 'String', str);
if isempty(found)
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
        if strcmp(lab, str)
            found = found(i);
            break
        end
    end
end
if isempty(found) || ~isgraphics(found(1))
    return
end
h = found(1);
try
    h.Units = 'pixels';
    h.Position = [x, y, max(80, w), ht];
    h.FontUnits = 'pixels';
    h.FontSize = theme.font.size;
    h.Visible = 'on';
catch
end
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

end

function local_hide_coord_captions(fig)

found = findall(fig, 'Style', 'text');
for i = 1:numel(found)
    try
        t = lower(strtrim(char(string(found(i).String))));
        if contains(t, 'coord')
            found(i).Visible = 'off';
        end
    catch
    end
end

end
