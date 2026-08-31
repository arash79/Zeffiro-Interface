function zef_layout_guide_form(fig)
%ZEF_LAYOUT_GUIDE_FORM  Compact a simple GUIDE label-and-field window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional figure() tools often place labels on the left and 15%-wide
%   edits on the far right. After zef_tool_start stretches the window to
%   520 px, that gap becomes a large empty column. This helper only runs
%   when the figure is a single-column text/edit form (no tables, lists,
%   axes, or multi-column XYZ clusters). Controls are converted to pixels
%   and stacked with a shared field column, then the window is sized to
%   the content. Later resizes grow the field column (capped) and keep
%   buttons compact at the bottom of the window.
%
%   zef_layout_guide_form(fig)
%
%   See also zef_layout_guide_window.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if isappdata(fig, 'ZefGuideForm')
    local_place(fig, getappdata(fig, 'ZefGuideForm'));
    return
end
if ~local_is_simple_form(fig)
    return
end

theme = zef_ui_theme();
try
    fig.AutoResizeChildren = 'off';
    fig.Units = 'pixels';
catch
end

texts = local_style(fig, 'text');
edits = [local_style(fig, 'edit'); local_style(fig, 'popupmenu')];
btns = local_style(fig, 'pushbutton');
if isempty(texts) || isempty(edits)
    return
end

pairs = local_pair(texts, edits);
if numel(pairs) < 3
    return
end
local_to_pixels(fig, [texts; edits; btns]);

footer = gobjects(0, 1);
extra = gobjects(0, 1);
for i = 1:numel(btns)
    txt = '';
    try
        txt = lower(strtrim(char(string(btns(i).String))));
    catch
    end
    if contains(txt, 'close') || contains(txt, 'apply') || contains(txt, 'start') ...
            || contains(txt, 'ok') || contains(txt, 'cancel')
        footer(end+1, 1) = btns(i); %#ok<AGROW>
    else
        extra(end+1, 1) = btns(i); %#ok<AGROW>
    end
end
if isempty(footer)
    footer = btns;
    extra = gobjects(0, 1);
end

lab_w = 132;
for i = 1:numel(pairs)
    lab_w = max(lab_w, local_label_px(pairs{i}{1}));
end
lab_w = min(260, lab_w + 8);

pair_y = zeros(numel(pairs), 1);
for i = 1:numel(pairs)
    pair_y(i) = local_yc(pairs{i}{1});
    try
        pair_y(i) = max(pair_y(i), local_yc(pairs{i}{2}));
    catch
    end
end
extra_y = zeros(numel(extra), 1);
for i = 1:numel(extra)
    extra_y(i) = local_yc(extra(i));
end

spec = struct();
spec.pairs = pairs;
spec.pair_y = pair_y;
spec.btns = footer;
spec.extra = extra;
spec.extra_y = extra_y;
spec.theme = theme;
spec.pad = 16;
spec.row_h = 28;
spec.row_gap = 10;
spec.btn_gap = 16;
spec.field_min = 148;
% Entry fields hold numbers or short strings, so letting them absorb every
% pixel of a widened window wastes the space instead of giving it to the
% label column. 320 matches the ceiling local_sesame_spread already applies
% and stays above the largest field_min the dropdown loop below can ask for
% (280), so the floor and the ceiling can never cross.
spec.field_max = 320;
for i = 1:numel(pairs)
    try
        fld = pairs{i}{2};
        st = lower(char(fld.Style));
        if ~strcmp(st, 'popupmenu')
            continue
        end
        items = fld.String;
        if ischar(items)
            items = cellstr(items);
        end
        for k = 1:numel(items)
            spec.field_min = max(spec.field_min, ...
                min(280, 36 + round(7.0 * numel(strtrim(char(string(items{k})))))));
        end
    catch
    end
end
spec.btn_w = 108;
spec.lab_w = lab_w;

setappdata(fig, 'ZefGuideForm', spec);
local_place(fig, spec);

n = numel(pairs) + numel(extra);
need_w = spec.pad + lab_w + 10 + spec.field_min + spec.pad;
need_h = spec.pad + n * (spec.row_h + spec.row_gap) - spec.row_gap ...
    + spec.btn_gap + spec.row_h + spec.pad;
