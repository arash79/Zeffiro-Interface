function zef_segmentation_tool_toggle(zef,h_button)
%ZEF_SEGMENTATION_TOOL_TOGGLE  Narrow/widen the Segmentation tool window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of **Toggle controls** (h_segmentation_tool_toggle),
%   wired in zef_segmentation_tool. That constructor also sets the
%   button's UserData to 1 the first time it is created. Does not dock
%   to the menu bar (zef_window_manager('dock_menu') is a separate path).
%
%   UserData 1 (initial) is the wide layout: this call multiplies
%   h_zeffiro_window_main.Position(3) by 0.505 and stores UserData 0.
%   UserData 0 is the narrow layout: width is divided by 0.505 and
%   UserData returns to 1. SizeChangedFcn is blanked for the move, then
%   restored with zef_set_size_change_function. warning off/on wraps the
%   resize.
%
%   zef_segmentation_tool_toggle(zef, h_button)
%
%   Inputs
%     zef      - session; uses h_zeffiro_window_main.
%     h_button - the Toggle controls uibutton (UserData 0 or 1).
%
%   See also zef_segmentation_tool, zef_set_position, zef_set_size_change_function.

if isequal(h_button.UserData,1)
    h_button.UserData = 0;
    position_vec = zef.h_zeffiro_window_main.Position;
    position_vec(3) = 0.505*position_vec(3);
else
    h_button.UserData = 1;
    position_vec = zef.h_zeffiro_window_main.Position;
    position_vec(3) = position_vec(3)/0.505;
end

warning off
zef.h_zeffiro_window_main.Position = position_vec;
warning on

end
