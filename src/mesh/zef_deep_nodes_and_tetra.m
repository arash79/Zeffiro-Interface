function [ ...
    out_deep_nodes, ...
    out_deep_node_inds, ...
    out_deep_tetra, ...
    out_deep_tetra_inds ...
    ] = zef_deep_nodes_and_tetra( ...
    in_nodes, ...
    in_tetra, ...
    in_volume_inds, ...
    in_acceptable_depth_mm ...
    )
%ZEF_DEEP_NODES_AND_TETRA  Nodes/tets of a subvolume farther than a depth from its skin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Restricts in_tetra(in_volume_inds,:) (typically the brain / source
%   compartment), finds that submesh's boundary with zef_surface_mesh, and
%   drops every node within in_acceptable_depth_mm of a boundary node
%   (zef_nearest_points range search, including the boundary nodes
%   themselves). Tets that still have all four vertices in the deep set
%   are returned. zef_lead_field_matrix uses the tet index list as
%   zef.brain_activity_inds.
%
%   [out_deep_nodes, out_deep_node_inds, out_deep_tetra, out_deep_tetra_inds] = ...
%       zef_deep_nodes_and_tetra(in_nodes, in_tetra, in_volume_inds, in_acceptable_depth_mm)
%
%   Inputs
%     in_nodes               - N×3, project length unit (the argument name
%                              says mm; the comparison uses the same unit
%                              as the mesh).
%     in_tetra               - T×4 1-based indices into in_nodes.
%     in_volume_inds         - M×1 tet indices defining the subvolume.
%     in_acceptable_depth_mm - nonnegative scalar radius.
%
%   Outputs
%     out_deep_nodes      - D×3 coordinates of surviving nodes.
%     out_deep_node_inds  - D×1 indices into in_nodes.
%     out_deep_tetra      - rows of in_tetra whose 4 vertices are all deep
%                           (indices still refer to the global in_nodes).
%     out_deep_tetra_inds - those row numbers in in_tetra (not into the
%                           subvolume list).
%
%   See also zef_surface_mesh, zef_lead_field_matrix, zef_nearest_points.


arguments
    in_nodes (:,3) double
    in_tetra (:,4) double {mustBeInteger, mustBePositive}
    in_volume_inds (:,1) double {mustBeInteger, mustBePositive}
    in_acceptable_depth_mm (1,1) double {mustBeNonnegative}
end

% Set empty return values.

out_deep_node_inds = [];
out_deep_nodes = [];
out_deep_tetra_inds = [];
out_deep_tetra = [];

% Find out the boundary- and non-boundary nodes of the volume. Note that
% the indices generated here should reference the "global" set of input
% nodes.

volume_tetra = in_tetra(in_volume_inds, :);

volume_node_inds = unique(volume_tetra(:));

surface_triangles = zef_surface_mesh(volume_tetra);

surface_node_inds = unique(surface_triangles);

non_surface_node_inds = setdiff(volume_node_inds, surface_node_inds);

surface_nodes = in_nodes(surface_node_inds,:);

non_surface_nodes = in_nodes(non_surface_node_inds,:);

% Find out non-surface nodes deep enough within the volume with
% rangesearch.

non_surface_node_inds_too_near_to_surface = zef_nearest_points( ...
    surface_nodes, ...
    non_surface_nodes, ...
    in_acceptable_depth_mm, ...
    'range' ...
    );

non_surface_node_inds_too_near_to_surface = non_surface_node_inds(non_surface_node_inds_too_near_to_surface);

% Also take into account surface nodes themselves. D'uh.

surface_node_inds_too_near_to_surface = zef_nearest_points( ...
    surface_nodes, ...
    surface_nodes, ...
    in_acceptable_depth_mm, ...
    'range' ...
    );

surface_node_inds_too_near_to_surface = surface_node_inds(surface_node_inds_too_near_to_surface);

node_inds_too_near_to_surface = union( ...
    non_surface_node_inds_too_near_to_surface, ...
    surface_node_inds_too_near_to_surface ...
    );

out_deep_node_inds = setdiff( ...
    volume_node_inds, ...
    node_inds_too_near_to_surface, ...
    'rows' ...
    );

out_deep_nodes = in_nodes(out_deep_node_inds, :);

% Find tetra in the volume which only contain acceptable (deep) nodes.
% Acceptable tetra consist of 4 deep nodes.

vertices_in_deep_nodes = ismember(in_tetra, out_deep_node_inds);

vertex_row_sums = sum(vertices_in_deep_nodes, 2);

out_deep_tetra_inds = find(vertex_row_sums == 4);

out_deep_tetra = in_tetra(out_deep_tetra_inds, :);

end % zef_deep_tetra
