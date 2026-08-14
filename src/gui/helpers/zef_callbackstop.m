function []=zef_callbackstop(src,~)
%ZEF_CALLBACKSTOP  Figure-tool **Stop** togglebutton callback.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_figure_tool sets h_stop_movie Callback to @zef_callbackstop.
%   When the toggle is on (Value true), writes zef.stop_movie=1 in the
%   base workspace (zef_play_cdata aborts on that flag) and shows red
%   'Stopped'. When off, evalin 0; in base and restores black 'Stop'.
%
%   See also zef_play_cdata, zef_figure_tool.


if ~src.Value
    evalin('base',[ num2str(src.Value),';'])
    set(src,'foregroundcolor',[0 0 0]);
    set(src,'string','Stop');
else
    evalin('base','zef.stop_movie=1;') ;
    set(src,'foregroundcolor',[1 0 0]);
    set(src,'string','Stopped');
end