need_w = max(need_w, spec.pad + numel(footer) * (spec.btn_w + 8) - 8 + spec.pad);
for i = 1:numel(extra)
    try
        s = char(string(extra(i).String));
        need_w = max(need_w, spec.pad + round(7.2 * numel(s) + 28) + spec.pad);
    catch
    end
end
zef_ui_apply_size(fig, need_w, need_h, need_w, need_h);
local_place(fig, spec);

end

function local_place(fig, spec)

if ~isgraphics(fig) || ~isvalid(fig) || isempty(spec)
    return
end
try
    spec.theme = zef_ui_theme();
catch
end
try
    fig.Units = 'pixels';
    p = fig.Position;
catch
    return
end
W = p(3);
H = p(4);
pad = spec.pad;
lab_w = spec.lab_w;
row_h = spec.row_h;
inner = max(lab_w + 10 + spec.field_min, W - 2 * pad);
field_w = max(spec.field_min, inner - lab_w - 10);
field_max = spec.field_min;
if isfield(spec, 'field_max')
    field_max = max(spec.field_min, spec.field_max);
end
field_w = min(field_w, field_max);
block = lab_w + 10 + field_w;
x0 = pad;

items = local_stack_items(spec);
y = H - pad - row_h;
for i = 1:numel(items)
    it = items{i};
    if strcmp(it.kind, 'extra')
        try
            btn = it.h;
            if isgraphics(btn) && isvalid(btn)
                btn.Units = 'pixels';
                btn.Position = [x0, y, block, row_h];
            end
        catch
        end
    else
        lab = it.lab;
        fld = it.fld;
        try
            if isgraphics(lab) && isvalid(lab)
                lab.Units = 'pixels';
                lab.HorizontalAlignment = 'left';
                lab.FontName = spec.theme.font.name;
                lab.ForegroundColor = spec.theme.color.text;
                lab.BackgroundColor = spec.theme.color.bg;
                lab.Position = [x0, y, lab_w, row_h];
            end
        catch
        end
        try
            if isgraphics(fld) && isvalid(fld)
                fld.Units = 'pixels';
                fld.Position = [x0 + lab_w + 10, y, field_w, row_h];
                fld.BackgroundColor = spec.theme.color.inputBg;
                fld.ForegroundColor = spec.theme.color.text;
            end
        catch
        end
    end
    y = y - row_h - spec.row_gap;
end

btns = spec.btns;
try
    btns = local_sort_footer(btns);
catch
end
nb = numel(btns);
if nb > 0
    total = nb * spec.btn_w + (nb - 1) * 8;
    x = x0 + block - total;
    x = max(x0, x);
    by = pad;
    need_y = pad + row_h + spec.row_gap;
    if y < need_y
        extra = need_y - y;
        try
            fig.Position(4) = H + extra;
            H = fig.Position(4);
        catch
        end
        for i = 1:numel(items)
            it = items{i};
            try
                if strcmp(it.kind, 'extra') && isgraphics(it.h) && isvalid(it.h)
                    it.h.Position(2) = it.h.Position(2) + extra;
                else
                    if isgraphics(it.lab) && isvalid(it.lab)
                        it.lab.Position(2) = it.lab.Position(2) + extra;
                    end
                    if isgraphics(it.fld) && isvalid(it.fld)
                        it.fld.Position(2) = it.fld.Position(2) + extra;
                    end
                end
            catch
            end
        end
    end
    for i = 1:nb
        try
            if isgraphics(btns(i)) && isvalid(btns(i))
                btns(i).Units = 'pixels';
                btns(i).Position = [x, by, spec.btn_w, row_h];
            end
        catch
        end
        x = x + spec.btn_w + 8;
    end
end

end

function items = local_stack_items(spec)

items = {};
ys = [];
pairs = spec.pairs;
pair_y = [];
try
    pair_y = spec.pair_y;
catch
end
for i = 1:numel(pairs)
    it = struct('kind', 'pair', 'lab', pairs{i}{1}, 'fld', pairs{i}{2}, 'h', []);
    items{end+1} = it; %#ok<AGROW>
    if i <= numel(pair_y)
        ys(end+1) = pair_y(i); %#ok<AGROW>
    else
        ys(end+1) = 0; %#ok<AGROW>
    end
end
extra = [];
extra_y = [];
try
    extra = spec.extra;
    extra_y = spec.extra_y;
