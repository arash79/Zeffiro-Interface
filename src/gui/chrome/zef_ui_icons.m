function out = zef_ui_icons(name, sz, fg, bg)
%ZEF_UI_ICONS  Load a themed CData icon from the shared SVG icon family.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   cdata = zef_ui_icons(name)
%   cdata = zef_ui_icons(name, sz, fg, bg)
%   folder = zef_ui_icons('folder')
%
%   Icons are rasterized from assets/fig/ui/<name>.svg. The SVG root style
%   (typically fill="none") is inherited, group transforms are applied, and
%   the visible artwork is optically fitted into the requested square.
%   Pale surface fills are omitted so interior strokes stay visible. Dark
%   ink is tinted with fg; chromatic SVG paint is kept. The result is
%   composited onto bg.
%
%   See also zef_ui_shell, zef_ui_theme.

if nargin < 1 || isempty(name)
    name = 'folder';
end
name = lower(char(string(name)));
if nargin < 2 || isempty(sz)
    sz = 20;
end
if nargin < 3 || isempty(fg)
    fg = [0.145 0.175 0.210];
    try
        th = zef_ui_theme();
        fg = th.color.text;
    catch
    end
end
if nargin < 4 || isempty(bg)
    bg = [0.945 0.952 0.956];
    try
        th = zef_ui_theme();
        bg = th.color.panel;
    catch
    end
end

if strcmp(name, 'folder')
    out = local_folder();
    return
end

sz = max(1, round(double(sz(1))));
fg = reshape(double(fg(1:3)), 1, 1, 3);
bg = reshape(double(bg(1:3)), 1, 1, 3);
key = sprintf('%s|%d|%.4f,%.4f,%.4f|%.4f,%.4f,%.4f', name, sz, fg(1), fg(2), fg(3), ...
    bg(1), bg(2), bg(3));
out = local_cache(key);
if ~isempty(out)
    return
end

file = local_file(name);
out = [];
if isempty(file)
    return
end
try
    [rgb, alpha] = local_raster_svg(file, sz);
catch
    return
end
if isempty(rgb) || isempty(alpha)
    return
end
straight = rgb;
mask = alpha > 1e-4;
for k = 1:3
    ch = rgb(:, :, k);
    ch(mask) = ch(mask) ./ alpha(mask);
    straight(:, :, k) = min(1, max(0, ch));
end
chroma = max(straight, [], 3) - min(straight, [], 3);
keep = chroma > 0.18;
ink = straight;
for k = 1:3
    ch = ink(:, :, k);
    ch(~keep) = fg(k);
    ink(:, :, k) = ch;
end
a = alpha;
out = zeros(sz, sz, 3);
for k = 1:3
    out(:, :, k) = bg(k) .* (1 - a) + ink(:, :, k) .* a;
end
out = max(0, min(1, out));
local_cache(key, out);

end

function folder = local_folder()

root = fileparts(which('zeffiro_interface'));
if isempty(root)
    root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
end
folder = fullfile(root, 'assets', 'fig', 'ui');

end

function file = local_file(name)

folder = local_folder();
cands = { ...
    fullfile(folder, [name '.svg']), ...
    [name '.svg']};
file = '';
for i = 1:numel(cands)
    if exist(cands{i}, 'file') == 2
        file = cands{i};
        return
    end
    w = which(cands{i});
    if ~isempty(w)
        file = w;
        return
    end
end

end

function out = local_cache(key, value)

persistent keys vals
if isempty(keys)
    keys = {};
    vals = {};
end
if nargin < 2
    out = [];
    idx = find(strcmp(keys, key), 1);
    if ~isempty(idx)
        out = vals{idx};
    end
    return
end
idx = find(strcmp(keys, key), 1);
if isempty(idx)
    keys{end+1} = key; %#ok<AGROW>
    vals{end+1} = value; %#ok<AGROW>
else
    vals{idx} = value;
end
out = value;

end

function [rgb, alpha] = local_raster_svg(file, sz)

txt = fileread(file);
vb = [0 0 128 128];
tok = regexp(txt, 'viewBox\s*=\s*"([^"]+)"', 'tokens', 'once');
if ~isempty(tok)
    v = sscanf(tok{1}, '%f').';
    if numel(v) == 4
        vb = v;
    end
