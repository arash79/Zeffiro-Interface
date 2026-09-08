function zef_layout_segmentation_tool(fig)
%ZEF_LAYOUT_SEGMENTATION_TOOL  Three-column grid for the Segmentation tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

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
catch
end
fig.AutoResizeChildren = 'off';
try
    fig.Scrollable = 'off';
catch
end

root = uigridlayout(fig, [3 1]);
root.Tag = 'zef_ui_root';
root.RowHeight = {56, '1x', 148};
root.Padding = [12 12 12 12];
root.RowSpacing = 10;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

header = uigridlayout(root, [1 6]);
header.Tag = 'zef_seg_header';
header.ColumnWidth = {'fit', '1x', 188, 'fit', 'fit', 176};
header.Padding = [0 4 0 4];
header.ColumnSpacing = 8;
try
    header.BackgroundColor = theme.color.bg;
catch
end
local_move(fig, header, 'ProjecttagEditFieldLabel');
local_move(fig, header, 'h_project_tag');
local_move(fig, header, 'h_profile_name');
local_move(fig, header, 'h_set_position');
local_move(fig, header, 'h_segmentation_tool_toggle');
logo = local_find(fig, 'h_axes2');
if ~isempty(logo)
    logo.Parent = header;
    try
        logo.Layout.Row = 1;
        logo.Layout.Column = 6;
    catch
    end
    try
        proj_root = fileparts(which('zeffiro_interface'));
        if isempty(proj_root)
            helper_dir = fileparts(mfilename('fullpath'));
            proj_root = fileparts(fileparts(fileparts(helper_dir)));
        end
        src = fullfile(proj_root, 'assets', 'fig', 'zeffiro_logo_compass.png');
        if exist(src, 'file') ~= 2
            src = fullfile(proj_root, 'assets', 'fig', 'zeffiro_small_logo.png');
        end
        if exist(src, 'file') == 2
            logo.ImageSource = src;
        else
            logo.ImageSource = 'zeffiro_logo_compass.png';
        end
        try
            rmappdata(logo, 'ZefLogoOriginal');
        catch
        end
        logo.ScaleMethod = 'fit';
        logo.HorizontalAlignment = 'right';
        logo.VerticalAlignment = 'center';
        logo.BackgroundColor = theme.color.bg;
    catch
    end
end

cols = uigridlayout(root, [2 3]);
cols.Tag = 'zef_seg_cols';
cols.ColumnWidth = {'1.80x', '1.24x', '0.90x'};
cols.RowHeight = {22, '1x'};
cols.ColumnSpacing = 10;
cols.RowSpacing = 4;
cols.Padding = [0 0 0 0];
try
    cols.BackgroundColor = theme.color.bg;
catch
end
local_move(fig, cols, 'CompartmentsLabel');
local_move(fig, cols, 'SensorsetsLabel');
local_move(fig, cols, 'SensorsLabel_2');
h_comp = local_find(fig, 'h_compartment_table');
if ~isempty(h_comp)
    h_comp.Parent = cols;
    h_comp.Layout.Row = 2;
    h_comp.Layout.Column = 1;
    zef_ui_fit_table(h_comp);
end

mid = uigridlayout(cols, [3 2]);
mid.Tag = 'zef_seg_mid';
mid.Layout.Row = 2;
mid.Layout.Column = 2;
mid.RowHeight = {'1x', 22, '1x'};
mid.ColumnWidth = {'0.88x', '1.22x'};
mid.Padding = [0 0 0 0];
mid.RowSpacing = 4;
mid.ColumnSpacing = 10;
try
    mid.BackgroundColor = theme.color.bg;
catch
end
h_sens = local_find(fig, 'h_sensors_table');
if ~isempty(h_sens)
    h_sens.Parent = mid;
    h_sens.Layout.Row = 1;
    h_sens.Layout.Column = [1 2];
    zef_ui_fit_table(h_sens);
end
lab_t = local_find(fig, 'TransformLabel');
if ~isempty(lab_t)
    lab_t.Parent = mid;
    lab_t.Layout.Row = 2;
    lab_t.Layout.Column = 1;
