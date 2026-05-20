% --- Zeffiro documentation header ---
% if isequal(zef — If isequal(zef.
%
% Purpose:
%   If isequal(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_menu_lock_transforms_on (read)
%   zef.h_transform_table (read)
%   zef.lock_transforms_on (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isequal(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if isequal(zef.lock_transforms_on,0)
    zef.h_transform_table.ColumnEditable = logical(ones(1,size(zef.h_transform_table.Data,2)));
    zef.h_menu_lock_transforms_on.Text = 'Toggle ''On'' unlocked';
    zef.h_menu_lock_transforms_on.ForegroundColor = [0 0 0];
elseif isequal(zef.lock_transforms_on,1)
    zef.h_transform_table.ColumnEditable = logical(zeros(1,size(zef.h_transform_table.Data,2)));
    zef.h_menu_lock_transforms_on.Text = 'Toggle ''On'' locked';
    zef.h_menu_lock_transforms_on.ForegroundColor = [1 0 0];
end