end
st0 = local_default_style();
svg_open = regexp(txt, '<svg([^>]*)>', 'tokens', 'once');
if ~isempty(svg_open)
    st0 = local_merge_style(st0, local_parse_attrs(svg_open{1}));
end
grads = local_parse_grads(txt);
txt = regexprep(txt, '<defs[\s\S]*?</defs>', '');
txt = regexprep(txt, '<title[\s\S]*?</title>', '');
inner = regexp(txt, '<svg[^>]*>([\s\S]*)</svg>', 'tokens', 'once');
if isempty(inner)
    inner = {txt};
end
ctxb = local_bounds_canvas(vb);
ctxb = local_draw_fragment(inner{1}, st0, grads, ctxb);
vb2 = local_optical_viewbox(ctxb.bounds, vb);
ss = 4;
if sz >= 72
    ss = 3;
end
h = sz * ss;
ctx = local_new_canvas(h, vb2);
ctx = local_draw_fragment(inner{1}, st0, grads, ctx);
rgb = local_downsample(ctx.rgb, sz);
alpha = local_downsample(ctx.alpha, sz);

end

function grads = local_parse_grads(txt)

grads = struct();
blocks = regexp(txt, '<linearGradient\s+id="([^"]+)"[\s\S]*?</linearGradient>', 'match');
for i = 1:numel(blocks)
    idtok = regexp(blocks{i}, 'id="([^"]+)"', 'tokens', 'once');
    if isempty(idtok)
        continue
    end
    cols = regexp(blocks{i}, 'stop-color="([^"]+)"', 'tokens');
    rgb = [0.078 0.722 0.651];
    if ~isempty(cols)
        parsed = zeros(numel(cols), 3);
        n = 0;
        for j = 1:numel(cols)
            c = local_parse_color(cols{j}{1}, struct(), false);
            if ~isempty(c)
                n = n + 1;
                parsed(n, :) = c;
            end
        end
        if n > 0
            rgb = parsed(max(1, ceil(n / 2)), :);
        end
    end
    grads.(matlab.lang.makeValidName(idtok{1})) = rgb;
end

end

function st = local_default_style()

st = struct('fill', 'black', 'stroke', 'none', 'stroke_width', 1, 'opacity', 1);

end

function st = local_merge_style(st, attrs)

if isfield(attrs, 'fill') && ~isempty(attrs.fill)
    st.fill = attrs.fill;
end
if isfield(attrs, 'stroke') && ~isempty(attrs.stroke)
    st.stroke = attrs.stroke;
end
if isfield(attrs, 'stroke_width') && ~isempty(attrs.stroke_width)
    st.stroke_width = str2double(attrs.stroke_width);
end
if isfield(attrs, 'opacity') && ~isempty(attrs.opacity)
    st.opacity = str2double(attrs.opacity);
end

end

function attrs = local_parse_attrs(s)

attrs = struct();
toks = regexp(char(string(s)), '([A-Za-z0-9_:-]+)\s*=\s*"([^"]*)"', 'tokens');
for i = 1:numel(toks)
    key = matlab.lang.makeValidName(strrep(toks{i}{1}, '-', '_'));
    attrs.(key) = toks{i}{2};
end

end

function ctx = local_new_canvas(h, vb)

[jj, ii] = meshgrid((0.5:h), (0.5:h));
ctx = struct();
ctx.H = h;
ctx.vb = vb;
ctx.px = vb(3) / h;
ctx.sx = vb(1) + jj * vb(3) / h;
ctx.sy = vb(2) + ii * vb(4) / h;
ctx.rgb = zeros(h, h, 3);
ctx.alpha = zeros(h, h);
ctx.xfm = eye(3);
ctx.skip_paint = false;
ctx.bounds = [inf inf -inf -inf];

end

function ctx = local_bounds_canvas(vb)

ctx = struct();
ctx.H = 2;
ctx.vb = vb;
ctx.px = 1;
ctx.sx = 0;
ctx.sy = 0;
ctx.rgb = zeros(2, 2, 3);
ctx.alpha = zeros(2, 2);
ctx.xfm = eye(3);
ctx.skip_paint = true;
ctx.bounds = [inf inf -inf -inf];

