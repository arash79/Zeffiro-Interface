%ZEF_TOGGLE_LOCK_ON  Sync compartment-table **On** editability with zef.lock_on.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click Compartments → **Lock on** (h_menu_lock_on). MenuSelectedFcn
%   first flips zef.lock_on = abs(zef.lock_on-1), then runs this script.
%   App Designer label starts as 'Lock on'; this script rewrites it.
%
%   Script. Expects zef in the caller.
%
%     lock_on == 0: column 2 (**On**) editable; menu text
%       "Toggle 'On' unlocked", black.
%     lock_on == 1: column 2 not editable; menu text
%       "Toggle 'On' locked", red. **Toggle on** in zef_menu_tool also
%       no-ops while lock_on is true.
%
%   See also zef_delete_compartment, zef_add_compartment.

if isequal(zef.lock_on,0)
    zef.h_compartment_table.ColumnEditable(2) = logical(1);
    zef.h_menu_lock_on.Text = 'Toggle ''On'' unlocked';
    zef.h_menu_lock_on.ForegroundColor = [0 0 0];
elseif isequal(zef.lock_on,1)
    zef.h_compartment_table.ColumnEditable(2) = logical(0);
    zef.h_menu_lock_on.Text = 'Toggle ''On'' locked';
    zef.h_menu_lock_on.ForegroundColor = [1 0 0];
end
