function [y_vals, plot_mode] = zef_cov_mean_scaling(time_series)
%ZEF_COV_MEAN_SCALING  Pairwise covariance after dividing by the series mean.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Covariance, mean scaling
%   Function. time_series./mean then cov(time_series'). plot_mode=2.

time_series = time_series./mean(time_series);
y_vals = cov(time_series');

plot_mode = 2;
