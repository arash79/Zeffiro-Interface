function zef_ui_fit_table(tbl)
%ZEF_UI_FIT_TABLE  Size table columns so headers and values stay readable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Flag / id columns stay compact (pixel widths). Text columns use
%   weighted 'Nx' so MATLAB stretches them to the live table inner
%   width. That fills the parent cell without a leftover gutter and
%   without a horizontal scrollbar from over-assigned pixels.
%
%   See also zef_layout_table_dialog, zef_ui_apply_theme.

if nargin < 1 || isempty(tbl)
    return
end
if numel(tbl) > 1
    for i = 1:numel(tbl)
        zef_ui_fit_table(tbl(i));
    end
    return
end
if ~isgraphics(tbl) || ~isvalid(tbl)
    return
end

n = 0;
names = {};
try
    names = tbl.ColumnName;
    if isstring(names)
        names = cellstr(names);
    end
    if ischar(names)
        names = {names};
    end
    n = numel(names);
catch
end
if n < 1
    try
        d = tbl.Data;
        if iscell(d) || isnumeric(d)
            n = size(d, 2);
        end
    catch
    end
end
if n < 1
    return
end

try
    tbl.RowName = {};
catch
end

names = local_short_headers(tbl, names);
n = numel(names);

theme = [];
try
    theme = zef_ui_theme();
catch
end
fs = 12;
if ~isempty(theme)
    fs = theme.font.size;
end
try
    tbl.FontSize = fs;
    tbl.FontName = theme.font.name;
catch
end
try
    tbl.RowStriping = 'on';
    if ~isempty(theme) && isfield(theme, 'color') ...
            && isfield(theme.color, 'tableRow')
        n_data = 0;
        try
            n_data = size(tbl.Data, 1);
        catch
        end
        if n_data < 2
            tbl.BackgroundColor = theme.color.tableRow;
        else
            tbl.BackgroundColor = [theme.color.tableRow; theme.color.tableAlt];
        end
        local_set_tbl(tbl, 'FontColor', theme.color.text);
        local_set_tbl(tbl, 'ForegroundColor', theme.color.text);
    end
catch
end

compact = zeros(1, n);
weight = zeros(1, n);
for i = 1:n
    nm = '';
    if i <= numel(names)
        try
            nm = lower(strtrim(char(string(names{i}))));
        catch
        end
    end
    c = local_compact_width(nm);
    if c > 0
        compact(i) = c;
    else
        weight(i) = local_flex_weight(nm);
    end
end
if ~any(weight)
    weight(n) = 1;
    compact(n) = 0;
end

n_flex = nnz(weight);
compact_sum = sum(compact);

avail = local_table_width(tbl);
inner = avail;
    chrome = 8;
try
    orig = tbl.Units;
    tbl.Units = 'pixels';
    vis_h = tbl.Position(4);
    tbl.Units = orig;
    n_rows = size(tbl.Data, 1);
    if vis_h > 40 && n_rows * 24 + 28 > vis_h
        chrome = 24;
    end
catch
end
if inner > 80
    inner = max(80, inner - chrome);
end
min_flex = 48 * max(n_flex, 1);
if inner > 80 && compact_sum + min_flex > inner
    room = max(n_flex * 32, inner - min_flex);
    scale = min(1, max(0.45, room / max(compact_sum, 1)));
    for i = 1:n
        if compact(i) > 0
            compact(i) = max(26, round(compact(i) * scale));
        end
    end
end

widths = cell(1, n);
for i = 1:n
    if compact(i) > 0
        widths{i} = compact(i);
    else
        widths{i} = local_flex_spec(weight(i));
    end
end

try
    tbl.ColumnWidth = widths;
catch
    try
        tbl.ColumnWidth = repmat({'1x'}, 1, n);
    catch
    end
end

end

function names = local_short_headers(tbl, names)

if isempty(names)
    return
end
map = { ...
    'index', 'ID'; ...
    'visible', 'Vis'; ...
    'invert normal', 'Inv'; ...
    'surface nodes', 'Nodes'; ...
    'surface triangles', 'Faces'; ...
    'conductivity', 'Cond.'; ...
    'electrical conductivity', 'Cond.'; ...
    'parameter', 'Param'; ...
    'modality', 'Mod.'; ...
    'directions', 'Dir'; ...
    'points', 'Pts'; ...
    'merge', 'Mrg'; ...
    'activity', 'Act.'; ...
    'plugin name', 'Plugin'; ...
    'variable name', 'Variable'; ...
    'default value', 'Default'; ...
    'reference', 'Ref.'; ...
    'units', 'Unit'; ...
    'number of sources', 'Sources'; ...
    'num sources', 'Sources'; ...
    'numb sources', 'Sources'; ...
    'number of sensors', 'Sensors'; ...
    'num sensors', 'Sensors'; ...
    'num se', 'Sensors'};
changed = false;
for i = 1:numel(names)
    raw = strtrim(char(string(names{i})));
    key = lower(raw);
    for k = 1:size(map, 1)
        if strcmp(key, map{k, 1})
            names{i} = map{k, 2};
            changed = true;
            break
        end
    end
    if contains(key, 'conductivity') && ~strcmp(names{i}, 'Cond.')
        names{i} = 'Cond.';
        changed = true;
    elseif (contains(key, 'source') && (contains(key, 'num') || contains(key, 'number'))) ...
            && ~strcmp(names{i}, 'Sources')
        names{i} = 'Sources';
        changed = true;
    elseif (contains(key, 'sensor') && (contains(key, 'num') || contains(key, 'number'))) ...
            && ~strcmp(names{i}, 'Sensors')
        names{i} = 'Sensors';
        changed = true;
    end
