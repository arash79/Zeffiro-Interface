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
%   'Stopped'. When off, clears that flag and restores the Stop label.
%
%   See also zef_play_cdata, zef_figure_tool.

on = false;
try
    on = logical(src.Value);
catch
end
theme = [];
try
    theme = zef_ui_theme();
catch
end
if on
    evalin('base', 'zef.stop_movie=1;');
    lab = 'Stopped';
    fg = [0.720 0.220 0.220];
    try
        fg = theme.color.danger;
    catch
    end
else
    evalin('base', 'zef.stop_movie=0;');
    lab = 'Stop';
    fg = [0.145 0.175 0.210];
    try
        fg = theme.color.text;
    catch
    end
end
try
    src.ForegroundColor = fg;
    src.String = lab;
catch
end
try
    setappdata(src, 'ZefButtonLabel', lab);
catch
end
try
    cap = findall(src.Parent, 'Tag', [char(src.Tag) '_cap']);
    if ~isempty(cap)
        cap(1).String = lab;
        cap(1).ForegroundColor = fg;
    end
catch
end
try
    if on
        zef_ui_interact(src, 'paint', 'press');
    else
        zef_ui_interact(src, 'paint', 'idle');
    end
catch
end
