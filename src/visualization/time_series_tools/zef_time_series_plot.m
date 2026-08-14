function [y_vals, plot_mode] = zef_time_series_plot(time_series)
%ZEF_TIME_SERIES_PLOT  ROI time courses scaled by global max.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Time series, max scaling
%   Function. y_vals = time_series/max(time_series(:)). plot_mode=3.

y_vals = time_series/max(time_series(:));

plot_mode = 3;
