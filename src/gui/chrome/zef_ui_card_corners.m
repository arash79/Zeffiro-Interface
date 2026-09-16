function zef_ui_card_corners(h_fig, ~, ~, ~)
%ZEF_UI_CARD_CORNERS  Remove obsolete Figure-workspace corner overlays.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure-workspace rounding is zef_ui_card on zef_shell_card, with tabs /
%   toolbar / figure_view parented inside and inset by cardRadius. Earlier
%   builds painted four 12 px overlays (pushbutton, then uipanel+axes, then
%   uiimage) at the card corners. On R2025a+ figure() is a uifigure: nested
%   axes keep a ~20 px title inset, and overlay widgets show as four
%   rectangles. This helper only deletes leftovers. Do not recreate them.
%
%   zef_ui_card_corners(h_fig, [x y w h], theme, radius)
%
%   See also zef_ui_roundrect, zef_ui_card.

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
try
    rmappdata(h_fig, 'ZefCardRect');
catch
end
try
    if isappdata(h_fig, 'ZefCardCornersCleared') ...
            && isequal(getappdata(h_fig, 'ZefCardCornersCleared'), true)
        return
    end
catch
end
found = [findall(h_fig, '-regexp', 'Tag', '^zef_card_c_'); ...
    findall(h_fig, '-regexp', 'Tag', '^zef_card_e_')];
for i = 1:numel(found)
    try
        if isvalid(found(i))
            delete(found(i));
        end
    catch
    end
end
try
    setappdata(h_fig, 'ZefCardCornersCleared', true);
catch
end

end
