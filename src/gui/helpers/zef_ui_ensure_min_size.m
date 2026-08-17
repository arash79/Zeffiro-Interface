function zef_ui_ensure_min_size(h, min_w, min_h)
%ZEF_UI_ENSURE_MIN_SIZE  Grow a figure if it is smaller than the theme minimum.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_ui_ensure_min_size(h, min_w, min_h)

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin < 2 || isempty(min_w)
    min_w = 420;
end
if nargin < 3 || isempty(min_h)
    min_h = 360;
end
try
    orig = h.Units;
    h.Units = 'pixels';
    pos = h.Position;
    pos(3) = max(pos(3), min_w);
    pos(4) = max(pos(4), min_h);
    h.Position = pos;
    h.Units = orig;
catch
end

end
