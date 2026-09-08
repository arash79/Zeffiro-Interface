function zef_layout_nse_tool(fig)
%ZEF_LAYOUT_NSE_TOOL  Grouped three-column layout for the NSE tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The NSE app is a dense parameter workspace. Parameters are grouped
%   by workflow (time, waveform, viscosity, physiology, flow, vessels,
%   solver, ROI, source). Domain lists, method dropdowns, and actions sit
%   in a dedicated sidebar so the primary work stays readable.
%
%   See also zef_ui_ready, zef_nse_tool_window.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if isappdata(fig, 'ZefNseLayoutV') && isequal(getappdata(fig, 'ZefNseLayoutV'), 4)
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

try
    local_unwrap_old(fig);
catch
end

lists = local_visible(findall(fig, 'Type', 'uilistbox'));
list_labs = local_list_labels(fig, lists);
pairs = local_pair_fields(fig, list_labs);
[side_dd, pairs] = local_take_methods(pairs);
side_dd = local_label_methods(side_dd, fig);
checks = local_visible(findall(fig, 'Type', 'uicheckbox'));
btns = local_visible(findall(fig, 'Type', 'uibutton'));

groups = local_bucket(pairs);
if ~isempty(checks)
    pcg_lab = gobjects(0);
    all_labs = local_visible(findall(fig, 'Type', 'uilabel'));
    for j = 1:numel(all_labs)
        t = lower(local_txt(all_labs(j)));
        if contains(t, 'pcg') && contains(t, 'solver')
            pcg_lab = all_labs(j);
            break
        end
    end
    groups.solver{end+1} = {pcg_lab, checks(1)}; %#ok<AGROW>
    try
        checks(1).Text = 'Use GPU';
    catch
    end
    if ~isempty(groups.other)
        keep = true(1, numel(groups.other));
        for i = 1:numel(groups.other)
            if ~isempty(pcg_lab) && isequal(groups.other{i}{1}, pcg_lab)
                keep(i) = false;
            end
        end
        groups.other = groups.other(keep);
    end
end

root = uigridlayout(fig, [1 1]);
root.Tag = 'zef_ui_root';
root.Padding = [10 10 10 10];
root.RowHeight = {'1x'};
root.ColumnWidth = {'1x'};
try
    root.BackgroundColor = theme.color.bg;
    root.Scrollable = 'on';
catch
end

body = uigridlayout(root, [1 3]);
body.Tag = 'zef_nse_body';
body.ColumnWidth = {'1x', '1x', 320};
body.ColumnSpacing = 12;
body.Padding = [0 0 0 0];
try
    body.BackgroundColor = theme.color.bg;
catch
end

col1 = local_stack_col(body, 1, theme);
col2 = local_stack_col(body, 2, theme);
side = local_stack_col(body, 3, theme);
side.Tag = 'zef_nse_side';

local_section(col1, 'Time', groups.time, theme);
local_section(col1, 'Pulse and waves', groups.wave, theme);
local_section(col1, 'Viscosity', groups.visc, theme);
local_section(col1, 'Physiology', groups.physio, theme);
local_section(col2, 'Flow and gravity', groups.flow, theme);
local_section(col2, 'Vessels', groups.vessel, theme);
local_section(col2, 'Solver', groups.solver, theme);
local_section(col2, 'ROI', groups.roi, theme);
local_section(col2, 'Source', groups.source, theme);
if ~isempty(groups.other)
    local_section(col2, 'Other', groups.other, theme);
end

local_lists(side, lists, list_labs, theme);
local_section(side, 'Method', side_dd, theme);
local_actions(side, btns, theme);

setappdata(fig, 'ZefNseLayoutV', 4);
work = zef_ui_screen_workarea(fig);
def_w = min(1180, max(960, work(3)));
def_h = min(860, max(640, work(4) - 40));
zef_ui_apply_size(fig, def_w, def_h, 920, 580);
try
    drawnow;
    zef_ui_adapt_grid(fig);
catch
end

end

function local_unwrap_old(fig)

