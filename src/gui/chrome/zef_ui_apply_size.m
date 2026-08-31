function zef_ui_apply_size(h, def_w, def_h, min_w, min_h)
%ZEF_UI_APPLY_SIZE  Set a window's default size and bind a resize floor.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Caps the default to the usable work area so tools do not open larger
%   than the display. Origin is then clamped on all four sides. Minimum
%   sizes are smaller than the default so the user can shrink the window;
%   SizeChangedFcn then clamps and the layout managers keep the structure.
%
%   zef_ui_apply_size(h, def_w, def_h)
%   zef_ui_apply_size(h, def_w, def_h, min_w, min_h)
%
%   See also zef_ui_bind_min_size, zef_ui_clamp_position.

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
    pos = double(h.Position);
    work = zef_ui_screen_workarea(pos);
    max_w = max(min_w, work(3));
    max_h = max(min_h, work(4));
    w = min(max(min_w, def_w), max_w);
    ht = min(max(min_h, def_h), max_h);
    pos(3) = w;
    pos(4) = ht;
    pos = zef_ui_clamp_position(pos, work);
    h.Position = pos;
    h.Units = orig;
catch
end

zef_ui_bind_min_size(h, min_w, min_h);

end
