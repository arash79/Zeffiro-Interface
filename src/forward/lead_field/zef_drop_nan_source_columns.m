function [L, positions, directions] = zef_drop_nan_source_columns(L, positions, directions)
%ZEF_DROP_NAN_SOURCE_COLUMNS  Drop sources whose lead-field columns are NaN.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, positions, directions] = zef_drop_nan_source_columns(L, positions, directions)
%
%   zef.L is stored interleaved (xyzxyz…) when there are three components
%   per location. Dropping only the NaN columns, or only the x-slice
%   1:3:end, desynchronises L from source_positions. A triplet is kept
%   only when all three columns are finite; scalar (mode-3) columns are
%   dropped one-for-one.
%
%   See also zef_source_interpolation.

if nargin < 3
    directions = [];
end
if nargin < 2
    positions = [];
end
if isempty(L)
    return
end

col_ok = ~isnan(sum(abs(L), 1));
n_pos = size(positions, 1);
n_dir = size(directions, 1);
n_col = size(L, 2);

if n_pos > 0 && n_col == 3 * n_pos
    triplet_ok = col_ok(1:3:end) & col_ok(2:3:end) & col_ok(3:3:end);
    keep = repelem(triplet_ok, 3);
    L = L(:, keep);
    positions = positions(triplet_ok, :);
    if n_dir == n_pos
        directions = directions(triplet_ok, :);
    elseif n_dir == n_col
        directions = directions(keep, :);
    end
elseif n_pos > 0 && n_col == n_pos
    L = L(:, col_ok);
    positions = positions(col_ok, :);
    if n_dir == n_pos
        directions = directions(col_ok, :);
    end
else
    L = L(:, col_ok);
    if n_dir == n_col
        directions = directions(col_ok, :);
    end
end

end