roots = findall(fig, 'Tag', 'zef_ui_root');
if isempty(roots)
    return
end
ctrls = [findall(fig, 'Type', 'uilabel'); findall(fig, 'Type', 'uieditfield'); ...
    findall(fig, 'Type', 'uinumericeditfield'); findall(fig, 'Type', 'uidropdown'); ...
    findall(fig, 'Type', 'uispinner'); findall(fig, 'Type', 'uibutton'); ...
    findall(fig, 'Type', 'uicheckbox'); findall(fig, 'Type', 'uilistbox')];
keep = gobjects(0, 1);
for i = 1:numel(ctrls)
    try
        tg = '';
        if isprop(ctrls(i), 'Tag')
            tg = char(ctrls(i).Tag);
        end
        if strcmp(tg, 'zef_nse_hdr')
            continue
        end
        keep(end+1, 1) = ctrls(i); %#ok<AGROW>
    catch
    end
end
for i = 1:numel(keep)
    try
        keep(i).Parent = fig;
    catch
    end
end
try
    delete(roots);
catch
end

end

function g = local_stack_col(body, col, theme)

g = uigridlayout(body, [12 1]);
try
    g.Layout.Column = col;
catch
end
g.ColumnWidth = {'1x'};
g.RowHeight = repmat({'fit'}, 1, 12);
g.RowSpacing = 8;
g.Padding = [0 0 0 0];
try
    g.BackgroundColor = theme.color.bg;
catch
end
setappdata(g, 'ZefRows', 0);

end

function pairs = local_pair_fields(fig, skip_labs)

if nargin < 2
    skip_labs = {};
end
skip = gobjects(0, 1);
if iscell(skip_labs)
    for i = 1:numel(skip_labs)
        if ~isempty(skip_labs{i}) && isgraphics(skip_labs{i})
            skip(end+1, 1) = skip_labs{i}; %#ok<AGROW>
        end
    end
end
labels = local_visible(findall(fig, 'Type', 'uilabel'));
fields = local_visible([findall(fig, 'Type', 'uieditfield'); ...
    findall(fig, 'Type', 'uinumericeditfield'); ...
    findall(fig, 'Type', 'uidropdown'); ...
    findall(fig, 'Type', 'uispinner')]);
used = false(numel(labels), 1);
for j = 1:numel(labels)
    for s = 1:numel(skip)
        if isequal(labels(j), skip(s))
            used(j) = true;
            break
        end
    end
    t = lower(local_txt(labels(j)));
    if contains(t, 'domain')
        used(j) = true;
    end
end
pairs = {};
for i = 1:numel(fields)
    fp = local_gp(fields(i));
    best = 0;
    best_d = inf;
    for j = 1:numel(labels)
        if used(j)
            continue
        end
        lp = local_gp(labels(j));
        if lp(1) + lp(3) > fp(1) + 12
            continue
        end
        if abs((lp(2) + lp(4) / 2) - (fp(2) + fp(4) / 2)) > 18
            continue
        end
        d = fp(1) - (lp(1) + lp(3));
        if d >= -8 && d < best_d
            best_d = d;
            best = j;
        end
    end
    lab = gobjects(0);
    if best > 0
        used(best) = true;
        lab = labels(best);
    end
    pairs{end+1} = {lab, fields(i)}; %#ok<AGROW>
end
for j = 1:numel(labels)
    if used(j)
        continue
    end
    txt = local_txt(labels(j));
    if numel(txt) < 3 || contains(lower(txt), 'domain')
        continue
    end
    lt = lower(txt);
    if contains(lt, 'reconstruction') || strcmp(lt, 'method') ...
            || contains(lt, 'graph type') || contains(lt, 'time integration') ...
            || contains(lt, 'pcg solver')
        continue
    end
    pairs{end+1} = {labels(j), gobjects(0)}; %#ok<AGROW>
end

end

function [method_pairs, rest] = local_take_methods(pairs)