end

function vb2 = local_optical_viewbox(b, vb)

vb2 = vb;
if nargin < 1 || numel(b) < 4 || ~all(isfinite(b(1:4)))
    return
end
w = max(1e-3, b(3) - b(1));
h = max(1e-3, b(4) - b(2));
span = max(w, h);
fill = 0.82;
canvas = span / fill;
if canvas >= vb(3) * 0.98
    return
end
cx = 0.5 * (b(1) + b(3));
cy = 0.5 * (b(2) + b(4));
vb2 = [cx - canvas / 2, cy - canvas / 2, canvas, canvas];

end

function ctx = local_touch_bounds(ctx, pts, pad)

if nargin < 3 || isempty(pad)
    pad = 0;
end
if ~isfield(ctx, 'bounds') || numel(ctx.bounds) < 4
    ctx.bounds = [inf inf -inf -inf];
end
if isempty(pts)
    return
end
ctx.bounds(1) = min(ctx.bounds(1), min(pts(:, 1)) - pad);
ctx.bounds(2) = min(ctx.bounds(2), min(pts(:, 2)) - pad);
ctx.bounds(3) = max(ctx.bounds(3), max(pts(:, 1)) + pad);
ctx.bounds(4) = max(ctx.bounds(4), max(pts(:, 2)) + pad);

end

function M = local_parse_transform(s)

M = eye(3);
s = strtrim(char(string(s)));
if isempty(s)
    return
end
toks = regexp(s, '([A-Za-z]+)\s*\(([^)]*)\)', 'tokens');
for i = 1:numel(toks)
    name = lower(toks{i}{1});
    raw = regexprep(toks{i}{2}, ',', ' ');
    nums = sscanf(raw, '%f');
    T = eye(3);
    switch name
        case 'translate'
            tx = 0;
            ty = 0;
            if numel(nums) >= 1
                tx = nums(1);
            end
            if numel(nums) >= 2
                ty = nums(2);
            end
            T = [1 0 tx; 0 1 ty; 0 0 1];
        case 'scale'
            sx = 1;
            if numel(nums) >= 1
                sx = nums(1);
            end
            sy = sx;
            if numel(nums) >= 2
                sy = nums(2);
            end
            T = [sx 0 0; 0 sy 0; 0 0 1];
        case 'rotate'
            ang = 0;
            if numel(nums) >= 1
                ang = nums(1) * pi / 180;
            end
            c = cos(ang);
            si = sin(ang);
            R = [c -si 0; si c 0; 0 0 1];
            if numel(nums) >= 3
                cx = nums(2);
                cy = nums(3);
                Tr = [1 0 cx; 0 1 cy; 0 0 1];
                Ti = [1 0 -cx; 0 1 -cy; 0 0 1];
                T = Tr * R * Ti;
            else
                T = R;
            end
        case 'matrix'
            if numel(nums) >= 6
                T = [nums(1) nums(3) nums(5); nums(2) nums(4) nums(6); 0 0 1];
            end
    end
    M = M * T;
end

end

function pts2 = local_xform_pts(M, pts)

if isempty(pts)
    pts2 = pts;
    return
end
if nargin < 1 || isempty(M) || isequal(M, eye(3))
    pts2 = pts;
    return
end
n = size(pts, 1);
hom = [pts, ones(n, 1)] * M.';
pts2 = hom(:, 1:2);

end

function s = local_xfm_scale(M)

s = 1;
if nargin < 1 || isempty(M)
    return
end
detlin = M(1, 1) * M(2, 2) - M(1, 2) * M(2, 1);
s = sqrt(abs(detlin));
if ~(s > 1e-9)
    s = 1;
end

end

function ctx = local_draw_fragment(xml, style, grads, ctx)

