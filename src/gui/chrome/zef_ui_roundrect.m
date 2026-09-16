function rgb = zef_ui_roundrect(w, h, radius, fillc, borderc, outerc)
%ZEF_UI_ROUNDRECT  Antialiased rounded-rect CData for traditional figures.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional uipanel cannot paint an 8–12 px corner radius. This
%   helper returns an RGB image whose outside corners match the figure
%   background so a stacked image layer can fake a card. A 1 px blend
%   keeps Retina scaling from smearing the edge into a grey halo.
%
%   rgb = zef_ui_roundrect(w, h, radius, fill, border, outer)
%
%   See also zef_ui_card, zef_ui_theme.

if nargin < 1 || isempty(w)
    w = 40;
end
if nargin < 2 || isempty(h)
    h = 40;
end
if nargin < 3 || isempty(radius)
    radius = 10;
end
if nargin < 4 || isempty(fillc)
    fillc = [1 1 1];
end
if nargin < 5 || isempty(borderc)
    borderc = [0.86 0.92 0.92];
end
if nargin < 6 || isempty(outerc)
    outerc = [0.965 0.970 0.974];
end

w = max(8, round(double(w(1))));
h = max(8, round(double(h(1))));
r = max(3, min(round(double(radius(1))), floor(min(w, h) / 2)));
fillc = reshape(double(fillc(1:3)), 1, 1, 3);
borderc = reshape(double(borderc(1:3)), 1, 1, 3);
outerc = reshape(double(outerc(1:3)), 1, 1, 3);

rgb = local_cache(w, h, r, fillc, borderc, outerc);
if ~isempty(rgb)
    return
end

band = r + 2;
if w > 2 * band + 2 && h > 2 * band + 2
    rgb = zeros(h, w, 3);
    rgb(:, :, 1) = fillc(1);
    rgb(:, :, 2) = fillc(2);
    rgb(:, :, 3) = fillc(3);
    rgb(1:band, 1:band, :) = local_sdf(w, h, r, fillc, borderc, outerc, ...
        1, band, 1, band);
    rgb(1:band, w - band + 1:w, :) = local_sdf(w, h, r, fillc, borderc, outerc, ...
        w - band + 1, w, 1, band);
    rgb(h - band + 1:h, 1:band, :) = local_sdf(w, h, r, fillc, borderc, outerc, ...
        1, band, h - band + 1, h);
    rgb(h - band + 1:h, w - band + 1:w, :) = local_sdf(w, h, r, fillc, borderc, outerc, ...
        w - band + 1, w, h - band + 1, h);
else
    rgb = local_sdf(w, h, r, fillc, borderc, outerc, 1, w, 1, h);
end
rgb = max(0, min(1, rgb));
local_cache(w, h, r, fillc, borderc, outerc, rgb);

end

function rgb = local_sdf(w, h, r, fillc, borderc, outerc, x0, x1, y0, y1)

[x, y] = meshgrid(single(x0:x1), single(y0:y1));
px = abs(x - 0.5 - w / 2) - (w / 2 - r);
py = abs(y - 0.5 - h / 2) - (h / 2 - r);
d = hypot(max(px, 0), max(py, 0)) + min(max(px, py), 0) - r;

ph = y1 - y0 + 1;
pw = x1 - x0 + 1;
rgb = zeros(ph, pw, 3);
rgb(:, :, 1) = outerc(1);
rgb(:, :, 2) = outerc(2);
rgb(:, :, 3) = outerc(3);
inside = d < -0.45;
for k = 1:3
    ch = rgb(:, :, k);
    ch(inside) = fillc(k);
    rgb(:, :, k) = ch;
end

edge = ~inside & (d < 0.55);
if any(edge(:))
    t = double(d(edge));
    a_fill = max(0, min(1, (-t) / 0.45));
    a_outer = max(0, min(1, (t + 0.05) / 0.50));
    a_border = max(0, 1 - a_fill - a_outer);
    s = a_fill + a_border + a_outer;
    a_fill = a_fill ./ s;
    a_border = a_border ./ s;
    a_outer = a_outer ./ s;
    for k = 1:3
        ch = rgb(:, :, k);
        ev = fillc(k) * a_fill + borderc(k) * a_border + outerc(k) * a_outer;
        ch(edge) = ev;
        rgb(:, :, k) = ch;
    end
end

end

function rgb = local_cache(w, h, r, fillc, borderc, outerc, value)

persistent keys vals
if isempty(keys)
    keys = zeros(0, 12);
    vals = {};
end
key = [w, h, r, round(fillc(:).' * 1000), round(borderc(:).' * 1000), ...
    round(outerc(:).' * 1000)];
if nargin < 7
    rgb = [];
    for i = numel(vals):-1:1
        if isequal(keys(i, :), key)
            rgb = vals{i};
            return
        end
    end
    return
end
idx = [];
for i = 1:size(keys, 1)
    if isequal(keys(i, :), key)
        idx = i;
        break
    end
end
if isempty(idx)
    keys = [keys; key]; %#ok<AGROW>
    vals{end + 1} = value;
    if size(keys, 1) > 24
        keys = keys(end - 23:end, :);
        vals = vals(end - 23:end);
    end
else
    vals{idx} = value;
end
rgb = value;

end
