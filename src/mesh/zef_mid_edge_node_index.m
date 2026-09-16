function col4 = zef_mid_edge_node_index(edge_ind)
%ZEF_MID_EDGE_NODE_INDEX  Number mid-edge nodes for a 8-to-1 tet split.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   col4 = zef_mid_edge_node_index(edge_ind)
%
%   edge_ind rows are [n1 n2 tet_id placeholder flag local_edge], already
%   sorted by [n1 n2 flag]. Flag 1 means the tet is fully marked and the
%   edge is split. Returns a 1..N index per distinct flagged edge, reused
%   on hanging-edge rows that share that pair. Unflagged-only edges stay 0.
%
%   See also zef_mesh_refinement, zef_refinement_step.

col4 = zeros(size(edge_ind, 1), 1);
is_full = edge_ind(:, 5) == 1;
if ~any(is_full)
    return
end
[unique_full, ~] = unique(edge_ind(is_full, 1:2), 'rows', 'stable');
[tf, loc] = ismember(edge_ind(:, 1:2), unique_full, 'rows');
col4(tf) = loc(tf);

end