xml = char(xml);
n = numel(xml);
i = 1;
while i <= n
    lt = i;
    while lt <= n && xml(lt) ~= '<'
        lt = lt + 1;
    end
    if lt > n
        break
    end
    if lt < n && xml(lt + 1) == '/'
        break
    end
    if lt < n && xml(lt + 1) == '!'
        gt = strfind(xml(lt:end), '-->');
        if isempty(gt)
            break
        end
        i = lt + gt(1) + 2;
        continue
    end
    j = lt + 1;
    while j <= n && ((xml(j) >= 'a' && xml(j) <= 'z') || (xml(j) >= 'A' && xml(j) <= 'Z'))
        j = j + 1;
    end
    name = lower(xml(lt + 1:j - 1));
    k = j;
    while k <= n && xml(k) ~= '>'
        k = k + 1;
    end
    if k > n
        break
    end
    attr_str = xml(j:k - 1);
    self_close = false;
    if ~isempty(attr_str) && attr_str(end) == '/'
        self_close = true;
        attr_str = attr_str(1:end - 1);
    end
    attrs = local_parse_attrs(attr_str);
    st = local_merge_style(style, attrs);
    i = k + 1;
    old_xfm = [];
    if isfield(ctx, 'xfm') && isfield(attrs, 'transform') && ~isempty(attrs.transform)
        old_xfm = ctx.xfm;
        ctx.xfm = ctx.xfm * local_parse_transform(attrs.transform);
    end
    if strcmp(name, 'g') || strcmp(name, 'svg')
        if ~self_close
            [inner, i] = local_inner_xml(xml, i, name);
            ctx = local_draw_fragment(inner, st, grads, ctx);
        end
    elseif strcmp(name, 'path')
        ctx = local_paint_path(ctx, attrs, st, grads);
        if ~self_close
            [~, i] = local_inner_xml(xml, i, name);
        end
    elseif strcmp(name, 'circle')
        ctx = local_paint_circle(ctx, attrs, st, grads);
        if ~self_close
            [~, i] = local_inner_xml(xml, i, name);
        end
    elseif strcmp(name, 'ellipse')
        ctx = local_paint_ellipse(ctx, attrs, st, grads);
        if ~self_close
            [~, i] = local_inner_xml(xml, i, name);
        end
    elseif strcmp(name, 'rect')
        ctx = local_paint_rect(ctx, attrs, st, grads);
        if ~self_close
            [~, i] = local_inner_xml(xml, i, name);
        end
    elseif ~self_close
        [~, i] = local_inner_xml(xml, i, name);
    end
    if ~isempty(old_xfm)
        ctx.xfm = old_xfm;
    end
end

end

function [inner, next_i] = local_inner_xml(xml, i, name)

open_pat = ['<' name];
close_pat = ['</' name '>'];
depth = 1;
p = i;
n = numel(xml);
while p <= n && depth > 0
    nxt_close = strfind(xml(p:end), close_pat);
    nxt_open = strfind(xml(p:end), open_pat);
    if isempty(nxt_close)
        inner = xml(i:end);
        next_i = n + 1;
        return
    end
    c0 = p + nxt_close(1) - 1;
    if ~isempty(nxt_open) && nxt_open(1) < nxt_close(1)
        depth = depth + 1;
        p = p + nxt_open(1) + numel(open_pat) - 1;
    else
        depth = depth - 1;
        if depth == 0
            inner = xml(i:c0 - 1);
            next_i = c0 + numel(close_pat);
            return
        end
        p = c0 + numel(close_pat);
    end
end
inner = xml(i:end);
next_i = n + 1;

end

function ctx = local_paint_path(ctx, attrs, st, grads)

if ~isfield(attrs, 'd')
    return
end
subs = local_parse_path(attrs.d);
ctx = local_paint_subs(ctx, subs, st, grads);

end

function ctx = local_paint_circle(ctx, attrs, st, grads)

cx = local_num_attr(attrs, 'cx', 0);
cy = local_num_attr(attrs, 'cy', 0);
r = local_num_attr(attrs, 'r', 0);
M = eye(3);
if isfield(ctx, 'xfm')
    M = ctx.xfm;
end
cxy = local_xform_pts(M, [cx cy]);
sc = local_xfm_scale(M);
r = r * sc;
sw = st.stroke_width * sc;
ctx = local_touch_bounds(ctx, cxy, r + sw / 2);
if isfield(ctx, 'skip_paint') && ctx.skip_paint
    return
end
cx = cxy(1);
cy = cxy(2);
fillc = local_parse_color(st.fill, grads, true);
strokec = local_parse_color(st.stroke, grads, false);
aa = 0.65 * ctx.px;
d = hypot(ctx.sx - cx, ctx.sy - cy);
if ~isempty(fillc)
    cover = min(1, max(0, (r + aa / 2 - d) / max(aa, 1e-6)));
    ctx = local_blit(ctx, cover, fillc, st.opacity);