method_pairs = {};
rest = {};
for i = 1:numel(pairs)
    if local_is_method_pair(pairs{i})
        method_pairs{end+1} = pairs{i}; %#ok<AGROW>
    else
        rest{end+1} = pairs{i}; %#ok<AGROW>
    end
end

end

function tf = local_is_method_pair(pair)

tf = false;
t = lower(local_txt(pair{1}));
items = '';
try
    if ~isempty(pair{2}) && isgraphics(pair{2}) && isprop(pair{2}, 'Items')
        items = lower(strjoin(string(pair{2}.Items), ' '));
    end
catch
end
if contains(t, 'graph type') || contains(t, 'time integration') ...
        || contains(t, 'solver') || strcmp(strtrim(t), 'method') ...
        || contains(t, 'conductivity statistic')
    tf = true;
    return
end
if contains(items, 'poisson') || contains(items, 'trapezoid') ...
        || contains(items, 'archie') || contains(items, 'hashin') ...
        || contains(items, 'pressure (full)') || contains(items, 'pressure (arteries)')
    tf = true;
    return
end
if (contains(t, 'viscosity') && contains(items, 'constant')) ...
        || (contains(t, 'reconstruction') && ~contains(t, 'quantile') ...
        && (contains(items, 'arteries') || contains(items, 'microcirculation')))
    tf = true;
end

end

function g = local_bucket(pairs)

g = struct('time', {{}}, 'wave', {{}}, 'visc', {{}}, 'physio', {{}}, ...
    'flow', {{}}, 'vessel', {{}}, 'solver', {{}}, 'roi', {{}}, ...
    'source', {{}}, 'other', {{}});
for i = 1:numel(pairs)
    t = lower(local_txt(pairs{i}{1}));
    key = 'other';
    if contains(t, 'time length') || contains(t, 'start time') ...
            || contains(t, 'time step')
        key = 'time';
    elseif contains(t, 'pulse') || contains(t, 'cycle') ...
            || contains(t, 'p-wave') || contains(t, 't-wave') ...
            || contains(t, 'd-wave')
        key = 'wave';
    elseif contains(t, 'viscosity') || contains(t, 'power law') ...
            || contains(t, 'carreau') || contains(t, 'archie') ...
            || contains(t, 'blood conductivity') || contains(t, 'conductivity exponent')
        key = 'visc';
    elseif contains(t, 'oxygen') || contains(t, 'nvc') || contains(t, 'neural drive') ...
            || contains(t, 'blood oxygen')
        key = 'physio';
    elseif contains(t, 'gravit') || contains(t, 'total flow') ...
            || contains(t, 'pressure') || contains(t, 'mass density') ...
            || contains(t, 'density') || strcmp(t, 'dir_v') || contains(t, 'direction')
        key = 'flow';
    elseif contains(t, 'arteriole') || contains(t, 'venule') ...
            || contains(t, 'capillary') || contains(t, 'artery diameter') ...
            || contains(t, 'area ratio')
        key = 'vessel';
    elseif contains(t, 'pcg') || contains(t, 'poisson') || contains(t, 'frames') ...
            || contains(t, 'quantile') || contains(t, 'velocity smoothing') ...
            || contains(t, 'gpu')
        key = 'solver';
    elseif contains(t, 'roi')
        key = 'roi';
    elseif contains(t, 'source sphere') || contains(t, 'source')
        key = 'source';
    end
    g.(key){end+1} = pairs{i}; %#ok<AGROW>
end

end

function local_section(col, title, pairs, theme)

if isempty(pairs)
    return
end
n = numel(pairs);
host = uigridlayout(col, [n + 1 2]);
try
    host.Layout.Row = local_next_row(col);
catch
end
host.ColumnWidth = {168, '1x'};
rh = [{20}, repmat({26}, 1, n)];
for i = 1:n
    if local_is_checkbox(pairs{i}{2})
        rh{i + 1} = 26;
    end
end
host.RowHeight = rh;
host.RowSpacing = 4;
host.ColumnSpacing = 8;
host.Padding = [8 8 8 8];
try
    host.BackgroundColor = theme.color.panel;
