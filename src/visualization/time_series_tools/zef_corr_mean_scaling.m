function [y_vals, plot_mode] = zef_corr_mean_scaling(time_series)
%ZEF_CORR_MEAN_SCALING  Pairwise corr after dividing by the series mean.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Correlation, mean scaling
%   Function. time_series./mean then corr(time_series'); NaN -> 1. plot_mode=2.

time_series = time_series./mean(time_series);
y_vals = corr(time_series');
y_vals(find(isnan(y_vals))) = 1;

plot_mode = 2;