end
if ~isempty(strokec) && sw > 0
    cover = min(1, max(0, (sw / 2 + aa / 2 - abs(d - r)) / max(aa, 1e-6)));
    ctx = local_blit(ctx, cover, strokec, st.opacity);
end

end

function ctx = local_paint_ellipse(ctx, attrs, st, grads)

cx = local_num_attr(attrs, 'cx', 0);
cy = local_num_attr(attrs, 'cy', 0);
rx = local_num_attr(attrs, 'rx', 0);
ry = local_num_attr(attrs, 'ry', 0);
t = linspace(0, 2 * pi, 64);
pts = [cx + rx * cos(t(:)), cy + ry * sin(t(:))];
pts = [pts; pts(1, :)];
subs = struct('pts', pts, 'closed', true);
ctx = local_paint_subs(ctx, subs, st, grads);

end

function ctx = local_paint_rect(ctx, attrs, st, grads)

x = local_num_attr(attrs, 'x', 0);
y = local_num_attr(attrs, 'y', 0);
w = local_num_attr(attrs, 'width', 0);
h = local_num_attr(attrs, 'height', 0);
rx = local_num_attr(attrs, 'rx', nan);
ry = local_num_attr(attrs, 'ry', nan);
if isnan(rx)
    rx = 0;
end
if isnan(ry)
    ry = rx;
end
d = local_rounded_rect_d(x, y, w, h, rx, ry);
subs = local_parse_path(d);
ctx = local_paint_subs(ctx, subs, st, grads);

end

function d = local_rounded_rect_d(x, y, w, h, rx, ry)

rx = min(rx, w / 2);
ry = min(ry, h / 2);
if rx < 1e-6 || ry < 1e-6
    d = sprintf('M%g %gH%gV%gH%gZ', x, y, x + w, y + h, x);
    return
end
d = sprintf(['M%g %gH%gA%g %g 0 0 1 %g %gV%gA%g %g 0 0 1 %g %gH%g' ...
    'A%g %g 0 0 1 %g %gV%gA%g %g 0 0 1 %g %gZ'], ...
    x + rx, y, x + w - rx, rx, ry, x + w, y + ry, y + h - ry, rx, ry, ...
    x + w - rx, y + h, x + rx, rx, ry, x, y + h - ry, y + ry, rx, ry, x + rx, y);

end

function ctx = local_paint_subs(ctx, subs, st, grads)

fillc = local_parse_color(st.fill, grads, true);
strokec = local_parse_color(st.stroke, grads, false);
aa = 0.65 * ctx.px;
M = eye(3);
if isfield(ctx, 'xfm')
    M = ctx.xfm;
end
sw = st.stroke_width * local_xfm_scale(M);
if ~isstruct(subs) || isempty(subs)
    return
end
for i = 1:numel(subs)
    pts = local_xform_pts(M, subs(i).pts);
    if size(pts, 1) < 2
        continue
    end
    ctx = local_touch_bounds(ctx, pts, sw / 2);
    if isfield(ctx, 'skip_paint') && ctx.skip_paint
        continue
    end
    if ~isempty(fillc) && (subs(i).closed || size(pts, 1) >= 3)
        mask = inpolygon(ctx.sx, ctx.sy, pts(:, 1), pts(:, 2));
        ctx = local_blit(ctx, double(mask), fillc, st.opacity);
    end
    if ~isempty(strokec) && sw > 0
        d = local_dist_poly(ctx.sx, ctx.sy, pts);
        cover = min(1, max(0, (sw / 2 + aa / 2 - d) / max(aa, 1e-6)));
        ctx = local_blit(ctx, cover, strokec, st.opacity);
    end
end

end

function ctx = local_blit(ctx, cover, color, opacity)

a = min(1, max(0, cover * opacity));
if max(a(:)) <= 0
    return
end
for k = 1:3
    ch = ctx.rgb(:, :, k);
    ch = ch .* (1 - a) + color(k) * a;
    ctx.rgb(:, :, k) = ch;
