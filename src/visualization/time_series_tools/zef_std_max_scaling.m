function [y_vals, plot_mode] = zef_std_no_scaling(time_series)
%ZEF_STD_NO_SCALING  Std after max-scaling (this file is zef_std_max_scaling.m).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Max scale then STD
%   Function. MATLAB calls this file by filename zef_std_max_scaling.
%   Inner function name is zef_std_no_scaling. plot_mode=1.

time_series = time_series./max(time_series);
y_vals = std(time_series');

plot_mode = 1;
