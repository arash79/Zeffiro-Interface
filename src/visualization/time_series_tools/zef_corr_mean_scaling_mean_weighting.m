function [y_vals, plot_mode] = zef_corr_mean_scaling_mean_weighting(time_series)
%ZEF_CORR_MEAN_SCALING_MEAN_WEIGHTING  Weighted corr after max-scaling.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Correlation, max scale, D*corr*D
%   Function. Divides by max (not mean), corr, then D*y*D with
%   D=diag(sqrt(max(...,[],2))). plot_mode=2.

time_series = time_series./max(time_series);
D = diag(sqrt(max(time_series,[],2)));
D = D./max(D(:));
y_vals = corr(time_series');
y_vals(find(isnan(y_vals))) = 1;
y_vals = D*y_vals*D;

plot_mode = 2;
