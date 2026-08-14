function zef_set_timepointline(h_axes)
%ZEF_SET_TIMEPOINTLINE  Vertical time marker on a 2-D time-series axes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Deletes any child Tag='timepointline', draws a gray line
%   at h_axes.CurrentPoint(1) spanning YLim, and sets Title to
%   'Time value = <x>'. Used on butterfly / parcellation time axes, not
%   on Figure-tool h_axes1.
%
%   See also zef_butterfly_plot.
h_line = findobj(h_axes.Children,'Tag','timepointline');
delete(h_line);
h_line = line(h_axes.CurrentPoint([1 1]),[h_axes.YLim]);
h_line.Color = 0.5*[1 1 1];
h_line.Tag = 'timepointline';
h_axes.Title.String = ['Time value = ' num2str(h_axes.CurrentPoint(1))];
h_line.LineWidth = 1;

end
