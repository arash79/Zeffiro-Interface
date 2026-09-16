function groups = zef_nearest_neighbour_groups(p_nearest_neighbour_inds, n_sources)
%ZEF_NEAREST_NEIGHBOUR_GROUPS  Invert nearest-source labels into index lists.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   groups = zef_nearest_neighbour_groups(p_nn, n_sources)
%
%   groups{i} is the sorted list of tetrahedra whose nearest interpolation
%   source is i. Equivalent to find(p_nn == i) per source, built once with
%   accumarray. Empty p_nn returns {}. Unused sources get zeros(0,1).
%
%   See also zef_hdiv_interpolation, zef_whitney_interpolation.

if nargin < 1 || isempty(p_nearest_neighbour_inds)
    groups = {};
    return
end
if nargin < 2 || isempty(n_sources)
    n_sources = max(p_nearest_neighbour_inds(:));
end
groups = accumarray( ...
    p_nearest_neighbour_inds(:), ...
    (1:numel(p_nearest_neighbour_inds))', ...
    [n_sources, 1], ...
    @(x) {x}, ...
    {zeros(0, 1)});

end
