function [y_vals, plot_mode] = zef_max_energy_no_scaling(time_series)
%ZEF_MAX_ENERGY_NO_SCALING  Max over time (no extra scale).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Description: Maximum energy, no scaling
%   Function. y_vals = max(time_series,[],2). plot_mode=1.

y_vals = max(time_series,[],2);

plot_mode = 1;
