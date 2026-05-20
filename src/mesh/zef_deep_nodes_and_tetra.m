% --- Zeffiro documentation header ---
% function [ ... — Function [ .
%
% Purpose:
%   Function [ ....
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   in_nodes
%   in_tetra
%   in_volume_inds
%   in_acceptable_depth_mm
%
% Calls (project):
%   zef_deep_nodes_and_tetra
%   zef_nearest_points
%   zef_surface_mesh
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `function [ ...(in_nodes, in_tetra, in_volume_inds, in_acceptable_depth_mm)` with project root and `src` on the path.
% --- End Zeffiro documentation header
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