end
lab_p = local_find(fig, 'ParametersLabel');
if ~isempty(lab_p)
    lab_p.Parent = mid;
    lab_p.Layout.Row = 2;
    lab_p.Layout.Column = 2;
end
h_tr = local_find(fig, 'h_transform_table');
if ~isempty(h_tr)
    h_tr.Parent = mid;
    h_tr.Layout.Row = 3;
    h_tr.Layout.Column = 1;
    zef_ui_fit_table(h_tr);
end
h_par = local_find(fig, 'h_parameters_table');
if ~isempty(h_par)
    h_par.Parent = mid;
    h_par.Layout.Row = 3;
    h_par.Layout.Column = 2;
    zef_ui_fit_table(h_par);
end

h_names = local_find(fig, 'h_sensors_name_table');
if ~isempty(h_names)
    h_names.Parent = cols;
    h_names.Layout.Row = 2;
    h_names.Layout.Column = 3;
    zef_ui_fit_table(h_names);
end

foot = uigridlayout(root, [2 3]);
foot.Tag = 'zef_seg_foot';
foot.ColumnWidth = cols.ColumnWidth;
foot.RowHeight = {22, '1x'};
foot.ColumnSpacing = 10;
foot.RowSpacing = 4;
foot.Padding = [0 0 0 0];
try
    foot.BackgroundColor = theme.color.bg;
catch
end
lab_i = local_find(fig, 'ProjectinformationLabel');
if ~isempty(lab_i)
    lab_i.Parent = foot;
    lab_i.Layout.Row = 1;
    lab_i.Layout.Column = 1;
end
lab_n = local_find(fig, 'ProjectnotesTextAreaLabel');
if ~isempty(lab_n)
    lab_n.Parent = foot;
    lab_n.Layout.Row = 1;
    lab_n.Layout.Column = [2 3];
end
h_info = local_find(fig, 'h_project_information');
if ~isempty(h_info)
    h_info.Parent = foot;
    h_info.Layout.Row = 2;
    h_info.Layout.Column = 1;
end
h_notes = local_find(fig, 'h_project_notes');
if ~isempty(h_notes)
    h_notes.Parent = foot;
    h_notes.Layout.Row = 2;
    h_notes.Layout.Column = [2 3];
end

h_prof = local_find(fig, 'h_profile_name');
if ~isempty(h_prof) && isvalid(h_prof)
    try
        h_prof.Tooltip = 'Profile';
    catch
    end
end
lab_prof = local_find(fig, 'ProfileDropDownLabel');
if ~isempty(lab_prof) && isvalid(lab_prof)
    try
        lab_prof.Visible = 'off';
    catch
    end
end
h_toggle = local_find(fig, 'h_segmentation_tool_toggle');
if ~isempty(h_toggle)
    try
        h_toggle.Text = 'Toggle layout';
    catch
    end
end
h_pos = local_find(fig, 'h_set_position');
if ~isempty(h_pos)
    try
        h_pos.Text = 'Set position';
    catch
    end
end
h_info = local_find(fig, 'h_project_information');
if ~isempty(h_info)
    try
        h_info.FontName = theme.font.name;
        h_info.FontSize = theme.font.sizeSmall;
    catch
    end
end

fig.SizeChangedFcn = '';
try
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_hide_orphans(fig);
labs = findall(fig, 'Type', 'uilabel');
for i = 1:numel(labs)
    try
        txt = strtrim(char(string(labs(i).Text)));
        if endsWith(txt, ':')
            labs(i).FontColor = theme.color.header;
            labs(i).FontWeight = 'bold';
        end
    catch
    end
end
zef_ui_bind_min_size(fig, 1020, 500);
zef_ui_adapt_grid(fig);

end

function h = local_find(fig, name)

h = findall(fig, 'Tag', name);
if isempty(h)
    h = gobjects(0);
    return
end
h = h(1);

end

function local_move(fig, parent, name)

h = local_find(fig, name);
if ~isempty(h) && isvalid(h)
    try
        h.Parent = parent;
        if strcmpi(char(h.Type), 'uitable')
            zef_ui_fit_table(h);
        end
    catch
    end
end

end
