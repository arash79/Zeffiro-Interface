function zef_set_menu_size(zef,status)
%ZEF_SET_MENU_SIZE  Expand or collapse the menu-bar window after a MenuSelectedFcn.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. status is 'expanded' or 'minimized'. Historically this used
%   Position(4)==0 as minimized; on some MATLAB/OS builds client height
%   is clamped above 0, so compare against ZefMenuMinHeight instead.
%   Expanded height is zef.menu_expanded_size; the logo ImageClickedFcn
%   toggles minimized. Temporarily clears SizeChangedFcn while moving.
%
%   See also zef_menu_tool, zef_window_manager.

if nargin < 2
    return
end
if ~isfield(zef, 'h_zeffiro_menu') || ~isvalid(zef.h_zeffiro_menu)
    return
end

h_menu = zef.h_zeffiro_menu;
zef_window_manager('standalone', h_menu);

min_h = 0;
if isprop(h_menu, 'ZefMenuMinHeight') && ~isempty(h_menu.ZefMenuMinHeight)
    min_h = h_menu.ZefMenuMinHeight;
end

sc = [];
try
    sc = h_menu.SizeChangedFcn;
    h_menu.SizeChangedFcn = '';
catch
end

current_h = h_menu.Position(4);
is_minimized = current_h <= min_h + 1;

if isequal(status,'expanded')

    if is_minimized
        new_h = zef.menu_expanded_size;
        h_menu.Position(2) = h_menu.Position(2) - (new_h - current_h);
        h_menu.Position(4) = new_h;
        if isfield(zef, 'h_menu_logo') && ~isempty(zef.h_menu_logo) ...
                && isgraphics(zef.h_menu_logo) && isvalid(zef.h_menu_logo)
            if isprop(zef.h_menu_logo, 'ImageClickedFcn')
                zef.h_menu_logo.ImageClickedFcn = 'zef_set_menu_size(zef,''minimized'');';
            end
            if isprop(zef.h_menu_logo, 'Position')
                zef.h_menu_logo.Position(1) = 0.1*h_menu.Position(3);
                zef.h_menu_logo.Position(2) = 0.1*h_menu.Position(4);
                zef.h_menu_logo.Position(3) = 0.8*h_menu.Position(3);
                zef.h_menu_logo.Position(4) = 0.8*h_menu.Position(4);
            end
        end
    end

elseif isequal(status,'minimized')

    if ~is_minimized
        extra = current_h - min_h;
        h_menu.Position(4) = min_h;
        h_menu.Position(2) = h_menu.Position(2) + extra;
    end

end

try
    h_menu.SizeChangedFcn = sc;
catch
end

end
