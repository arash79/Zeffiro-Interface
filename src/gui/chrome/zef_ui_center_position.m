function pos = zef_ui_center_position(pos, ref)
%ZEF_UI_CENTER_POSITION  Center [x y w h] on a parent rectangle or work area.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Size is unchanged. Call zef_ui_clamp_position afterwards so the
%   centred window still fits the monitor.
%
%   pos = zef_ui_center_position(pos)
%   pos = zef_ui_center_position(pos, parent_pos)
%   pos = zef_ui_center_position(pos, parent_figure)
%
%   See also zef_ui_clamp_position, zef_ui_place_window.

if nargin < 1 || isempty(pos) || numel(pos) < 4
    return
end
pos = double(pos(1:4));
if nargin < 2 || isempty(ref)
    ref = zef_ui_screen_workarea(pos);
elseif isgraphics(ref)
    try
        orig = ref.Units;
        ref.Units = 'pixels';
        rp = double(ref.Position);
        ref.Units = orig;
        ref = rp;
    catch
        ref = zef_ui_screen_workarea(pos);
    end
end
ref = double(ref(1:4));
pos(1) = ref(1) + (ref(3) - pos(3)) / 2;
pos(2) = ref(2) + (ref(4) - pos(4)) / 2;

end