end
ctx.alpha = ctx.alpha .* (1 - a) + a;

end

function dmin = local_dist_poly(px, py, pts)

dmin = inf(size(px));
for i = 1:size(pts, 1) - 1
    ax = pts(i, 1);
    ay = pts(i, 2);
    bx = pts(i + 1, 1);
    by = pts(i + 1, 2);
    abx = bx - ax;
    aby = by - ay;
    apx = px - ax;
    apy = py - ay;
    den = abx * abx + aby * aby;
    if den < 1e-18
        d = hypot(apx, apy);
    else
        t = min(1, max(0, (apx * abx + apy * aby) / den));
        d = hypot(apx - t * abx, apy - t * aby);
    end
    dmin = min(dmin, d);
end

end

function rgb = local_parse_color(spec, grads, as_fill)

rgb = [];
if nargin < 3
    as_fill = false;
end
spec = strtrim(char(string(spec)));
if isempty(spec) || strcmpi(spec, 'none')
    return
end
if as_fill && any(strcmpi(spec, {'white', '#fff', '#ffffff', 'url(#g2)'}))
    return
end
if strcmpi(spec, 'white')
    rgb = [1 1 1];
    return
end
if strcmpi(spec, 'black')
    rgb = [0 0 0];
    return
end
tok = regexp(spec, 'url\(#([^)]+)\)', 'tokens', 'once');
if ~isempty(tok)
    id = matlab.lang.makeValidName(tok{1});
    if isfield(grads, id)
        rgb = grads.(id);
    else
        rgb = [0.078 0.722 0.651];
    end
    if as_fill && local_lum(rgb) > 0.72
        rgb = [];
    end
    return
end
if ~isempty(spec) && spec(1) == '#'
    h = spec(2:end);
    if numel(h) == 3
        h = [h(1) h(1) h(2) h(2) h(3) h(3)];
    end
    if numel(h) >= 6
        rgb = [hex2dec(h(1:2)) hex2dec(h(3:4)) hex2dec(h(5:6))] / 255;
        if as_fill && local_lum(rgb) > 0.72
            rgb = [];
        end
    end
    return
end
rgb = [0 0 0];

end

function y = local_lum(c)

y = 0.2126 * c(1) + 0.7152 * c(2) + 0.0722 * c(3);

end

function v = local_num_attr(attrs, name, default)

v = default;
if isfield(attrs, name) && ~isempty(attrs.(name))
    v = str2double(attrs.(name));
    if isnan(v)
        v = default;
    end
end

end

function subs = local_parse_path(d)

