function [y_vals, plot_mode] = zef_std_max_scaling(time_series)
%ZEF_STD_MAX_SCALING  Std after max-scaling.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Max scale then STD
%   Function. time_series./max(time_series) then std(time_series'). plot_mode=1.

time_series = time_series./max(time_series);
y_vals = std(time_series');

plot_mode = 1;
