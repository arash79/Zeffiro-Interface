% --- Zeffiro documentation header ---
% if isequal(zef — If isequal(zef.
%
% Purpose:
%   If isequal(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_compartment_table (read)
%   zef.h_menu_lock_on (read)
%   zef.lock_on (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isequal(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if isequal(zef.lock_on,0)
    zef.h_compartment_table.ColumnEditable(2) = logical(1);
    zef.h_menu_lock_on.Text = 'Toggle ''On'' unlocked';
    zef.h_menu_lock_on.ForegroundColor = [0 0 0];
elseif isequal(zef.lock_on,1)
    zef.h_compartment_table.ColumnEditable(2) = logical(0);
    zef.h_menu_lock_on.Text = 'Toggle ''On'' locked';
    zef.h_menu_lock_on.ForegroundColor = [1 0 0];
end