catch
end
hdr = uilabel(host, 'Text', title);
try
    hdr.Tag = 'zef_nse_hdr';
    hdr.FontWeight = 'bold';
    hdr.HorizontalAlignment = 'left';
    hdr.FontColor = theme.color.header;
    hdr.Layout.Row = 1;
    hdr.Layout.Column = [1 2];
catch
end
for i = 1:n
    lab = pairs{i}{1};
    fld = pairs{i}{2};
    if ~isempty(lab) && isgraphics(lab)
        try
            lab.Parent = host;
            lab.Layout.Row = i + 1;
            lab.Layout.Column = 1;
            lab.HorizontalAlignment = 'right';
            lab.WordWrap = 'on';
            lab.FontWeight = 'normal';
        catch
        end
    end
    if ~isempty(fld) && isgraphics(fld)
        try
            fld.Parent = host;
            fld.Layout.Row = i + 1;
            if isempty(lab) || ~isgraphics(lab)
                fld.Layout.Column = [1 2];
            else
                fld.Layout.Column = 2;
            end
        catch
        end
    end
end

end

function local_lists(side, lists, labs, theme)

if isempty(lists)
    return
end
n = numel(lists);
host = uigridlayout(side, [2 * n 1]);
try
    host.Layout.Row = local_next_row(side);
catch
end
host.RowHeight = repmat({'fit', 140}, 1, n);
host.Padding = [8 8 8 8];
host.RowSpacing = 4;
try
    host.BackgroundColor = theme.color.panel;
catch
end
for i = 1:n
    if i <= numel(labs) && ~isempty(labs{i}) && isgraphics(labs{i})
        try
            labs{i}.Parent = host;
            labs{i}.Layout.Row = 2 * i - 1;
            labs{i}.HorizontalAlignment = 'left';
            labs{i}.FontWeight = 'bold';
            labs{i}.FontColor = theme.color.header;
        catch
        end
    end
    try
        lists(i).Parent = host;
        lists(i).Layout.Row = 2 * i;
    catch
    end
end

end

function local_actions(side, btns, theme)

if isempty(btns)
    return
end
pri = false(numel(btns), 1);
order = zeros(numel(btns), 1);
for i = 1:numel(btns)
    t = lower(local_txt(btns(i)));
    if contains(t, 'solve')
        order(i) = 1;
        pri(i) = true;
    elseif contains(t, 'interpolate')
        order(i) = 2;
        pri(i) = true;
    elseif contains(t, 'plot graph')
        order(i) = 3;
        pri(i) = true;
    elseif contains(t, 'parse')
        order(i) = 4;
    elseif contains(t, 'sigma')
        order(i) = 5;
    elseif contains(t, 'plot sphere')
        order(i) = 6;
    elseif contains(t, 'plot roi')
        order(i) = 7;
    elseif contains(t, 'apply roi')
        order(i) = 8;
    elseif contains(t, 'apply source')
        order(i) = 9;
    else
        order(i) = 20 + i;
    end
    if pri(i)
        try
            setappdata(btns(i), 'ZefPrimary', true);
        catch
        end
    end
end
[~, idx] = sort(order);
btns = btns(idx);
n = numel(btns);
if n <= 2
    n_cols = max(1, n);
else
    n_cols = 3;
end
n_rows = ceil(n / n_cols);
host = uigridlayout(side, [n_rows n_cols]);
try
    host.Layout.Row = local_next_row(side);
catch
end
host.ColumnWidth = repmat({'1x'}, 1, n_cols);
host.RowHeight = repmat({32}, 1, n_rows);
host.RowSpacing = 6;
host.ColumnSpacing = 8;
host.Padding = [8 8 8 8];
try
    host.BackgroundColor = theme.color.panel;
catch
end
for i = 1:n
    try
        btns(i).Parent = host;
        btns(i).Layout.Row = ceil(i / n_cols);
        btns(i).Layout.Column = mod(i - 1, n_cols) + 1;
    catch
    end
end

end

