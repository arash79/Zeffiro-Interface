function zef = zeffiro_interface_dynamical_plot_queue(zef)
%ZEFFIRO_INTERFACE_DYNAMICAL_PLOT_QUEUE  Open Multi tools → Dynamical plot queue.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   INI callback in profile/*/zeffiro_plugins.ini. Opens the queue editor
%   via zef_tool_start → zef_dpq_window. The window only edits
%   zef.dynamical_plot_queue_table; playback is zef_plot_dpq
%   ('static'|'dynamical') from visualization.
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
