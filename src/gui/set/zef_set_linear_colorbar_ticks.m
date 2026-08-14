function zef_set_linear_colorbar_ticks(zef,n_ticks,n_digits,max_val)
%ZEF_SET_LINEAR_COLORBAR_TICKS  Label a dB colorbar with linear amplitude ticks.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Finds Tag='rightColorbar' on zef.h_zeffiro (created by
%   zef_plot_volume when inv_scale==1). Sets n_ticks evenly in Limits,
%   then TickLabels = round(max_val * 10^((tick-Limits(2))/20), n_digits).
%   The /20 matches the 20*log10 reconstruction scaling in zef_plot_volume.
%
%   See also zef_plot_volume.
h_c = findobj(zef.h_zeffiro.Children,'Tag','rightColorbar');

h_c.Ticks = linspace(h_c.Limits(1),h_c.Limits(2),n_ticks);
% Invert 20*log10 scaling used when zef.inv_scale==1 in zef_plot_volume.
TicksLabels = round(max_val.*10.^((h_c.Ticks - h_c.Limits(2))./20),n_digits);
h_c.TickLabels = cellstr(num2str(TicksLabels(:)));


end
