function L_ind = zef_blocked_source_index(n_loc, source_direction_mode)
%ZEF_BLOCKED_SOURCE_INDEX  Location → blocked lead-field column indices.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   L_ind = zef_blocked_source_index(n_loc, source_direction_mode)
%
%   After zef_processLeadfields, plugin L is blocked: x-block, y-block,
%   z-block, each of length n_loc = n_interp. Row k of L_ind is the
%   columns of location k.
%
%   Modes 1 and 2: n_loc × 3, row k is [k, k+n_loc, k+2*n_loc].
%   Mode 3: n_loc × 1, row k is k.
%
%   n_loc is the number of interpolation nodes (n_interp), not
%   length(unexpanded s_ind_1)/3. The unexpanded unique node list has
%   length n_interp already; dividing by 3 scanned only one third of the
%   sources (RAP_MUSIC_iteration before this helper).
%
%   See also zef_processLeadfields, zef_rap_music_scan.

if nargin < 2 || isempty(source_direction_mode)
    source_direction_mode = 1;
end
n_loc = double(n_loc);
if ~isscalar(n_loc) || n_loc < 1 || n_loc ~= floor(n_loc)
    error('zef:BlockedSourceIndex:BadLocationCount', ...
        'n_loc must be a positive integer (n_interp); got %s.', mat2str(n_loc));
end

if ismember(source_direction_mode, [1, 2])
    cols = (1:n_loc).';
    L_ind = [cols, n_loc + cols, 2 * n_loc + cols];
elseif source_direction_mode == 3
    L_ind = (1:n_loc).';
else
    error('zef:BlockedSourceIndex:UnsupportedDirectionMode', ...
        'source_direction_mode %g is not 1, 2, or 3.', source_direction_mode);
end

end
