function zef_close_waitbar(h)
%ZEF_CLOSE_WAITBAR  Close a Zeffiro waitbar without throwing on a stale handle.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Uses close() so zef_waitbar nest counting runs: a nested caller only
%   drops the nest count and the parent pipeline keeps a valid handle.
%   delete() bypasses that contract and is reserved for zef_delete_waitbar.
%   Empty, invalid, or already-deleted handles are ignored so onCleanup
%   teardown cannot raise "Invalid figure handle".
%
%   zef_close_waitbar(h)
%
%   See also zef_waitbar, zef_delete_waitbar.

try
    if nargin >= 1 && ~isempty(h) && isvalid(h)
        close(h);
    end
catch
end

end