catch
end
for i = 1:numel(extra)
    it = struct('kind', 'extra', 'lab', [], 'fld', [], 'h', extra(i));
    items{end+1} = it; %#ok<AGROW>
    if i <= numel(extra_y)
        ys(end+1) = extra_y(i); %#ok<AGROW>
    else
        ys(end+1) = 0; %#ok<AGROW>
    end
end
if isempty(items)
    return
end
[~, ord] = sort(ys(:), 'descend');
items = items(ord);

end

function btns = local_sort_footer(btns)

if isempty(btns)
    return
end
rank = inf(numel(btns), 1);
xs = inf(numel(btns), 1);
want = {'close', 'apply', 'start', 'ok', 'cancel'};
for i = 1:numel(btns)
    txt = '';
    try
        txt = lower(strtrim(char(string(btns(i).String))));
    catch
    end
    for k = 1:numel(want)
        if contains(txt, want{k})
            rank(i) = k;
            break
        end
    end
    try
        xs(i) = btns(i).Position(1);
    catch
    end
end
[~, bo] = sortrows([rank, xs]);
btns = btns(bo);

end

function tf = local_is_simple_form(fig)

tf = false;
if ~isempty(findall(fig, 'Type', 'uitable')) || ~isempty(findall(fig, 'Type', 'uipanel'))
    return
end
ax = findall(fig, 'Type', 'axes');
for i = 1:numel(ax)
    try
        if ~isempty(ax(i).Children)
            return
        end
    catch
        return
    end
end
if ~isempty(findall(fig, 'Type', 'uiaxes'))
    return
end
if ~isempty(local_style(fig, 'listbox')) || ~isempty(local_style(fig, 'slider'))
    return
end
texts = local_style(fig, 'text');
edits = local_style(fig, 'edit');
pops = local_style(fig, 'popupmenu');
btns = local_style(fig, 'pushbutton');
n_field = numel(edits) + numel(pops);
if numel(texts) < 3 || n_field < 3
    return
end
if numel(btns) > 8 || numel(pops) > 10
    return
end
if numel(findall(fig, 'Type', 'uicontrol')) > 55
    return
end
xs = local_norm_x(edits);
if isempty(xs)
    return
end
if max(xs) - min(xs) > 0.22
    return
end
tf = true;

end

function objs = local_style(fig, style)

objs = findall(fig, 'Type', 'uicontrol', 'Style', style);
if isempty(objs)
    objs = gobjects(0);
else
    objs = objs(:);
end

end

function local_to_pixels(fig, objs)

try
    fig.Units = 'pixels';
catch
end
if nargin < 2 || isempty(objs)
    return
end
for i = 1:numel(objs)
    try
        if isgraphics(objs(i)) && isvalid(objs(i))
            objs(i).Units = 'pixels';
        end
    catch
    end
end

end

function pairs = local_pair(texts, fields)

pairs = {};
used = false(numel(fields), 1);
[~, order] = sort(local_yc(texts), 'descend');
texts = texts(order);
for i = 1:numel(texts)
    ty = local_yc(texts(i));
    best = 0;
    best_d = inf;
    for k = 1:numel(fields)
        if used(k)
            continue
        end
        d = abs(local_yc(fields(k)) - ty);
        if d < best_d
            best_d = d;
            best = k;
        end
    end
    if best == 0 || best_d > 0.08
        continue
    end
    used(best) = true;
    pairs{end+1} = {texts(i), fields(best)}; %#ok<AGROW>
end

end

function y = local_yc(h)

if nargin < 1 || isempty(h)
    y = 0;
    return
end
n = numel(h);
if n > 1
    y = zeros(n, 1);
    for i = 1:n
        y(i) = local_yc(h(i));
    end
    return
end
p = [0 0 40 22];
try
    p = h.Position;
catch
end
if numel(p) < 4
    y = 0;
    return
end
y = p(2) + p(4) / 2;

end

function xs = local_norm_x(edits)

xs = zeros(numel(edits), 1);
for i = 1:numel(edits)
    try
        u = edits(i).Units;
        edits(i).Units = 'normalized';
        xs(i) = edits(i).Position(1);
        edits(i).Units = u;
    catch
        xs(i) = 0;
    end
end
xs = xs(:);

end

function w = local_label_px(lab)

w = 120;
try
    s = char(string(lab.String));
    w = max(w, round(7.2 * numel(s) + 12));
catch
end

end
