function [y_vals, plot_mode] = zef_corr_no_scaling(time_series)
%ZEF_CORR_NO_SCALING  Pairwise corr (no extra scale).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Correlation, no scaling
%   Function. corr(time_series'); NaN -> 1. plot_mode=2.

y_vals = corr(time_series');
y_vals(find(isnan(y_vals))) = 1;

plot_mode = 2;
