function zef_layout_fss(fig)
%ZEF_LAYOUT_FSS  Grid layout for Find synthetic source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Source list and parameter table share leftover height. Action
%   buttons stay in a compact footer so enlarging the window does not
%   leave a frozen pixel layout.
%
%   See also find_synthetic_source, zef_ui_ready.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if ~isempty(findall(fig, 'Tag', 'zef_ui_root'))
    zef_ui_adapt_grid(fig);
    return
end

src = local_h(fig, 'h_source_list');
par = local_h(fig, 'h_source_parameters');
if isempty(src) || isempty(par)
    tbls = findall(fig, 'Type', 'uitable');
    if numel(tbls) >= 2
        xs = inf(numel(tbls), 1);
        for i = 1:numel(tbls)
            try
                gp = getpixelposition(tbls(i), true);
                xs(i) = gp(1);
            catch
            end
        end
        [~, xo] = sort(xs);
        if isempty(src)
            src = tbls(xo(1));
        end
        if isempty(par)
            par = tbls(xo(end));
        end
    elseif numel(tbls) == 1 && isempty(src)
        src = tbls(1);
    end
end
if isempty(src) && isempty(local_h(fig, 'h_add_source'))
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

root = uigridlayout(fig, [6 1]);
root.Tag = 'zef_ui_root';
root.RowHeight = {36, '1x', 32, 28, 36, 36};
root.Padding = [12 12 12 12];
root.RowSpacing = 8;
try
    root.Scrollable = 'off';
    root.BackgroundColor = theme.color.bg;
catch
end

top = uigridlayout(root, [1 2]);
top.ColumnWidth = {'1x', '1x'};
top.Padding = [0 0 0 0];
top.ColumnSpacing = 8;
try
    top.BackgroundColor = theme.color.bg;
catch
end
local_put(top, local_h(fig, 'h_add_source'), 1, 1);
local_put(top, local_h(fig, 'h_remove_source'), 1, 2);

mid = uigridlayout(root, [1 2]);
mid.Tag = 'zef_fss_tables';
mid.ColumnWidth = {160, '1x'};
mid.Padding = [0 0 0 0];
mid.ColumnSpacing = 8;
try
    mid.BackgroundColor = theme.color.bg;
catch
end
local_put(mid, src, 1, 1);
local_put(mid, par, 1, 2);
try
    zef_ui_fit_table([src, par]);
catch
end

opts = uigridlayout(root, [1 4]);
opts.ColumnWidth = {'fit', 88, 'fit', 88};
opts.Padding = [0 0 0 0];
opts.ColumnSpacing = 8;
try
    opts.BackgroundColor = theme.color.bg;
catch
end
lab_n = local_label(fig, 'Background Noise');
if isempty(lab_n)
    lab_n = local_label(fig, 'Background');
end
local_put(opts, lab_n, 1, 1);
local_put(opts, local_h(fig, 'h_bg_noise'), 1, 2);
lab_t = local_label(fig, 'Single time');
if isempty(lab_t)
    lab_t = local_label(fig, 'time point');
end
local_put(opts, lab_t, 1, 3);
local_put(opts, local_h(fig, 'h_time_val'), 1, 4);

sw = local_h(fig, 'h_plot_switch');
if ~isempty(sw)
    local_put(root, sw, 4, 1);
end

row_a = uigridlayout(root, [1 3]);
row_a.ColumnWidth = {'1x', '1x', '1x'};
row_a.Padding = [0 0 0 0];
row_a.ColumnSpacing = 8;
try
    row_a.BackgroundColor = theme.color.bg;
catch
end
local_put(row_a, local_h(fig, 'h_plot_sources'), 1, 1);
local_put(row_a, local_h(fig, 'h_generate_time_sequence'), 1, 2);
local_put(row_a, local_h(fig, 'h_plot_time_sequence'), 1, 3);

row_b = uigridlayout(root, [1 2]);
row_b.ColumnWidth = {'1x', '1x'};
row_b.Padding = [0 0 0 0];
row_b.ColumnSpacing = 8;
try
    row_b.BackgroundColor = theme.color.bg;
catch
end
local_put(row_b, local_h(fig, 'h_plot_intensity'), 1, 1);
local_put(row_b, local_h(fig, 'h_create_synth_data'), 1, 2);

zef_ui_hide_orphans(fig);
try
    fig.SizeChangedFcn = '';
    if isappdata(fig, 'ZefMinSizeFcn')
        rmappdata(fig, 'ZefMinSizeFcn');
    end
catch
end
zef_ui_apply_size(fig, 640, 560, 520, 440);
zef_ui_bind_min_size(fig, 520, 440);
zef_ui_adapt_grid(fig);
try
    zef_ui_fit_table(findall(fig, 'Type', 'uitable'));
catch
end

end

function local_put(parent, h, row, col)

if isempty(h) || ~(isgraphics(h(1)) && isvalid(h(1)))
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

end

function h = local_h(fig, name)

h = gobjects(0);
found = findall(fig, 'Tag', name);
if ~isempty(found)
    h = found(1);
    return
end
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, 'find_synth_source') ...
            && isprop(zef.find_synth_source, name)
        h = zef.find_synth_source.(name);
        try
            h.Tag = name;
        catch
        end
        if ~isempty(h) && isgraphics(h) && isvalid(h)
            return
        end
    end
    if isstruct(zef) && isfield(zef, name) && isgraphics(zef.(name))
        h = zef.(name);
        if ~isempty(h) && isgraphics(h) && isvalid(h)
            return
        end
    end
catch
end
needles = { ...
    'h_add_source', 'Add new synthetic'; ...
    'h_remove_source', 'Remove synthetic'; ...
    'h_generate_time_sequence', 'Generate time'; ...
    'h_create_synth_data', 'Create synthetic'; ...
    'h_plot_sources', 'Plot source'; ...
    'h_plot_intensity', 'Plot intensities'; ...
    'h_plot_time_sequence', 'Plot time sequence'};
for i = 1:size(needles, 1)
    if ~strcmp(name, needles{i, 1})
        continue
    end
    btns = [findall(fig, 'Type', 'uibutton'); findall(fig, 'Style', 'pushbutton')];
    needle = lower(needles{i, 2});
    for k = 1:numel(btns)
        txt = '';
        try
            if isprop(btns(k), 'Text')
                txt = lower(strtrim(char(string(btns(k).Text))));
            elseif isprop(btns(k), 'String')
                txt = lower(strtrim(char(string(btns(k).String))));
            end
        catch
        end
        if contains(txt, needle)
            h = btns(k);
            try
                h.Tag = name;
            catch
            end
            return
        end
    end
end

end

function h = local_label(fig, txt)

h = gobjects(0);
labs = findall(fig, 'Type', 'uilabel');
needle = lower(strtrim(txt));
for i = 1:numel(labs)
    try
        t = lower(strtrim(char(string(labs(i).Text))));
        if contains(t, needle)
            h = labs(i);
            return
        end
    catch
    end
end

end
