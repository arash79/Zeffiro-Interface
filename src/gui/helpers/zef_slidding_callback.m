% --- Zeffiro documentation header ---
% function []=zef_slidding_callback — GUI callback for function []=slidding actions.
%
% Purpose:
%   GUI callback for function []=slidding actions.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.frame_start (read, write)
%   zef.frame_step (read)
%   zef.frame_stop (read, write)
%   zef.h_slider (read)
%   zef.store_cdata (read)
%   zef.visualization_type (read)
%
% Calls (project):
%   zef_play_cdata
%   zef_slidding_callback
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `function []=zef_slidding_callback` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function []=zef_slidding_callback


if evalin('base','zef.store_cdata')
    zef_play_cdata(1,get(gcbo,'Value'));
else
    l_r = evalin('base','(zef.frame_stop-zef.frame_start+zef.frame_step)/zef.frame_step;');
    evalin('base',['zef.frame_start=' ,num2str(ceil(l_r*evalin('base','zef.h_slider.Value'))),';']);
    evalin('base',['zef.frame_stop=' ,num2str(ceil(l_r*evalin('base','zef.h_slider.Value'))),';']);
    if isequal(evalin('base','zef.visualization_type'),2)
        evalin('base','zef_visualize_volume');
    elseif isequal(evalin('base','zef.visualization_type'),3)
        evalin('base','zef_visualize_surfaces');
    end

end

end
