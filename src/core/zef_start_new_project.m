%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if zef — If zef.
%
% Purpose:
%   If zef.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Calls (project):
%   zef_delete_all_compartments
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if zef.use_display
    zef = zeffiro_interface('zeffiro_restart', true);
else
    zef = zeffiro_interface('zeffiro_restart', true, 'start_mode','nodisplay');
end

zef = zef_delete_all_compartments(zef);
