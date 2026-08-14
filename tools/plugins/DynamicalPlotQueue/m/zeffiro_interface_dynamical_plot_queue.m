function zef = zef_dpq_start(zef)
%ZEF_DPQ_START  Open Multi tools → Dynamical plot queue.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   File zeffiro_interface_dynamical_plot_queue.m (the INI callback name
%   in profile/*/zeffiro_plugins.ini). The in-file function is
%   zef_dpq_start. Opens the queue editor via zef_tool_start →
%   zef_dpq_window. The window only edits zef.dynamical_plot_queue_table;
%   playback is zef_plot_dpq('static'|'dynamical') from visualization.
%
%   zef = zeffiro_interface_dynamical_plot_queue(zef)
%   zef = zeffiro_interface_dynamical_plot_queue
%
%   No-arg form reads zef from base. Zero outputs assignin back to base.
%
%   See also zef_plot_dpq, zef_dpq_window.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_dpq_window',1/2,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
