function [y_vals, plot_mode] = zef_cov_no_scaling(time_series)
%ZEF_COV_NO_SCALING  Pairwise DTW matrix (not covariance).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: DTW, no scaling (file name: covariance, no scaling)
%   Function. Nested dtw(time_series(i,:), time_series(j,:)). plot_mode=2.

y_vals = zeros(size(time_series,1), size(time_series,1));
for i = 1 : size(time_series,1)
    for j = 1 : size(time_series,1)
        y_vals(i,j) = dtw(time_series(i,:),time_series(j,:));
    end
end

plot_mode = 2;
