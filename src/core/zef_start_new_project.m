%ZEF_START_NEW_PROJECT  Restart Zeffiro and delete all compartments.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Calls zeffiro_interface('zeffiro_restart', true), preserving
%   nodisplay when zef.use_display is false, then
%   zef_delete_all_compartments. Used by import-to-new-project and
%   Project → New project from profile / New empty project.
%
%   Workspace
%     zef  - replaced by the restarted session.
%
%   See also zeffiro_interface, zef_delete_all_compartments.


if zef.use_display
    zef = zeffiro_interface('zeffiro_restart', true);
else
    zef = zeffiro_interface('zeffiro_restart', true, 'start_mode','nodisplay');
end

zef = zef_delete_all_compartments(zef);
