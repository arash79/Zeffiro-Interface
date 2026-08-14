%ZEF_TOGGLE_LOCK_TRANSFORMS_ON  Sync transform-table editability with zef.lock_transforms_on.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click Transform → **Lock on** (h_menu_lock_transforms_on).
%   MenuSelectedFcn flips lock_transforms_on then runs this script.
%   **Add transform** / **Delete transform(s)** also no-op while locked.
%
%   Script. Expects zef in the caller.
%
%     lock_transforms_on == 0: every column editable; menu
%       "Toggle 'On' unlocked", black.
%     lock_transforms_on == 1: every column read-only; menu
%       "Toggle 'On' locked", red.
%
%   See also zef_add_transform, zef_delete_transform.

if isequal(zef.lock_transforms_on,0)
    zef.h_transform_table.ColumnEditable = logical(ones(1,size(zef.h_transform_table.Data,2)));
    zef.h_menu_lock_transforms_on.Text = 'Toggle ''On'' unlocked';
    zef.h_menu_lock_transforms_on.ForegroundColor = [0 0 0];
elseif isequal(zef.lock_transforms_on,1)
    zef.h_transform_table.ColumnEditable = logical(zeros(1,size(zef.h_transform_table.Data,2)));
    zef.h_menu_lock_transforms_on.Text = 'Toggle ''On'' locked';
    zef.h_menu_lock_transforms_on.ForegroundColor = [1 0 0];
end
