function [y_vals, plot_mode] = zef_mean_energy_no_scaling(time_series)
%ZEF_MEAN_ENERGY_NO_SCALING  Std after mean-scaling (filename is not the formula).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Mean scale then STD (file name: mean energy, no scaling)
%   Function. Divides by mean(time_series) then std(time_series'). plot_mode=1.

time_series = time_series./mean(time_series);
y_vals = std(time_series');

plot_mode = 1;