function labs = local_list_labels(fig, lists)

labs = cell(1, numel(lists));
all_labs = local_visible(findall(fig, 'Type', 'uilabel'));
for i = 1:numel(lists)
    lp = local_gp(lists(i));
    best = 0;
    best_d = inf;
    for j = 1:numel(all_labs)
        tp = local_gp(all_labs(j));
        if abs(tp(1) - lp(1)) > 80
            continue
        end
        if tp(2) + tp(4) > lp(2) + 8
            continue
        end
        d = lp(2) - (tp(2) + tp(4));
        if d >= -4 && d < best_d
            best_d = d;
            best = j;
        end
    end
    if best > 0
        labs{i} = all_labs(best);
    end
    if isempty(labs{i})
        needle = 'artery';
        if i >= 2
            needle = 'microcirculation';
        end
        for j = 1:numel(all_labs)
            t = lower(local_txt(all_labs(j)));
            if contains(t, needle) || (i >= 2 && contains(t, 'capillary') && contains(t, 'domain'))
                labs{i} = all_labs(j);
                break
            end
        end
    end
end

end

function side_dd = local_label_methods(side_dd, fig)

labs = local_visible(findall(fig, 'Type', 'uilabel'));
for i = 1:numel(side_dd)
    has_lab = false;
    try
        if ~isempty(side_dd{i}{1}) && isgraphics(side_dd{i}{1}) ...
                && strlength(strtrim(string(local_txt(side_dd{i}{1})))) > 0
            has_lab = true;
        end
    catch
    end
    if has_lab
        continue
    end
    items = '';
    try
        items = lower(strjoin(string(side_dd{i}{2}.Items), ' '));
    catch
    end
    want = '';
    if contains(items, 'poisson')
        want = 'method';
    elseif contains(items, 'pressure (arteries)') || contains(items, 'velocity (arteries)')
        want = 'reconstruction';
    elseif contains(items, 'trapezoid')
        want = 'time integration';
    elseif contains(items, 'archie')
        want = 'conductivity';
    elseif contains(items, 'constant') && contains(items, 'power law')
        want = 'viscosity';
    elseif contains(items, 'pressure (full)')
        want = 'graph type';
    end
    if isempty(want)
        continue
    end
    for j = 1:numel(labs)
        t = lower(local_txt(labs(j)));
    t0 = strtrim(regexprep(t, ':', ''));
    if strcmp(t0, want) || strcmp(t0, [want ' type']) ...
            || strcmp(t0, [want ' model']) || strcmp(t0, [want ' statistic'])
        side_dd{i}{1} = labs(j);
        try
            labs(j).Visible = 'on';
        catch
        end
        break
    end
    end
end

end

function objs = local_visible(objs)

keep = true(numel(objs), 1);
for i = 1:numel(objs)
    try
        keep(i) = strcmpi(char(objs(i).Visible), 'on');
        tg = '';
        if isprop(objs(i), 'Tag')
            tg = char(objs(i).Tag);
        end
        if strcmp(tg, 'zef_nse_hdr') || strcmp(tg, 'zef_ui_root')
            keep(i) = false;
        end
    catch
    end
end
objs = objs(keep);

end

function p = local_gp(h)

p = [0 0 40 22];
try
    p = getpixelposition(h, true);
catch
    try
        p = h.Position;
    catch
    end
end

end

function t = local_txt(h)

t = '';
if isempty(h) || ~(isgraphics(h) && isvalid(h))
    return
end
try
    if isprop(h, 'Text')
        t = strtrim(char(string(h.Text)));
    elseif isprop(h, 'String')
        t = strtrim(char(string(h.String)));
    end
catch
end

end

function n = local_next_row(col)

n = 0;
try
    n = getappdata(col, 'ZefRows');
catch
end
if isempty(n)
    n = 0;
end
n = n + 1;
setappdata(col, 'ZefRows', n);

end

function tf = local_is_checkbox(h)

tf = false;
try
    tf = strcmpi(char(h.Type), 'uicheckbox');
catch
end

end
