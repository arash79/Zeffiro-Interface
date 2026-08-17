function zef_ui_apply_size(h, def_w, def_h, min_w, min_h)
%ZEF_UI_APPLY_SIZE  Set a window's default size and bind a resize floor.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Caps the default to 82% of the screen so tools do not open larger
%   than the display. Minimum sizes are smaller than the default so the
%   user can shrink the window; SizeChangedFcn then clamps and the
%   layout managers keep the structure.
%
%   zef_ui_apply_size(h, def_w, def_h)
%   zef_ui_apply_size(h, def_w, def_h, min_w, min_h)
%
%   See also zef_ui_bind_min_size, zef_ui_ensure_min_size.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin < 4 || isempty(min_w)
    min_w = max(320, round(0.72 * def_w));
end
if nargin < 5 || isempty(min_h)
    min_h = max(240, round(0.72 * def_h));
end

try
    orig = h.Units;
    h.Units = 'pixels';
    scr = get(groot, 'ScreenSize');
    max_w = max(min_w, round(0.82 * scr(3)));
    max_h = max(min_h, round(0.82 * scr(4)));
    w = min(max(min_w, def_w), max_w);
    ht = min(max(min_h, def_h), max_h);
    pos = h.Position;
    pos(3) = w;
    pos(4) = ht;
    if pos(1) + pos(3) > scr(1) + scr(3)
        pos(1) = max(scr(1), scr(1) + scr(3) - pos(3) - 8);
    end
    if pos(2) + pos(4) > scr(2) + scr(4)
        pos(2) = max(scr(2), scr(2) + scr(4) - pos(4) - 28);
    end
    h.Position = pos;
    h.Units = orig;
catch
end

zef_ui_bind_min_size(h, min_w, min_h);

end
