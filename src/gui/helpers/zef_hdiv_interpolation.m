function [G, interpolation_positions] = zef_hdiv_interpolation( ...
    p_nodes, ...
    p_tetrahedra, ...
    p_brain_inds, ...
    p_intended_source_inds, ...
    p_nearest_neighbour_inds, ...
    p_optimization_system_type ...
    )

% Documentation
%
% Produces a lead field interpolation matrix G with position-based
% optimization (PBO), based on the H(div) (face-intersecting + edgewise)
% source model. Also returns the related interpolation positions.
%
% Input:
%
% - p_nodes
%
%   The nodes that form the tetrahedral mesh.
%
% - p_tetrahedra
%
%   The tetrahedra (4-tuples of node indices) that are formed from
%   p_nodes.
%
% - p_brain_inds
%
%   The indices of the tetrahedra where sources can be placed in the first
%   place. In other words, these tetra form the gray matter.
%
% - p_intended_source_inds
%
%   These are the subset of the tetrahedral indices which indicate where
%   dipolar sources are to be placed in, not just where they can be
%   placed.
%
% - p_nearest_neighbour_inds
%
%   Used in the case of continuous source models to determine which
%   neighbours of neighbours of each central source tetrahedron are to be
%   included in the interpolation. This is the first output value of
%   zef_decompose_dof_space. If this is empty, the source model is
%   interpreted as being discrete.
%
% Output:
%
% - G
%
%   Interpolation matrix that is to be multiplied by the transpose of the
%   transfer matrix in the lead field routines.
%
% - interpolation_positions
%
%   The positions at which sources are the be placed after interpolation.

arguments
    p_nodes (:,3) double {mustBeNonNan}
    p_tetrahedra (:,4) double {mustBeInteger, mustBePositive}
    p_brain_inds (:,1) double {mustBeInteger, mustBePositive}
    p_intended_source_inds (:,1) double {mustBeInteger, mustBePositive}
    p_nearest_neighbour_inds (:,1) double {mustBeInteger, mustBePositive}
    p_optimization_system_type { ...
        mustBeText, ...
        mustBeMember(p_optimization_system_type,{'pbo','mpo'}) ...
        }
end

if isempty(p_nearest_neighbour_inds)
    [G, interpolation_positions] = zef_hdiv_interpolation_discrete_local( ...
        p_nodes, ...
        p_tetrahedra, ...
        p_brain_inds, ...
        p_intended_source_inds, ...
        p_optimization_system_type ...
        );
    return
end

% Open up a zef_waitbar.

wbtitle = 'Lead field H(div) interpolation';
wb = zef_waitbar(0,1, wbtitle);

% Define cleanup operations, in case of an interruption.

cleanupfn = @(h) close(h);
cleanupobj = onCleanup(@() cleanupfn(wb));

% Dipoles and their adjacency and weight matrices T and G.

[T_fi, G_fi, ~, fi_source_directions, fi_source_positions, ~] = zef_fi_dipoles( ...
    p_nodes, ...
    p_tetrahedra, ...
    p_brain_inds ...
    );

[T_ew, G_ew, ~, ew_source_directions, ew_source_positions, ~] = zef_ew_dipoles( ...
    p_nodes, ...
    p_tetrahedra, ...
    p_brain_inds ...
    );

% Form local environment indices based on adjacency matrix T_fi.

valid_source_inds = p_intended_source_inds;

% Form interpolation positions (barycenters of tetrahedra).

source_tetra = p_tetrahedra(valid_source_inds,:);
interpolation_positions = zef_tetra_barycentra(p_nodes, source_tetra);

% Form initial values based on given nodes, tetrahedra and lead field.

n_of_iterations = size(valid_source_inds, 1);

print_interval = ceil(n_of_iterations / 100);

G_cols = 3 * size(interpolation_positions, 1);

% Start iteration over the source positions of interest.

tic;

%% Generate coefficient matrix indices and values before allocating space
%  for G. Start by storing the actual coefficient values and their
%  corresponding rows and columns in the adjacency matrices T into cell
%  arrays or tuples.

fi_coeff_row_col_val = cell(0);
ew_coeff_row_col_val = cell(0);

