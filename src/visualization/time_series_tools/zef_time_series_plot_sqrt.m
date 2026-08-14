function [y_vals, plot_mode] = zef_time_series_plot_sqrt(time_series)
%ZEF_TIME_SERIES_PLOT_SQRT  Sqrt of max-scaled ROI time courses.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Time series, sqrt of max scaling
%   Function. y_vals = sqrt(time_series/max(time_series(:))). plot_mode=3.

y_vals = sqrt(time_series/max(time_series(:)));

plot_mode = 3;
