function n = source_count(payload)
%SOURCE_COUNT  Number of sources implied by positions or lead-field columns.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    if ~isempty(payload.source_positions)
        n = size(payload.source_positions, 1);
        return
    end
    if ~isempty(payload.L) && mod(size(payload.L, 2), 3) == 0
        n = size(payload.L, 2) / 3;
        return
    end
    n = size(payload.L, 2);
end
