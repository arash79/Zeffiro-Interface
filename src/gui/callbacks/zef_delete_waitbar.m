% --- Zeffiro documentation header ---
% function zef_delete_waitbar — Function zef delete waitbar.
%
% Purpose:
%   Function zef delete waitbar.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Calls (project):
%   zef_delete_waitbar
%
% Side effects:
%   - filesystem I/O
%   - waitbar progress UI
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_delete_waitbar` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_delete_waitbar


h_waitbar = findall(groot,'-property','ZefWaitbarStartTime');
if isempty(h_waitbar)
    return;
end
try
    set(h_waitbar,'DeleteFcn','');
    delete(h_waitbar);
catch
    % Ignore errors so caller can rely on this not throwing
end

end