cmds = local_tokenize_path(d);
cx = 0;
cy = 0;
sx = 0;
sy = 0;
last_c = [0 0];
last_cubic = false;
pts = zeros(0, 2);
subs = struct('pts', {}, 'closed', {});
for ci = 1:numel(cmds)
    cmd = cmds(ci).cmd;
    nums = cmds(ci).nums;
    rel = cmd >= 'a' && cmd <= 'z';
    c = upper(cmd);
    k = 1;
    nn = numel(nums);
    if c == 'M'
        [subs, pts] = local_flush_sub(subs, pts, false);
        first = true;
        while k + 1 <= nn
            x = nums(k);
            y = nums(k + 1);
            k = k + 2;
            if rel
                x = x + cx;
                y = y + cy;
            end
            cx = x;
            cy = y;
            if first
                sx = cx;
                sy = cy;
                first = false;
            end
            pts(end + 1, :) = [cx, cy]; %#ok<AGROW>
        end
        last_cubic = false;
    elseif c == 'Z'
        if ~isempty(pts)
            pts(end + 1, :) = [sx, sy]; %#ok<AGROW>
        end
        cx = sx;
        cy = sy;
        [subs, ~] = local_flush_sub(subs, pts, true);
        pts = [cx, cy];
        last_cubic = false;
    elseif c == 'L'
        while k + 1 <= nn
            x = nums(k);
            y = nums(k + 1);
            k = k + 2;
            if rel
                x = x + cx;
                y = y + cy;
            end
            cx = x;
            cy = y;
            pts(end + 1, :) = [cx, cy]; %#ok<AGROW>
        end
        last_cubic = false;
    elseif c == 'H'
        while k <= nn
            x = nums(k);
            k = k + 1;
            if rel
                x = x + cx;
            end
            cx = x;
            pts(end + 1, :) = [cx, cy]; %#ok<AGROW>
        end
        last_cubic = false;
    elseif c == 'V'
        while k <= nn
            y = nums(k);
            k = k + 1;
            if rel
                y = y + cy;
            end
            cy = y;
            pts(end + 1, :) = [cx, cy]; %#ok<AGROW>
        end
        last_cubic = false;
    elseif c == 'C'
        while k + 5 <= nn
            x1 = nums(k);
            y1 = nums(k + 1);
            x2 = nums(k + 2);
            y2 = nums(k + 3);
            x = nums(k + 4);
            y = nums(k + 5);
            k = k + 6;
            if rel
                x1 = x1 + cx;
                y1 = y1 + cy;
                x2 = x2 + cx;
                y2 = y2 + cy;
                x = x + cx;
                y = y + cy;
            end
            samp = local_cubic([cx cy], [x1 y1], [x2 y2], [x y], 16);
            pts = [pts; samp]; %#ok<AGROW>
            last_c = [x2 y2];
            cx = x;
            cy = y;
            last_cubic = true;
        end
    elseif c == 'S'
        while k + 3 <= nn
            x2 = nums(k);
            y2 = nums(k + 1);
            x = nums(k + 2);
            y = nums(k + 3);
            k = k + 4;
            if rel
                x2 = x2 + cx;
                y2 = y2 + cy;
                x = x + cx;
                y = y + cy;
            end
            if last_cubic
                x1 = 2 * cx - last_c(1);
                y1 = 2 * cy - last_c(2);
            else
                x1 = cx;
                y1 = cy;
            end
            samp = local_cubic([cx cy], [x1 y1], [x2 y2], [x y], 16);
            pts = [pts; samp]; %#ok<AGROW>
            last_c = [x2 y2];
            cx = x;
            cy = y;
            last_cubic = true;
        end
    elseif c == 'A'
        while k + 6 <= nn
            rx = nums(k);
            ry = nums(k + 1);
            rot = nums(k + 2);
            fa = nums(k + 3);
            fs = nums(k + 4);
            x = nums(k + 5);
            y = nums(k + 6);
            k = k + 7;
            if rel
                x = x + cx;
                y = y + cy;
            end
            samp = local_arc(cx, cy, rx, ry, rot, fa, fs, x, y, 16);
            pts = [pts; samp]; %#ok<AGROW>
            cx = x;
            cy = y;
        end
        last_cubic = false;
    else
        last_cubic = false;
    end
end
[subs, ~] = local_flush_sub(subs, pts, false);
keep = false(size(subs));
for i = 1:numel(subs)
    keep(i) = size(subs(i).pts, 1) >= 2;
end
subs = subs(keep);

end

function [subs, pts] = local_flush_sub(subs, pts, closed)

if size(pts, 1) >= 1
    item = struct('pts', pts, 'closed', closed);
    if isempty(subs)
        subs = item;
    else
        subs(end + 1) = item; %#ok<AGROW>
    end
end
pts = zeros(0, 2);

end

function cmds = local_tokenize_path(d)

