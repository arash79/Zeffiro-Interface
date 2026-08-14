function [y_vals, plot_mode] = zef_dtw_max_scaling(time_series)
%ZEF_DTW_MAX_SCALING  Pairwise DTW after dividing by the series max.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: DTW, max scaling
%   Function. time_series./max then nested dtw. plot_mode=2.

time_series = time_series./max(time_series);
y_vals = zeros(size(time_series,1), size(time_series,1));
for i = 1 : size(time_series,1)
    for j = 1 : size(time_series,1)
        y_vals(i,j) = dtw(time_series(i,:),time_series(j,:));
    end
end

plot_mode = 2;
