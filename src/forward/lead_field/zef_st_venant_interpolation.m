function [G, interpolation_positions] = zef_st_venant_interpolation( ...
    p_nodes, ...
    p_tetrahedra, ...
    p_brain_inds, ...
    p_intended_source_inds, ...
    p_nearest_neighbour_inds, ...
    p_regparam ...
    )
%ZEF_ST_VENANT_INTERPOLATION  St. Venant monopolar source interpolation G.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_lead_field_interpolation for ZefSourceModel.StVenant
%   and ContinuousStVenant. Does not use PBO/MPO; the 6th argument is the
%   Tikhonov parameter p_regparam (EEG FEM passes 1e-6).
%
%   [G, interpolation_positions] = zef_st_venant_interpolation(nodes, tetra, ...
%       brain_inds, intended_source_inds, nearest_neighbour_inds, regparam)
%
%   For each intended source tet:
%     1. interpolation position = tet barycentre; nearest mesh node via
%        KDTreeSearcher.
%     2. Neighbours = nonzero rows of zef_adjacency_matrix on brain tets
%        (the centre node is dropped). Empty neighbour set → skip.
%     3. Moments = neighbour_diffs / longest_edge. Restriction P is 9 ×
%        n_neighbours: rows 1,4,7 ones (charge); 2,5,8 dipole moments;
%        3,6,9 squared moments. b is 9×3 with I_3/longest_edge on the
%        dipole rows. D = diag(sum(dists.^2,2)).
%     4. Monopolar loads m = (P'P + α D)^{-1} P' b, written into the
%        three columns of G at the neighbour nodes.
%
%   Continuous neighbourhood (nonempty nearest_neighbour_inds) currently
%   does not expand the stencil. G is negated at the end (sign convention
%   vs the Schur complement; see the comment above the negation).
%   Nodes with no neighbours contribute nothing.
%
%   See also zef_adjacency_matrix, zef_L2_norm, zef_lead_field_interpolation.

arguments
    p_nodes (:,3) double {mustBeNonNan}
    p_tetrahedra (:,4) double {mustBeInteger, mustBePositive}
    p_brain_inds (:,1) double {mustBeInteger, mustBePositive}
    p_intended_source_inds (:,1) double {mustBeInteger, mustBePositive}
    p_nearest_neighbour_inds (:,1) double {mustBeInteger, mustBePositive}
    p_regparam (1,1) double
end

G = [];

interpolation_positions = [];

% Open up a zef_waitbar

wbtitle = 'Lead field interpolation (St. Venant)';
wb = zef_waitbar(0,1, wbtitle);

% Define cleanup operations, in case of an interruption.

cleanupfn = @(handle) close(handle);

cleanupobj = onCleanup(@() cleanupfn(wb));

% Define adjacency matrix for tetrahedra

adjacency_mat = zef_adjacency_matrix(p_nodes, p_tetrahedra(p_brain_inds,:));

%% First find nodes closest to the given positions.

% Nearest nodes for each interpolation position with KDTree search

MdlKDT = KDTreeSearcher(p_nodes);

interpolation_positions = zef_tetra_barycentra(p_nodes, p_tetrahedra(p_intended_source_inds, :));

center_node_inds = knnsearch(MdlKDT, interpolation_positions);

% Storage for the interpolation results.

n_of_iters = numel(center_node_inds);

print_interval = ceil(n_of_iters / 100);

% Initialize interpolation weight matrix G

Grows = size(p_nodes, 1);

Gcols = 3 * size(interpolation_positions, 1);

G = sparse(Grows, Gcols, 0);

%% Interpolation for each position

wbtitleloop = [wbtitle, ': interpolation '];

% Cartesian directions for interpolation

basis = eye(3);

% Iterate over neighbours of each center node and form the monopolar
% loads.

for ind = 1 : n_of_iters

    % Update zef_waitbar.

    if mod(ind, print_interval) == 0

        zef_waitbar(ind , n_of_iters, wb, [wbtitleloop, num2str(ind), ' / ', num2str(n_of_iters)]);

    end

    % Fetch reference node coordinates

    refnode_ind = center_node_inds(ind);

    refnode = p_nodes(refnode_ind, :);

    % Calculate the distances from refnode with Matlab's broadcasting
    % mechanism and save them to the preallocated distance matrix.

    neighbour_inds = find(adjacency_mat(:, refnode_ind));
    % p_nearest_neighbour_inds is part of the shared interpolation
    % signature; Continuous St. Venant uses this same adjacency stencil
    % (it does not grow the neighbourhood beyond tet-edge adjacency).

    % Isolated vertices (empty adjacency column) cannot form a St. Venant
    % stencil; skip rather than building a 9×0 least-squares system.

    if isempty(neighbour_inds)
        continue
    end

    neighbour_inds = setdiff(neighbour_inds, refnode_ind);

    n_of_neighbours = numel(neighbour_inds); % + 1;

    neighbours = p_nodes(neighbour_inds, :);

    neighbour_diffs = neighbours - refnode;

    % Calculate the distances and longest edge.

    dists = zef_L2_norm(neighbour_diffs, 2);

    longest_edge_len = max(dists, [], 'all');

    %% Construct restriction matrices P, b and regularization matrix D.

    P = zeros(9, n_of_neighbours);

    % Conservation of charge (rows of ones)

    P(1:3:end,:) = repmat(ones(1, size(P, 2)), 3, 1);

    % Dipole moment approximations

    moments = (1/longest_edge_len) * neighbour_diffs;

    moment_x = moments * basis(:,1);
    moment_y = moments * basis(:,2);
    moment_z = moments * basis(:,3);

    P(2,:) = moment_x';
    P(5,:) = moment_y';
    P(8,:) = moment_z';

    % Suppression of higher order moments

    P(3,:) = moment_x'.^2;
    P(6,:) = moment_y'.^2;
    P(9,:) = moment_z'.^2;

    % Vector b

    b = zeros(9,3);

    b(2:3:end, :) = basis / longest_edge_len;

    % Regularization matrix D

    D = diag(sum(dists.^2, 2));

    % Form the monopolar loads m via least squares approximation
    % m = inv(P'P + aD)P'b.

    m = inv(P' * P + p_regparam * D) * P' * b;

    col_inds = (3 * (ind-1) + 1 : 3 * ind);

    G(neighbour_inds, col_inds) = m(:,1:3);

end

% Sign is flipped so the interpolation matches EEG transfer polarity.
% zef_transfer_matrix also yields a negative Schur complement (B/C differ
% for EEG vs tES); keep this minus if you change that assembler.

G = -G;

end
