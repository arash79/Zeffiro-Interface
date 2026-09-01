function [G, interpolation_positions] = zef_whitney_interpolation( ...
    p_nodes, ...
    p_tetrahedra, ...
    p_brain_inds, ...
    p_intended_source_inds, ...
    p_nearest_neighbour_inds, ...
    p_optimization_system_type ...
    )
%ZEF_WHITNEY_INTERPOLATION  Whitney (face-intersecting) source interpolation G.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_lead_field_interpolation for ZefSourceModel.Whitney
%   and ContinuousWhitney. Builds a sparse map from nodal degrees of
%   freedom to three Cartesian source columns per intended tetrahedron.
%
%   [G, interpolation_positions] = zef_whitney_interpolation(nodes, tetra, ...
%       brain_inds, intended_source_inds, nearest_neighbour_inds, ...
%       optimization_system_type)
%
%   Dipoles: zef_fi_dipoles (face-intersecting / FI) only — not edge
%   Whitney (EW). interpolation_positions are barycentra of
%   tetra(intended_source_inds,:).
%
%   For each source tet i, neighbours are the nonzero rows of T_fi(:,i).
%   If nearest_neighbour_inds is nonempty (continuous model), the
%   neighbourhood is the union of T_fi columns for i and the brain tets
%   listed for that source. Empty nearest_neighbour_inds → discrete local.
%
%   Coefficients: p_optimization_system_type must be 'pbo' or 'mpo'
%   (otherwise error). PBO/MPO return n_coeff×3 weights; those fill S_fi
%   and G = G_fi * S_fi (G_fi from zef_fi_dipoles). Size of G is
%   n_nodes × 3*n_sources.
%
%   See also zef_hdiv_interpolation, zef_pbo_system, zef_mpo_system,
%            zef_lead_field_interpolation, zef_fi_dipoles.

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

G = [];

% Open up a zef_waitbar.

wbtitle = 'Lead field Whitney interpolation';
wb = zef_waitbar(0,1, wbtitle);

% Define cleanup operations, in case of an interruption.

cleanupfn = @zef_close_waitbar;

cleanupobj = onCleanup(@() cleanupfn(wb));

% Dipoles and their adjacency and weight matrices T and G.

[T_fi, G_fi, ~, fi_source_directions, fi_source_positions, ~] = zef_fi_dipoles( ...
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

% Invert nearest-neighbour labels once. find(p_nearest_neighbour_inds==i)
% inside the source loop is O(n_sources * n_brain_tets).

if isempty(p_nearest_neighbour_inds)
    nn_groups = {};
else
    nn_groups = accumarray( ...
        p_nearest_neighbour_inds(:), ...
        (1:numel(p_nearest_neighbour_inds))', ...
        [n_of_iterations, 1], ...
        @(x) {x}, ...
        {zeros(0, 1)} ...
        );
end

% Initialize weight matrix.

G_rows = size(p_nodes, 1);
G_cols = 3 * size(interpolation_positions, 1);

G = sparse(G_rows, G_cols, 0);

% Start iteration over the source positions of interest.

tic;

%% Generate coefficient matrix indices and values before allocating space
%  for G. Start by storing the actual coefficient values and their
%  corresponding rows and columns in the adjacency matrices T into cell
%  arrays or tuples.

fi_coeff_row_col_val = cell(0);

for i = 1 : n_of_iterations

    % Get global source index.

    source_ind = valid_source_inds(i);

    % Find local neighbour indices.

    if isempty(p_nearest_neighbour_inds)

        fi_neighbour_inds = full(find(T_fi(:,source_ind)));

    else

        % Gather continuous environment around current source ind.

        i_locations_in_nearest_neighbour_inds = nn_groups{i};

        env_inds = [source_ind ; p_brain_inds(i_locations_in_nearest_neighbour_inds)];

        % Use cell arrays to store neighbour source inds per column.

        env_size = numel(env_inds);

        fi_ind_cell = cell(1, env_size);

        for ii = 1 : env_size

            fi_ind_cell{ii} = full(find(T_fi(:,env_inds(ii))))';

        end

        % Set the neighbour indices to be used in optimization.

        fi_neighbour_inds = unique([fi_ind_cell{:}]');

    end

    % N of non-zero object function coefficients.

    n_coeff_fi = numel(fi_neighbour_inds);
    n_coeff = n_coeff_fi;

    % Dipole locations and directions.

    dir_mat = [ ...
        fi_source_directions(fi_neighbour_inds,:) ...
        ];

    loc_mat = [ ...
        fi_source_positions(fi_neighbour_inds,:) ...
        ];

    % Interpolation coefficients.

    if strcmp(p_optimization_system_type, 'pbo')

        Coeff_mat = zef_pbo_system( ...
            loc_mat, ...
            dir_mat, ...
            interpolation_positions, ...
            i, ...
            n_coeff ...
            );

    elseif strcmp(p_optimization_system_type, 'mpo')

        Coeff_mat = zef_mpo_system( ...
            loc_mat, ...
            dir_mat, ...
            interpolation_positions, ...
            i, ...
            n_coeff ...
            );

    else
        error('To interpolate, one must optimize with either a PBO or an MPO system.')
    end

    % Row indices (repeated because there are multiple values per row)

    fi_coeff_row_col_val{i,1} = repmat(fi_neighbour_inds, 1, size(Coeff_mat,2));

    % Column indices (again repeated for the same reasons as above)

    col_inds = (3 * (i-1) + 1 : 3 * i)';

    fi_coeff_row_col_val{i,2} = repmat(col_inds, 1, length(fi_neighbour_inds))';

    % Values

    fi_coeff_row_col_val{i,3} = Coeff_mat(1 : n_coeff_fi, :);

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

for i = 1 : n_of_iterations

    n_of_fi_vals = numel(fi_coeff_row_col_val{i, 3});

    entry_counter_fi = entry_counter_fi + n_of_fi_vals;

end

n_of_entries_fi = entry_counter_fi;

% Construct the row I, column J and coeff value K vectors needed to
% instantiate interpolation matrix G with sparse.

entry_counter_fi = 0;

I_fi = zeros(n_of_entries_fi,1);
J_fi = zeros(n_of_entries_fi,1);
K_fi = zeros(n_of_entries_fi,1);

% Fill in the index and value vectors.

for i = 1 : n_of_iterations

    fi_row_inds = row_col_val_inds_fn(entry_counter_fi, fi_coeff_row_col_val, i, 1);
    fi_col_inds = row_col_val_inds_fn(entry_counter_fi, fi_coeff_row_col_val, i, 2);
    fi_val_inds = row_col_val_inds_fn(entry_counter_fi, fi_coeff_row_col_val, i, 3);

    I_fi(fi_row_inds) = fi_coeff_row_col_val{i,1}(:);
    J_fi(fi_col_inds) = fi_coeff_row_col_val{i,2}(:);
    K_fi(fi_val_inds) = fi_coeff_row_col_val{i,3}(:);

    entry_counter_fi = entry_counter_fi + numel(fi_coeff_row_col_val{i,1});

end

% Finally, allocate and instantiate building blocks of G only once.

S_fi = sparse(I_fi, J_fi, K_fi, size(G_fi,2), G_cols);

G = G_fi * S_fi;

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
