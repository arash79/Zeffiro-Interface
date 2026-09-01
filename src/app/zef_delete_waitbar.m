function zef_delete_waitbar
%ZEF_DELETE_WAITBAR  Delete all Zeffiro waitbar figures.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds figures that have dynamic property ZefWaitbarStartTime, clears
%   CloseRequestFcn / DeleteFcn, and deletes them. Errors during delete
%   are swallowed so teardown (zef_close_all) cannot fail because of a
%   stale waitbar.
%
%   See also zef_waitbar, zef_close_waitbar, zef_close_all.

h_waitbar = findall(groot, '-property', 'ZefWaitbarStartTime');
if isempty(h_waitbar)
    tagged = findall(groot, 'Tag', 'progress_bar');
    h_waitbar = tagged;
end
if isempty(h_waitbar)
    return
end
try
    set(h_waitbar, 'CloseRequestFcn', '');
    set(h_waitbar, 'DeleteFcn', '');
    delete(h_waitbar);
catch
end

end
