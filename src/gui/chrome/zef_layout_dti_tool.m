function zef_layout_dti_tool(fig)
%ZEF_LAYOUT_DTI_TOOL  Grid layout for the DTI Conductivity Tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Replaces absolute Positions plus proportional SizeChangedFcn scaling
%   with nested uigridlayout panels so file fields stay aligned and the
%   window resizes without overlapping controls.
%
%   See also zef_dti_conductivity_window, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    zef_ui_adapt_grid(fig);
    return
end

theme = zef_ui_theme();
try
    fig.SizeChangedFcn = '';
    fig.AutoResizeChildren = 'off';
    fig.Scrollable = 'off';
    fig.Units = 'pixels';
catch
end

root = uigridlayout(fig, [5 1]);
root.Tag = 'zef_ui_root';
root.RowHeight = {'fit', 'fit', 'fit', '1x', '1x'};
root.Padding = [12 12 12 12];
root.RowSpacing = 10;
try
    root.BackgroundColor = theme.color.bg;
    root.Scrollable = 'off';
catch
end

file_p = local_panel(root, theme, 'FreeSurfer Input Files');
file_outer = local_grid(file_p, [1 2], theme);
file_outer.ColumnWidth = {'1x', 108};
file_outer.ColumnSpacing = 10;
file_outer.Padding = [8 8 8 8];

file_left = local_grid(file_outer, [5 3], theme);
file_left.ColumnWidth = {'fit', '1x', 88};
file_left.RowHeight = {28, 20, 28, 28, 28};
file_left.RowSpacing = 6;
file_left.ColumnSpacing = 8;
file_left.Padding = [0 0 0 0];
local_put(file_left, local_label(fig, 'Reference MRI'), 1, 1);
local_put(file_left, local_h('h_dti_ref_mri_file'), 1, 2);
local_put(file_left, local_h('h_dti_browse_ref_button'), 1, 3);
local_put(file_left, local_h('h_dti_ref_status'), 2, [2 3]);
local_put(file_left, local_label(fig, 'FA File'), 3, 1);
local_put(file_left, local_h('h_freesurfer_fa_file'), 3, 2);
local_put(file_left, local_h('h_freesurfer_browse_fa_button'), 3, 3);
local_put(file_left, local_label(fig, 'v1 File'), 4, 1);
local_put(file_left, local_h('h_freesurfer_v1_file'), 4, 2);
local_put(file_left, local_h('h_freesurfer_browse_v1_button'), 4, 3);
local_put(file_left, local_label(fig, 'register.dat'), 5, 1);
local_put(file_left, local_h('h_freesurfer_register_file'), 5, 2);
local_put(file_left, local_h('h_freesurfer_browse_register_button'), 5, 3);

file_right = local_grid(file_outer, [2 1], theme);
file_right.RowHeight = {'1x', '1x'};
file_right.RowSpacing = 8;
file_right.Padding = [0 0 0 0];
local_put(file_right, local_h('h_dti_load_button'), 1, 1);
local_put(file_right, local_h('h_dti_clear_button'), 2, 1);

model_p = local_panel(root, theme, 'Conversion Model');
model_g = local_grid(model_p, [4 1], theme);
model_g.RowHeight = {28, 28, 28, 32};
model_g.RowSpacing = 8;
model_g.Padding = [8 8 8 8];

model_top = local_grid(model_g, [1 2], theme);
model_top.ColumnWidth = {'fit', '1x'};
model_top.Padding = [0 0 0 0];
local_put(model_top, local_label(fig, 'Model:'), 1, 1);
local_put(model_top, local_h('h_dti_model_dropdown'), 1, 2);

p1 = local_grid(model_g, [1 6], theme);
p1.ColumnWidth = {'fit', '1x', 'fit', '1x', 'fit', '1x'};
p1.ColumnSpacing = 8;
p1.Padding = [0 0 0 0];
local_put(p1, local_label(fig, 'Volume Fraction'), 1, 1);
local_put(p1, local_h('h_dti_volume_fraction'), 1, 2);
local_put(p1, local_label(fig, 'Extra (S/m)'), 1, 3);
local_put(p1, local_h('h_dti_extra_conductivity'), 1, 4);
local_put(p1, local_label(fig, 'Intra (S/m)'), 1, 5);
local_put(p1, local_h('h_dti_intra_conductivity'), 1, 6);

p2 = local_grid(model_g, [1 6], theme);
p2.ColumnWidth = {'fit', 90, 'fit', 90, 'fit', 90};
p2.ColumnSpacing = 10;
p2.Padding = [0 0 0 0];
local_put(p2, local_label(fig, 'Scale Factor'), 1, 1);
local_put(p2, local_h('h_dti_conductivity_scale'), 1, 2);
local_put(p2, local_label(fig, 'Anisotropy Threshold'), 1, 3);
local_put(p2, local_h('h_dti_anisotropy_threshold'), 1, 4);
local_put(p2, local_label(fig, 'Mean diffusivity'), 1, 5);
local_put(p2, local_h('h_dti_mean_diffusivity'), 1, 6);

