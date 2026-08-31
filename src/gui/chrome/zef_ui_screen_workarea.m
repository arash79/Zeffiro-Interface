function work = zef_ui_screen_workarea(ref)
%ZEF_UI_SCREEN_WORKAREA  Usable pixel rectangle of the monitor under ref.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   MATLAB ScreenSize / MonitorPositions include the full display. This
%   helper subtracts a thin desktop inset so title bars and OS docks stay
%   reachable. ref may be a figure, a [x y w h] vector, or omitted.
%
%   work = zef_ui_screen_workarea
%   work = zef_ui_screen_workarea(h)
%   work = zef_ui_screen_workarea(pos)
%
%   See also zef_ui_clamp_position, zef_ui_place_window.

mon = get(groot, 'ScreenSize');
try
    mons = get(groot, 'MonitorPositions');
catch
    mons = mon;
end
if isempty(mons)
    mons = mon;
end

pos = [];
if nargin >= 1 && ~isempty(ref)
    if isnumeric(ref)
        pos = double(ref(:)');
    elseif isgraphics(ref) && isvalid(ref)
        try
            orig = ref.Units;
            ref.Units = 'pixels';
            pos = double(ref.Position);
            ref.Units = orig;
        catch
            pos = [];
        end
    end
end

if numel(pos) >= 2 && size(mons, 1) > 1
    cx = pos(1);
    cy = pos(2);
    if numel(pos) >= 4
        cx = pos(1) + pos(3) / 2;
        cy = pos(2) + pos(4) / 2;
    end
    best = 1;
    best_d = inf;
    for i = 1:size(mons, 1)
        m = mons(i, :);
        if cx >= m(1) && cx <= m(1) + m(3) && cy >= m(2) && cy <= m(2) + m(4)
            mon = m;
            best = 0;
            break
        end
        mx = m(1) + m(3) / 2;
        my = m(2) + m(4) / 2;
        d = (cx - mx) ^ 2 + (cy - my) ^ 2;
        if d < best_d
            best_d = d;
            best = i;
        end
    end
    if best > 0
        mon = mons(best, :);
    end
elseif size(mons, 1) >= 1
    mon = mons(1, :);
end

inset_x = 8;
inset_bottom = 8;
inset_top = 28;
work = [mon(1) + inset_x, ...
    mon(2) + inset_bottom, ...
    max(160, mon(3) - 2 * inset_x), ...
    max(120, mon(4) - inset_bottom - inset_top)];

end
