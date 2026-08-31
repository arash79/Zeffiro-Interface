function pos = zef_ui_clamp_position(pos, work)
%ZEF_UI_CLAMP_POSITION  Fit [x y w h] inside a usable screen rectangle.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Shrinks the window when it is larger than the work area, then clamps
%   the origin so every edge stays inside. Does not require a live figure.
%
%   pos = zef_ui_clamp_position(pos)
%   pos = zef_ui_clamp_position(pos, work)
%
%   See also zef_ui_screen_workarea, zef_ui_place_window.

if nargin < 1 || isempty(pos) || numel(pos) < 4
    return
end
pos = double(pos(1:4));
if any(~isfinite(pos))
    return
end
if nargin < 2 || isempty(work) || numel(work) < 4
    work = zef_ui_screen_workarea(pos);
end
work = double(work(1:4));
pos(3) = min(pos(3), work(3));
pos(4) = min(pos(4), work(4));
pos(3) = max(120, pos(3));
pos(4) = max(80, pos(4));
max_x = work(1) + work(3) - pos(3);
max_y = work(2) + work(4) - pos(4);
if max_x < work(1)
    max_x = work(1);
end
if max_y < work(2)
    max_y = work(2);
end
pos(1) = min(max(work(1), pos(1)), max_x);
pos(2) = min(max(work(2), pos(2)), max_y);

end