help_scale = local_label(fig, 'Direct scaling');
help_ani = local_label(fig, 'Minimum FA');
local_hide(help_scale);
local_hide(help_ani);

local_put(model_g, local_h('h_dti_update_conversion_model_button'), 4, 1);

interp_p = local_panel(root, theme, 'Interpolation');
interp_g = local_grid(interp_p, [3 1], theme);
interp_g.RowHeight = {28, 'fit', 32};
interp_g.RowSpacing = 6;
interp_g.Padding = [8 8 8 8];
ir = local_grid(interp_g, [1 4], theme);
ir.ColumnWidth = {'fit', '1x', 'fit', 110};
ir.Padding = [0 0 0 0];
ir.ColumnSpacing = 8;
local_put(ir, local_label(fig, 'Mode:'), 1, 1);
local_put(ir, local_h('h_dti_interp_mode'), 1, 2);
local_put(ir, local_label(fig, 'Radius (mm)'), 1, 3);
local_put(ir, local_h('h_dti_interp_radius'), 1, 4);
help_i = local_label(fig, 'Radius Average');
if ~isempty(help_i)
    local_put(interp_g, help_i, 2, 1);
    try
        help_i.WordWrap = 'on';
    catch
    end
end
local_put(interp_g, local_h('h_dti_update_interpolation_model_button'), 3, 1);

comp_p = local_panel(root, theme, 'Compartment Selection');
comp_g = local_grid(comp_p, [2 3], theme);
comp_g.ColumnWidth = {168, '1x', 140};
comp_g.RowHeight = {22, '1x'};
comp_g.Padding = [8 8 8 8];
comp_g.ColumnSpacing = 8;
local_put(comp_g, local_label(fig, 'Apply to compartments'), 1, 1);
help_c = local_label(fig, 'Hold Ctrl/Cmd');
if ~isempty(help_c)
    local_put(comp_g, help_c, 2, 1);
    try
        help_c.WordWrap = 'on';
        help_c.VerticalAlignment = 'top';
    catch
    end
end
local_put(comp_g, local_h('h_dti_compartments'), [1 2], 2);
local_put(comp_g, local_h('h_dti_apply_button'), [1 2], 3);

info_p = local_panel(root, theme, 'Information');
info_g = local_grid(info_p, [1 1], theme);
info_g.Padding = [8 8 8 8];
local_put(info_g, local_h('h_dti_info_text'), 1, 1);

local_hide(local_h('h_dti_status_text'));
local_hide(local_label(fig, 'Status:'));

zef_ui_hide_orphans(fig);
scr = get(groot, 'ScreenSize');
def_h = min(860, max(640, round(0.82 * scr(4))));
zef_ui_apply_size(fig, 760, def_h, 640, 560);
try
    fig.AutoResizeChildren = 'off';
catch
end

end

function p = local_panel(parent, theme, title)

p = uipanel(parent, 'Title', title);
try
    p.BackgroundColor = theme.color.panel;
    p.ForegroundColor = theme.color.text;
    p.FontName = theme.font.name;
    p.FontSize = theme.font.sizeSmall;
    p.BorderType = 'line';
    p.BorderColor = theme.color.border;
catch
end

end

function g = local_grid(parent, sz, theme)

g = uigridlayout(parent, sz);
try
    g.BackgroundColor = theme.color.panel;
catch
end

end

function local_put(parent, h, row, col)

if isempty(h) || ~isgraphics(h(1)) || ~isvalid(h(1))
    return
end
h = h(1);
try
    h.Parent = parent;
    h.Layout.Row = row;
    h.Layout.Column = col;
catch
    try
        h.Layout = matlab.ui.layout.GridLayoutOptions('Row', row, 'Column', col);
    catch
    end
end
try
    if strcmpi(char(h.Type), 'uilabel')
        h.HorizontalAlignment = 'left';
    end
catch
end

end

function h = local_h(name)

h = gobjects(0);
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, name) && isgraphics(zef.(name))
        h = zef.(name);
    end
catch
end

end

function h = local_label(fig, txt)

h = gobjects(0);
labs = findall(fig, 'Type', 'uilabel');
needle = lower(strtrim(regexprep(txt, ':$', '')));
for i = 1:numel(labs)
    try
        t = lower(strtrim(regexprep(char(string(labs(i).Text)), ':$', '')));
        if strcmp(t, needle) || strncmp(t, [needle ' '], numel(needle) + 1) ...
                || strncmp(t, [needle '('], numel(needle) + 1)
            h = labs(i);
            return
        end
    catch
    end
end

end

function local_hide(h)

if isempty(h) || ~isgraphics(h(1)) || ~isvalid(h(1))
    return
end
try
    h(1).Visible = 'off';
catch
end

end
