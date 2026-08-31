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
%   background so a full-size inactive uicontrol can fake a card.
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
    borderc = [0.82 0.85 0.86];
end
if nargin < 6 || isempty(outerc)
    outerc = [0.965 0.970 0.974];
end

w = max(8, round(double(w(1))));
h = max(8, round(double(h(1))));
r = max(3, min(round(double(radius(1))), floor(min(w, h) / 2) - 1));
fillc = reshape(double(fillc(1:3)), 1, 1, 3);
borderc = reshape(double(borderc(1:3)), 1, 1, 3);
outerc = reshape(double(outerc(1:3)), 1, 1, 3);

[x, y] = meshgrid(single(1:w), single(1:h));
px = abs(x - 0.5 - w / 2) - (w / 2 - r);
py = abs(y - 0.5 - h / 2) - (h / 2 - r);
d = hypot(max(px, 0), max(py, 0)) + min(max(px, py), 0) - r;

rgb = repmat(outerc, h, w);
inside = d < -0.75;
for k = 1:3
    ch = rgb(:, :, k);
    ch(inside) = fillc(k);
    rgb(:, :, k) = ch;
end

edge = ~inside & (d < 1.15);
if any(edge(:))
    t = double(d(edge));
    a_fill = max(0, min(1, (-t) / 0.75));
    a_outer = max(0, min(1, (t - 0.15) / 1.0));
    a_border = max(0, 1 - a_fill - a_outer);
    s = a_fill + a_border + a_outer;
    a_fill = a_fill ./ s;
    a_border = a_border ./ s;
    a_outer = a_outer ./ s;
    for k = 1:3
        ch = rgb(:, :, k);
        ev = ch(edge);
        ev = fillc(k) * a_fill + borderc(k) * a_border + outerc(k) * a_outer;
        ch(edge) = ev;
        rgb(:, :, k) = ch;
    end
end
rgb = max(0, min(1, rgb));

end