for i = 1 : n_of_iterations

    % Get global source index.

    source_ind = valid_source_inds(i);

    % Gather continuous environment around current source ind.

    i_locations_in_nearest_neighbour_inds = find(p_nearest_neighbour_inds == i);

    env_inds = [source_ind ; p_brain_inds(i_locations_in_nearest_neighbour_inds)];

    % Use cell arrays to store neighbour source inds per column.

    env_size = numel(env_inds);

    fi_ind_cell = cell(1, env_size);
    ew_ind_cell = cell(1, env_size);

    for ii = 1 : env_size

        fi_ind_cell{ii} = full(find(T_fi(:,env_inds(ii))))';
        ew_ind_cell{ii} = full(find(T_ew(:,env_inds(ii))))';

    end

    % Set the neighbour indices to be used in optimization.

    fi_neighbour_inds = unique([fi_ind_cell{:}]');
    ew_neighbour_inds = unique([ew_ind_cell{:}]');

    % N of non-zero object function coefficients.

    n_coeff_fi = numel(fi_neighbour_inds);
    n_coeff_ew = numel(ew_neighbour_inds);
    n_coeff = n_coeff_fi + n_coeff_ew;

    % Dipole locations and directions.

    dir_mat = [ ...
        fi_source_directions(fi_neighbour_inds,:) ; ...
        ew_source_directions(ew_neighbour_inds,:) ...
        ];

    loc_mat = [ ...
        fi_source_positions(fi_neighbour_inds,:) ; ...
        ew_source_positions(ew_neighbour_inds,:) ...
        ];

    Coeff_mat = hdiv_coefficients_fn( ...
        loc_mat, ...
        dir_mat, ...
        interpolation_positions, ...
        i, ...
        n_coeff, ...
        p_optimization_system_type ...
        );

    % Row indices (repeated because there are multiple values per row)

    fi_coeff_row_col_val{i,1} = repmat(fi_neighbour_inds, 1, size(Coeff_mat,2));
    ew_coeff_row_col_val{i,1} = repmat(ew_neighbour_inds, 1, size(Coeff_mat,2));

    % Column indices (again repeated for the same reasons as above)

    col_inds = (3 * (i-1) + 1 : 3 * i)';

    fi_coeff_row_col_val{i,2} = repmat(col_inds, 1, length(fi_neighbour_inds))';
    ew_coeff_row_col_val{i,2} = repmat(col_inds, 1, length(ew_neighbour_inds))';

    % Values

    fi_coeff_row_col_val{i,3} = Coeff_mat(1 : n_coeff_fi, :);
    ew_coeff_row_col_val{i,3} = Coeff_mat(n_coeff_fi+1 : n_coeff, :);

    % Update zef_waitbar.

    if mod(i, print_interval) == 0

        time_val = toc;

        zef_waitbar( ...
            i,n_of_iterations, ...
            wb, ...
            [ ...
            wbtitle, ...
            ' (', ...
            num2str(i), ...
            ' / ', ...
            num2str(n_of_iterations), ...
            '). Ready: ' datestr(datevec(now+(n_of_iterations/i - 1)*time_val/86400)) '.' ...
            ] ...
            );

    end
end

% Number of needed indices in the sparse matrix G from how many
% coefficients were found during above iteration.

entry_counter_fi = 0;
entry_counter_ew = 0;

for i = 1 : n_of_iterations

    n_of_fi_vals = numel(fi_coeff_row_col_val{i, 3});
    n_of_ew_vals = numel(ew_coeff_row_col_val{i, 3});

    entry_counter_fi = entry_counter_fi + n_of_fi_vals;
    entry_counter_ew = entry_counter_ew + n_of_ew_vals;

end

n_of_entries_fi = entry_counter_fi;
n_of_entries_ew = entry_counter_ew;

% Construct the row I, column J and coeff value K vectors needed to
% instantiate interpolation matrix G with sparse.

entry_counter_fi = 0;
entry_counter_ew = 0;

I_fi = zeros(n_of_entries_fi,1);
J_fi = zeros(n_of_entries_fi,1);
K_fi = zeros(n_of_entries_fi,1);

I_ew = zeros(n_of_entries_ew,1);
J_ew = zeros(n_of_entries_ew,1);
K_ew = zeros(n_of_entries_ew,1);

% Fill in the index and value vectors.

for i = 1 : n_of_iterations

    fi_row_inds = row_col_val_inds_fn(entry_counter_fi, fi_coeff_row_col_val, i, 1);
    fi_col_inds = row_col_val_inds_fn(entry_counter_fi, fi_coeff_row_col_val, i, 2);
    fi_val_inds = row_col_val_inds_fn(entry_counter_fi, fi_coeff_row_col_val, i, 3);

    I_fi(fi_row_inds) = fi_coeff_row_col_val{i,1}(:);
    J_fi(fi_col_inds) = fi_coeff_row_col_val{i,2}(:);
    K_fi(fi_val_inds) = fi_coeff_row_col_val{i,3}(:);

    entry_counter_fi = entry_counter_fi + numel(fi_coeff_row_col_val{i,1});

    ew_row_inds = row_col_val_inds_fn(entry_counter_ew, ew_coeff_row_col_val, i, 1);
    ew_col_inds = row_col_val_inds_fn(entry_counter_ew, ew_coeff_row_col_val, i, 2);
    ew_val_inds = row_col_val_inds_fn(entry_counter_ew, ew_coeff_row_col_val, i, 3);

    I_ew(ew_row_inds) = ew_coeff_row_col_val{i,1}(:);
    J_ew(ew_col_inds) = ew_coeff_row_col_val{i,2}(:);
    K_ew(ew_val_inds) = ew_coeff_row_col_val{i,3}(:);

    entry_counter_ew = entry_counter_ew + numel(ew_coeff_row_col_val{i,1});

end

% Finally, allocate and instantiate building blocks of G only once.

S_fi = sparse(I_fi, J_fi, K_fi, size(G_fi,2), G_cols);
S_ew = sparse(I_ew, J_ew, K_ew, size(G_ew,2), G_cols);

G = G_fi * S_fi + G_ew * S_ew;

zef_waitbar(1,1, wb);

end

%% Helper functions

function inds = row_col_val_inds_fn(entry_counter, rows_cols_vals, iter_ind, selector_ind)

% A helper function for cleaning up above index selection code.
%
% Input
%
% - entry_counter: keeps track of how manu coefficient values there were
%   per transfer matrix column.
%
% - rows_cols_vals: a tuple (cell array) of PBO coefficient
%   (rows,cols,vals) arrays.
%
% - iter_ind: a valid source tetra index.
%
% - selector_ind: in {1,2,3}. Used to choose either rows (1), columns (2)
%   or values (3) from rows_cols_and_vals.
%
% Output:
%
% - the row-, column- or value indices in coeff_rows_cols_vals

arguments
    entry_counter
    rows_cols_vals
    iter_ind
    selector_ind
end

begini = entry_counter + 1;
endi = entry_counter + numel(rows_cols_vals{iter_ind, selector_ind});

inds = begini : endi;

end

function [G, interpolation_positions] = zef_hdiv_interpolation_discrete_local( ...
    p_nodes, ...
    p_tetrahedra, ...
    p_brain_inds, ...
    p_intended_source_inds, ...
    p_optimization_system_type ...
    )

% Build only the H(div) dipoles that touch the selected tetrahedra. The
% global FI/EW dipole matrices are too large for discrete million-tetra
% meshes when only a small source subset is interpolated.

valid_source_inds = p_intended_source_inds;
source_tetra = p_tetrahedra(valid_source_inds,:);
interpolation_positions = zef_tetra_barycentra(p_nodes, source_tetra);

n_of_iterations = size(valid_source_inds, 1);
G_rows = size(p_nodes, 1);
G_cols = 3 * n_of_iterations;

if n_of_iterations == 0
    G = sparse(G_rows, G_cols);
    return
end

wbtitle = 'Lead field H(div) interpolation';
wb = zef_waitbar(0,1, wbtitle);

cleanupfn = @(h) close(h);
cleanupobj = onCleanup(@() cleanupfn(wb));

face_node_inds = [
    2 3 4
    1 3 4
    1 2 4
    1 2 3
    ];

selected_face_keys = zeros(4 * n_of_iterations, 3);
selected_face_source_iter = zeros(4 * n_of_iterations, 1);
selected_face_tetra = zeros(4 * n_of_iterations, 1);
selected_face_opp_node = zeros(4 * n_of_iterations, 1);

for face_ind = 1 : 4
    row_inds = (face_ind - 1) * n_of_iterations + (1 : n_of_iterations);
    selected_face_keys(row_inds,:) = sort(source_tetra(:, face_node_inds(face_ind,:)), 2);
    selected_face_source_iter(row_inds) = (1 : n_of_iterations)';
    selected_face_tetra(row_inds) = valid_source_inds;
    selected_face_opp_node(row_inds) = source_tetra(:, face_ind);
end

[unique_selected_face_keys, ~, selected_face_group] = unique(selected_face_keys, 'rows');
selected_face_group_members = accumarray( ...
    selected_face_group, ...
    (1 : length(selected_face_group))', ...
    [], ...
    @(x) {x} ...
    );

chunk_size = 200000;
n_of_brain_inds = length(p_brain_inds);
fi_capacity = max(4 * n_of_iterations, 1);
fi_count = 0;

fi_source_iter = zeros(fi_capacity, 1);
fi_tetra_1 = zeros(fi_capacity, 1);
fi_tetra_2 = zeros(fi_capacity, 1);
fi_node_1 = zeros(fi_capacity, 1);
fi_node_2 = zeros(fi_capacity, 1);

for chunk_start = 1 : chunk_size : n_of_brain_inds

    chunk_end = min(n_of_brain_inds, chunk_start + chunk_size - 1);
    chunk_brain_inds = p_brain_inds(chunk_start : chunk_end);
    chunk_tetra = p_tetrahedra(chunk_brain_inds, :);

    for face_ind = 1 : 4

        chunk_face_keys = sort(chunk_tetra(:, face_node_inds(face_ind,:)), 2);
        [is_matching_face, matching_group] = ismember( ...
            chunk_face_keys, ...
            unique_selected_face_keys, ...
            'rows' ...
            );

        matching_rows = find(is_matching_face);

        for match_ind = 1 : length(matching_rows)

            row_ind = matching_rows(match_ind);
            neighbour_tetra = chunk_brain_inds(row_ind);
            neighbour_opp_node = chunk_tetra(row_ind, face_ind);
            member_inds = selected_face_group_members{matching_group(row_ind)};

            for member_ind = member_inds'

                source_tetra_ind = selected_face_tetra(member_ind);

                if neighbour_tetra == source_tetra_ind
                    continue
                end

                source_iter = selected_face_source_iter(member_ind);
                source_opp_node = selected_face_opp_node(member_ind);

                if source_tetra_ind <= neighbour_tetra
                    tetra_1 = source_tetra_ind;
                    tetra_2 = neighbour_tetra;
                    node_1 = source_opp_node;
                    node_2 = neighbour_opp_node;
                else
                    tetra_1 = neighbour_tetra;
                    tetra_2 = source_tetra_ind;
                    node_1 = neighbour_opp_node;
                    node_2 = source_opp_node;
                end

                fi_count = fi_count + 1;

                if fi_count > fi_capacity
                    fi_capacity = 2 * fi_capacity;
                    fi_source_iter(fi_capacity, 1) = 0;
                    fi_tetra_1(fi_capacity, 1) = 0;
                    fi_tetra_2(fi_capacity, 1) = 0;
                    fi_node_1(fi_capacity, 1) = 0;
                    fi_node_2(fi_capacity, 1) = 0;
                end

                fi_source_iter(fi_count) = source_iter;
                fi_tetra_1(fi_count) = tetra_1;
                fi_tetra_2(fi_count) = tetra_2;
                fi_node_1(fi_count) = node_1;
                fi_node_2(fi_count) = node_2;

            end
        end
    end

    zef_waitbar( ...
        chunk_end, ...
        n_of_brain_inds + n_of_iterations, ...
        wb, ...
        [wbtitle ' local FI setup.'] ...
        );

end

fi_source_iter = fi_source_iter(1 : fi_count);
fi_tetra_1 = fi_tetra_1(1 : fi_count);
fi_tetra_2 = fi_tetra_2(1 : fi_count);
fi_node_1 = fi_node_1(1 : fi_count);
fi_node_2 = fi_node_2(1 : fi_count);

if ~isempty(fi_source_iter)
    [~, unique_fi_inds] = unique([fi_source_iter fi_tetra_1 fi_tetra_2], 'rows');
    fi_source_iter = fi_source_iter(unique_fi_inds);
    fi_node_1 = fi_node_1(unique_fi_inds);
    fi_node_2 = fi_node_2(unique_fi_inds);
end

fi_by_source = cell(n_of_iterations, 1);

for fi_ind = 1 : length(fi_source_iter)
    source_iter = fi_source_iter(fi_ind);
    fi_by_source{source_iter}(end + 1, 1) = fi_ind;
end

edge_node_inds = [
    1 2
    1 3
    1 4
    2 3
    2 4
    3 4
    ];

G_i_cell = cell(n_of_iterations, 1);
G_j_cell = cell(n_of_iterations, 1);
G_v_cell = cell(n_of_iterations, 1);

tic;
print_interval = max(1, ceil(n_of_iterations / 100));

for i = 1 : n_of_iterations

    fi_inds = fi_by_source{i};
    fi_node_1_i = fi_node_1(fi_inds);
    fi_node_2_i = fi_node_2(fi_inds);

    [fi_directions, fi_moments, fi_locations] = dipole_geometry_fn( ...
        p_nodes, ...
        fi_node_1_i, ...
        fi_node_2_i ...
        );

    source_nodes = source_tetra(i,:);
    ew_nodes = sort(source_nodes(edge_node_inds), 2);

    [ew_directions, ew_moments, ew_locations] = dipole_geometry_fn( ...
        p_nodes, ...
        ew_nodes(:,1), ...
        ew_nodes(:,2) ...
        );

    n_coeff_fi = length(fi_inds);
    n_coeff_ew = size(ew_nodes, 1);
    n_coeff = n_coeff_fi + n_coeff_ew;

    dir_mat = [fi_directions ; ew_directions];
    loc_mat = [fi_locations ; ew_locations];

    Coeff_mat = hdiv_coefficients_fn( ...
        loc_mat, ...
        dir_mat, ...
        interpolation_positions, ...
        i, ...
        n_coeff, ...
        p_optimization_system_type ...
        );

    [G_i_cell{i}, G_j_cell{i}, G_v_cell{i}] = sparse_entries_for_source_fn( ...
        i, ...
        fi_node_1_i, ...
        fi_node_2_i, ...
        fi_moments, ...
        ew_nodes(:,1), ...
        ew_nodes(:,2), ...
        ew_moments, ...
        Coeff_mat ...
        );

    if mod(i, print_interval) == 0

        time_val = toc;

        zef_waitbar( ...
            n_of_brain_inds + i, ...
            n_of_brain_inds + n_of_iterations, ...
            wb, ...
            [ ...
            wbtitle, ...
            ' (', ...
            num2str(i), ...
            ' / ', ...
            num2str(n_of_iterations), ...
            '). Ready: ' datestr(datevec(now+(n_of_iterations/i - 1)*time_val/86400)) '.' ...
            ] ...
            );

    end
end

G_i = vertcat(G_i_cell{:});
G_j = vertcat(G_j_cell{:});
G_v = vertcat(G_v_cell{:});

G = sparse(G_i, G_j, G_v, G_rows, G_cols);

zef_waitbar(1,1, wb);

end

function Coeff_mat = hdiv_coefficients_fn( ...
    loc_mat, ...
    dir_mat, ...
    interpolation_positions, ...
    source_iter, ...
    n_coeff, ...
    optimization_system_type ...
    )

if strcmp(optimization_system_type, 'pbo')

    Coeff_mat = zef_pbo_system( ...
        loc_mat, ...
        dir_mat, ...
        interpolation_positions, ...
        source_iter, ...
        n_coeff ...
        );

elseif strcmp(optimization_system_type, 'mpo')

    Coeff_mat = zef_mpo_system( ...
        loc_mat, ...
        dir_mat, ...
        interpolation_positions, ...
        source_iter, ...
        n_coeff ...
        );

else
    error('To interpolate, one must optimize with either a PBO or an MPO system.')
end

end

function [directions, moments, locations] = dipole_geometry_fn(nodes, node_1, node_2)

directions = nodes(node_2,:) - nodes(node_1,:);
moments = sqrt(sum(directions.^2, 2));

if isempty(moments)
    locations = zeros(0, 3);
    return
end

directions = directions ./ repmat(moments, 1, 3);
locations = (1 / 2) * (nodes(node_1,:) + nodes(node_2,:));

end

function [G_i, G_j, G_v] = sparse_entries_for_source_fn( ...
    source_iter, ...
    fi_node_1, ...
    fi_node_2, ...
    fi_moments, ...
    ew_node_1, ...
    ew_node_2, ...
    ew_moments, ...
    coeff_mat ...
    )

node_1 = [fi_node_1 ; ew_node_1];
node_2 = [fi_node_2 ; ew_node_2];
moments = [fi_moments ; ew_moments];

n_dipoles = length(moments);
col_inds = (3 * (source_iter - 1) + 1 : 3 * source_iter);

G_i = zeros(6 * n_dipoles, 1);
G_j = zeros(6 * n_dipoles, 1);
G_v = zeros(6 * n_dipoles, 1);

entry_ind = 0;

for dipole_ind = 1 : n_dipoles
    for col_ind = 1 : 3
        entry_ind = entry_ind + 1;
        G_i(entry_ind) = node_1(dipole_ind);
        G_j(entry_ind) = col_inds(col_ind);
        G_v(entry_ind) = coeff_mat(dipole_ind, col_ind) / moments(dipole_ind);

        entry_ind = entry_ind + 1;
        G_i(entry_ind) = node_2(dipole_ind);
        G_j(entry_ind) = col_inds(col_ind);
        G_v(entry_ind) = - coeff_mat(dipole_ind, col_ind) / moments(dipole_ind);
    end
end

end
