function [y_vals, plot_mode] = zef_corr_max_scaling(time_series)
%ZEF_CORR_MAX_SCALING  Pairwise corr after dividing by the series max.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Correlation, max scaling
%   Function. time_series./max then corr(time_series'); NaN -> 1. plot_mode=2.

time_series = time_series./max(time_series);
y_vals = corr(time_series');
y_vals(find(isnan(y_vals))) = 1;

plot_mode = 2;
