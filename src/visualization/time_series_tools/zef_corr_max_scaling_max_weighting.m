function [y_vals, plot_mode] = zef_corr_max_scaling_max_weighting(time_series)
%ZEF_CORR_MAX_SCALING_MAX_WEIGHTING  Covariance after mean-scaling (not corr).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Mean scale then covariance (file name: corr max weighting)
%   Function. time_series./mean then cov(time_series'). plot_mode=2.

time_series = time_series./mean(time_series);
y_vals = cov(time_series');

plot_mode = 2;