d = char(string(d));
n = numel(d);
i = 1;
cmds = struct('cmd', {}, 'nums', {});
while i <= n
    while i <= n && (d(i) <= ' ' || d(i) == ',')
        i = i + 1;
    end
    if i > n
        break
    end
    ch = d(i);
    if (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')
        cmd = ch;
        i = i + 1;
        nums = [];
        while true
            while i <= n && (d(i) <= ' ' || d(i) == ',')
                i = i + 1;
            end
            if i > n
                break
            end
            nc = d(i);
            if (nc >= 'A' && nc <= 'Z') || (nc >= 'a' && nc <= 'z')
                break
            end
            [val, i] = local_read_number(d, i);
            if ~isnan(val)
                nums(end + 1) = val; %#ok<AGROW>
            else
                i = i + 1;
            end
        end
        cmds(end + 1) = struct('cmd', cmd, 'nums', nums); %#ok<AGROW>
    else
        i = i + 1;
    end
end

end

function [val, i] = local_read_number(d, i)

n = numel(d);
start = i;
if i <= n && (d(i) == '+' || d(i) == '-')
    i = i + 1;
end
while i <= n && d(i) >= '0' && d(i) <= '9'
    i = i + 1;
end
if i <= n && d(i) == '.'
    i = i + 1;
    while i <= n && d(i) >= '0' && d(i) <= '9'
        i = i + 1;
    end
end
if i <= n && (d(i) == 'e' || d(i) == 'E')
    i = i + 1;
    if i <= n && (d(i) == '+' || d(i) == '-')
        i = i + 1;
    end
    while i <= n && d(i) >= '0' && d(i) <= '9'
        i = i + 1;
    end
end
if i == start || (i == start + 1 && (d(start) == '+' || d(start) == '-' || d(start) == '.'))
    val = nan;
    return
end
val = str2double(d(start:i - 1));

end

function pts = local_cubic(p0, p1, p2, p3, n)

n = max(n, 24);
t = linspace(0, 1, n + 1).';
t = t(2:end);
u = 1 - t;
pts = u .^ 3 .* p0 + (3 * u .^ 2 .* t) .* p1 + (3 * u .* t .^ 2) .* p2 + t .^ 3 .* p3;

end

function pts = local_arc(x1, y1, rx, ry, phi_deg, fa, fs, x2, y2, n)

rx = abs(rx);
ry = abs(ry);
if rx < 1e-9 || ry < 1e-9
    pts = [x2 y2];
    return
end
fa = fa ~= 0;
fs = fs ~= 0;
phi = phi_deg * pi / 180;
cosr = cos(phi);
sinr = sin(phi);
dx = (x1 - x2) / 2;
dy = (y1 - y2) / 2;
x1p = cosr * dx + sinr * dy;
y1p = -sinr * dx + cosr * dy;
lam = (x1p / rx) ^ 2 + (y1p / ry) ^ 2;
if lam > 1
    s = sqrt(lam);
    rx = rx * s;
    ry = ry * s;
end
num = rx ^ 2 * ry ^ 2 - rx ^ 2 * y1p ^ 2 - ry ^ 2 * x1p ^ 2;
den = rx ^ 2 * y1p ^ 2 + ry ^ 2 * x1p ^ 2;
coef = sqrt(max(0, num / den));
if fa == fs
    coef = -coef;
end
cxp = coef * rx * y1p / ry;
cyp = coef * -ry * x1p / rx;
cx = cosr * cxp - sinr * cyp + (x1 + x2) / 2;
cy = sinr * cxp + cosr * cyp + (y1 + y2) / 2;
th1 = atan2((y1p - cyp) / ry, (x1p - cxp) / rx);
th2 = atan2((-y1p - cyp) / ry, (-x1p - cxp) / rx);
dth = th2 - th1;
if ~fs && dth > 0
    dth = dth - 2 * pi;
elseif fs && dth < 0
    dth = dth + 2 * pi;
end
n = max(n, ceil(abs(dth) / (pi / 12)));
t = linspace(0, 1, n + 1).';
t = t(2:end);
th = th1 + t * dth;
xt = cx + rx * cos(th) * cosr - ry * sin(th) * sinr;
yt = cy + rx * cos(th) * sinr + ry * sin(th) * cosr;
pts = [xt yt];

end

function out = local_downsample(img, sz)

h = size(img, 1);
if h == sz
    out = img;
    return
end
try
    out = imresize(img, [sz sz], 'lanczos3');
    return
catch
end
out = local_box_down(img, sz);

end

function out = local_box_down(img, sz)

h = size(img, 1);
if h == sz
    out = img;
    return
end
f = h / sz;
if abs(f - round(f)) < 1e-9 && round(f) >= 2
    f = round(f);
    nc = size(img, 3);
    out = zeros(sz, sz, nc);
    w = size(img, 2);
    for k = 1:nc
        ch = img(:, :, k);
        tmp = reshape(ch, f, sz, w);
        tmp = squeeze(mean(tmp, 1));
        tmp = reshape(tmp, sz, f, sz);
        out(:, :, k) = squeeze(mean(tmp, 2));
    end
    if nc == 1
        out = out(:, :, 1);
    end
    return
end
try
    out = imresize(img, [sz sz], 'bilinear');
catch
    out = img;
end

end
