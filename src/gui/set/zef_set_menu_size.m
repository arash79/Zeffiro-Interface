function zef_set_menu_size(zef,status)
% --- Zeffiro documentation header ---
% zef_set_menu_size — Zef set menu size.
%
% Purpose:
%   Zef set menu size.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   status
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_menu_logo (read)
%   zef.h_zeffiro_menu (read)
%   zef.menu_expanded_size (read)
%
% Calls (project):
%   zef_set_menu_size
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_menu_size(zef, status)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isequal(status,'expanded')

    if isequal(zef.h_zeffiro_menu.Position(4),0)

        zef.h_menu_logo.ImageClickedFcn = 'zef_set_menu_size(zef,''minimized'');';
        zef.h_zeffiro_menu.Position(4) = zef.menu_expanded_size;
        zef.h_zeffiro_menu.Position(2) = zef.h_zeffiro_menu.Position(2) - zef.menu_expanded_size;
        zef.h_menu_logo.Position(1) = 0.1*zef.h_zeffiro_menu.Position(3);
        zef.h_menu_logo.Position(2) = 0.1*zef.h_zeffiro_menu.Position(4);
        zef.h_menu_logo.Position(3) = 0.8*zef.h_zeffiro_menu.Position(3);
        zef.h_menu_logo.Position(4) = 0.8*zef.h_zeffiro_menu.Position(4);

    end

elseif isequal(status,'minimized')

    if zef.h_zeffiro_menu.Position(4) > 0

        zef.h_zeffiro_menu.Position(4) = 0;
        zef.h_zeffiro_menu.Position(2) = zef.h_zeffiro_menu.Position(2) + zef.menu_expanded_size;

    end

end

end
