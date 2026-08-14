function [y_vals, plot_mode] = zef_std_no_scaling(time_series)
%ZEF_STD_NO_SCALING  Correlation after mean-scaling (not STD).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Mean scale then correlation (file name: std, no scaling)
%   Function. Divides by mean then corr(time_series'); NaN -> 1. plot_mode=2.

time_series = time_series./mean(time_series);
y_vals = corr(time_series');
y_vals(find(isnan(y_vals))) = 1;

plot_mode = 2;
