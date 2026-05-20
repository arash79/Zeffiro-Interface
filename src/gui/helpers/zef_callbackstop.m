% --- Zeffiro documentation header ---
% function []=zef_callbackstop(src,~) — GUI callback for function []=zefstop(src,~) actions.
%
% Purpose:
%   GUI callback for function []=zefstop(src,~) actions.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.stop_movie (read, write)
%
% Calls (project):
%   zef_callbackstop
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `function []=zef_callbackstop(src,~)` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function []=zef_callbackstop(src,~)


if ~src.Value
    evalin('base',[ num2str(src.Value),';'])
    set(src,'foregroundcolor',[0 0 0]);
    set(src,'string','Stop');
else
    evalin('base','zef.stop_movie=1;') ;
    set(src,'foregroundcolor',[1 0 0]);
    set(src,'string','Stopped');
end
