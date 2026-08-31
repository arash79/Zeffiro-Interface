function clipped_nodes_ind = zef_clipping_plane(nodes, clipping_plane, varargin)
%ZEF_CLIPPING_PLANE  Keep mesh nodes on one side (or a slab) of a plane.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Tests n·x against a scalar or interval offset. The plane is the cell
%   {nx, ny, nz, d} where n = [nx ny nz] and d is clipping_plane{4}.
%   Nodes satisfy n·x >= d, or d(1) <= n·x <= d(2) when d has two entries.
%   Coordinates are those of the current mesh (typically millimetres in
%   the project frame; this function does not convert units).
%
%   ind = zef_clipping_plane(nodes, clipping_plane)
%   ind = zef_clipping_plane(nodes, clipping_plane, aux_node_ind)
%
%   Inputs
%     nodes           - N-by-3 node coordinates.
%     clipping_plane  - 1-by-4 cell: {nx, ny, nz, d} with d scalar or 1-by-2.
%     aux_node_ind    - optional index subset; result is intersected with it.
%
%   Output
%     clipped_nodes_ind  - linear indices into nodes that pass the test.
%
%   See also zef_visualize_volume.


clipped = 0;
if length(varargin) > 0
    aux_node_ind = varargin{1};
    clipped = 1;
end

if length(clipping_plane{4}) == 1

    if clipped
        clipped_nodes_ind = intersect(aux_node_ind,find(sum(nodes.*repmat([clipping_plane{1} clipping_plane{2} clipping_plane{3}],size(nodes,1),1),2) >= clipping_plane{4}));
    else
        clipped_nodes_ind = find(sum(nodes.*repmat([clipping_plane{1} clipping_plane{2} clipping_plane{3}],size(nodes,1),1),2) >= clipping_plane{4});
    end

elseif length(clipping_plane{4}) == 2

    if clipped
        clipped_nodes_ind = intersect(aux_node_ind,find(sum(nodes.*repmat([clipping_plane{1} clipping_plane{2} clipping_plane{3}],size(nodes,1),1),2) >= clipping_plane{4}(1)));
        clipped_nodes_ind = intersect(clipped_nodes_ind,find(sum(nodes.*repmat([clipping_plane{1} clipping_plane{2} clipping_plane{3}],size(nodes,1),1),2) <= clipping_plane{4}(2)));
    else
        clipped_nodes_ind = find(sum(nodes.*repmat([clipping_plane{1} clipping_plane{2} clipping_plane{3}],size(nodes,1),1),2) >= clipping_plane{4}(1));
        clipped_nodes_ind = intersect(clipped_nodes_ind,find(sum(nodes.*repmat([clipping_plane{1} clipping_plane{2} clipping_plane{3}],size(nodes,1),1),2) <= clipping_plane{4}(2)));
    end

end
