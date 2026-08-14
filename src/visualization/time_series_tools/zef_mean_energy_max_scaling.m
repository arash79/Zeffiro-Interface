function [y_vals, plot_mode] = zef_mean_energy_max_scaling(time_series)
%ZEF_MEAN_ENERGY_MAX_SCALING  Mean over time after dividing by the series max.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Mean energy, max scaling
%   Function. time_series./max(time_series) then mean(...,2). plot_mode=1.

time_series = time_series./max(time_series);
y_vals = mean(time_series,2);

plot_mode = 1;