end
if changed
    try
        tbl.ColumnName = names;
    catch
    end
end

end

function avail = local_table_width(tbl)

cell_w = local_grid_cell_width(tbl);
if cell_w > 80
    avail = cell_w;
    return
end
avail = local_pos_width(tbl);
if avail < 80
    avail = 0;
end

end

function w = local_pos_width(obj)

w = 0;
try
    orig = obj.Units;
    obj.Units = 'pixels';
    w = obj.Position(3);
    obj.Units = orig;
catch
end

end

function w = local_grid_cell_width(tbl)

w = 0;
try
    fig = ancestor(tbl, 'figure');
    if isempty(fig) || ~isvalid(fig)
        return
    end
    w = local_pos_width(fig);
    if w < 80
        w = 0;
        return
    end
    chain = {};
    q = tbl.Parent;
    while ~isempty(q) && isvalid(q) && q ~= fig
        chain{end+1} = q;
        q = q.Parent;
    end
    for i = numel(chain):-1:1
        g = chain{i};
        if ~isa(g, 'matlab.ui.container.GridLayout')
            continue
        end
        pad = 0;
        try
            pad = sum(g.Padding([1 3]));
        catch
        end
        sp = 0;
        try
            sp = g.ColumnSpacing;
        catch
        end
        inner = max(0, w - pad);
        n = numel(g.ColumnWidth);
        if n < 1
            w = inner;
            continue
        end
        child = tbl;
        if i > 1
            child = chain{i-1};
        end
        c0 = 1;
        c1 = n;
        try
            lc = child.Layout.Column;
            if numel(lc) >= 2
                c0 = lc(1);
                c1 = lc(2);
            elseif ~isempty(lc)
                c0 = lc(1);
                c1 = lc(1);
            elseif n > 1
                w = inner;
                continue
            end
        catch
            if n > 1
                w = inner;
                continue
            end
        end
        c0 = max(1, min(n, c0));
        c1 = max(c0, min(n, c1));
        if n > 1
            inner = max(0, inner - sp * (n - 1));
        end
        cell_ws = local_parse_col_widths(g.ColumnWidth, inner);
        w = sum(cell_ws(c0:c1));
        if c1 > c0
            w = w + sp * (c1 - c0);
        end
    end
catch
    w = 0;
end

end

function cell_ws = local_parse_col_widths(cws, inner)

n = numel(cws);
cell_ws = zeros(1, n);
weight = zeros(1, n);
fixed = 0;
for i = 1:n
    cw = cws{i};
    if isnumeric(cw)
        cell_ws(i) = cw;
        fixed = fixed + cw;
    else
        s = char(string(cw));
        if contains(s, 'x')
            v = str2double(erase(s, {'x', 'X'}));
            if isnan(v) || v <= 0
                v = 1;
            end
            weight(i) = v;
        else
            weight(i) = 1;
        end
    end
end
remain = max(0, inner - fixed);
wsum = sum(weight);
if wsum > 0
    cell_ws = cell_ws + weight * remain / wsum;
end

end

function s = local_flex_spec(w)

if w >= 2.5
    s = '3x';
elseif w >= 1.6
    s = '2x';
else
    s = '1x';
end

end

function w = local_compact_width(nm)

w = 0;
if isempty(nm)
    return
end
pairs = { ...
    'id', 32; ...
    'index', 32; ...
    'on', 42; ...
    'vis', 52; ...
    'visible', 52; ...
    'inv', 40; ...
    'invert normal', 40; ...
    'merge', 46; ...
    'mrg', 46; ...
    'cond.', 54; ...
    'cond', 54; ...
    'conductivity', 54; ...
    'mod.', 56; ...
    'modality', 56; ...
    'dir', 42; ...
    'directions', 42; ...
    'pts', 42; ...
    'points', 42; ...
    'act.', 108; ...
    'activity', 108; ...
    'tags', 48; ...
    'nodes', 56; ...
    'faces', 56; ...
    'type', 88; ...
    'unit', 52; ...
    'units', 52; ...
    'variable', 236; ...
    'sources', 72; ...
    'sensors', 72; ...
    'ref.', 112; ...
    'reference', 112};
for i = 1:size(pairs, 1)
    if strcmp(nm, pairs{i, 1})
        w = pairs{i, 2};
        return
    end
end

end

function w = local_flex_weight(nm)

w = 1;
if isempty(nm)
    return
end
if contains(nm, 'description')
    w = 3.4;
elseif contains(nm, 'variable')
    w = 2.4;
elseif contains(nm, 'script')
    w = 2.6;
elseif contains(nm, 'value') || strcmp(nm, 'default')
    w = 2.8;
elseif strcmp(nm, 'param')
    w = 1.8;
elseif contains(nm, 'parameter name')
    w = 2.6;
elseif any(strcmp(nm, {'name', 'plugin', 'tag'})) || contains(nm, 'plugin')
    w = 2.8;
end

end

function local_set_tbl(tbl, prop, value)

try
    if isprop(tbl, prop)
        tbl.(prop) = value;
    end
catch
end

end
