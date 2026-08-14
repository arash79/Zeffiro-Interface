function [y_vals, plot_mode] = zef_max_energy_mean_scaling(time_series)
%ZEF_MAX_ENERGY_MEAN_SCALING  Mean over time after dividing by the series mean.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Maximum energy, mean scaling
%   Function. Parcellation tool Plot list (help Description:).
%   time_series./mean(time_series) then mean(...,2). plot_mode=1.

time_series = time_series./mean(time_series);
y_vals = mean(time_series,2);

plot_mode = 1;
