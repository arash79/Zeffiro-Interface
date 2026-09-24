function idx = zef_sensor_draw_indices(visible_list, n)
%ZEF_SENSOR_DRAW_INDICES  Contact rows to draw for one sensor set.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   An empty visibility list is unspecified: every row is drawn. A stored
%   list is applied as written, including a list of all zeros (draw none).
%   The set-level <tag>_visible flag is a separate gate in the plotters.
%
%   idx = zef_sensor_draw_indices(visible_list, n)

if nargin < 2 || isempty(n)
    n = numel(visible_list);
end
n = double(n);
if n < 1
    idx = zeros(0, 1);
    return
end
if isempty(visible_list)
    idx = (1:n)';
    return
end
idx = find(visible_list(:));
idx = idx(idx >= 1 & idx <= n);

end
