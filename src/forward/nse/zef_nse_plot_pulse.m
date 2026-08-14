function zef_nse_plot_pulse(zef,nse_field,type)



%ZEF_NSE_PLOT_PULSE  Plot the NSE pulse on zef.h_axes1 (NSE tool).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   type 'single_pulse' (default): one cycle_length. 'full_data':
%   0:time_step_length:time_length. Calls zef_nse_signal_pulse.
%
%   zef_nse_plot_pulse(zef, nse_field, type)
%
%   See also zef_nse_signal_pulse.

if nargin < 3
    type = 'single_pulse';
end

axes(zef.h_axes1);
cla(zef.h_axes1);

if isequal(type,'single_pulse')
    t = nse_field.cycle_length*[0:0.001:1];
elseif isequal(type,'full_data')
    t = [0:nse_field.time_step_length:nse_field.time_length];
end
y = zef_nse_signal_pulse(t,nse_field,256);

plot(zef.h_axes1,t,y,'k');
zef.h_axes1.XLim = [min(t) max(t)];
zef.h_axes1.YLim = [min(y) 1.05*max(abs(y))];
zef.h_axes1.XGrid = 'on';
zef.h_axes1.YGrid = 'on';

end
