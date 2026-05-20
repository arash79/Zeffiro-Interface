% --- Zeffiro documentation header ---
% examples.studies.santtus_peeling_article.helpers.function [dist_vec, angle_vec, mag_vec, dispersion_vec] = zef_rec_diff( ... — Example or study script demonstrating function [dist_vec, angle_vec, mag_vec, dispersion_vec] = zef_rec_diff( .
%
% Purpose:
%   Example or study script demonstrating function [dist_vec, angle_vec, mag_vec, dispersion_vec] = zef_rec_diff( ....
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Inputs:
%   zef
%   inverse_method
%   noise_db
%   diff_type
%   dispersion_radius
%
% Zef fields (observed):
%   zef.L (read)
%   zef.inv_data_mode (read, write)
%   zef.inv_synth_source (read, write)
%   zef.measurements (read, write)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_find_source_legacy
%   zef_rec_diff
%   zef_waitbar
%
% Side effects:
%   - reads/updates `zef` struct fields
%   - waitbar progress UI
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `examples.studies.santtus_peeling_article.helpers.function [dist_vec, angle_vec, mag_vec, dispersion_vec] = zef_rec_diff( ...(zef, inverse_method, noise_db, diff_type, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header
function [dist_vec, angle_vec, mag_vec, dispersion_vec] = zef_rec_diff( ...
    zef, ...
    inverse_method, ...
    noise_db, ...
    diff_type, ...
    dispersion_radius ...
)

    arguments

        zef (1,1) struct

        inverse_method (1,1) function_handle

        noise_db (1,1) double { mustBeNonpositive } = 0

        diff_type (1,1) string { mustBeMember(diff_type, ["L2", "minabs"]) } = "L2"

        dispersion_radius (1,1) double { mustBePositive } = 1.5

    end

    % Pre-allocate result vectors.

    dist_vec = zeros(3*size(zef.source_positions,1),1);

    angle_vec = zeros(3*size(zef.source_positions,1),1);

    mag_vec = zeros(3*size(zef.source_positions,1),1);

    dispersion_vec = zeros(3*size(zef.source_positions,1),1);

    max_ind_vec = zeros(3*size(zef.source_positions,1),1);

    % Initialize waitbar and cleanup for progress display.
    h_waitbar = zef_waitbar(0, 'Creating synthetic measurements');

    cleanup_fn = @(wb) i_safe_close_waitbar(wb);

    cleanup_ob = onCleanup(@() cleanup_fn(h_waitbar));

    n_sources = size(zef.source_positions, 1);
    zef.measurements = zeros(size(zef.L, 1), 3*n_sources);
    zef.inv_synth_source = [0 0 0 0 0 0 10 0 3 5];  % Synthetic source parameters
    dir_mat = eye(3);  % Unit vectors along x, y, z

    % For each source position, generate synthetic data along x, y, z and invert.
    for i = 1 : n_sources

        if mod(i,floor(n_sources/10))==0

            h_waitbar = zef_waitbar(i/n_sources,h_waitbar,'Creating synthetic measurements');

        end

        for j = 1 : 3

            zef.inv_synth_source(1:6) = [zef.source_positions(i,:) dir_mat(j,:) ];

            zef.measurements(:,3*(i-1)+j) = zef_find_source_legacy(zef);

            if not(noise_db == 0)

                zef.measurements(:,3*(i-1)+j) = 10^(noise_db/20)*randn(size(zef.measurements,1),1) + zef.measurements(:,3*(i-1)+j);

            end

        end % for

    end % for

    zef.inv_data_mode = 'raw';

    % Run the inverse method; output is a cell array of reconstructions.
    z = inverse_method(zef);

    % Compare each source–reconstruction pair: position, direction, magnitude.

    for i = 1 : n_sources

        for j = 1 : 3

            rec_component_ind = 3 * (i-1) + j;

            z_ij = zeros(3*size(zef.source_positions,1),1);
            z_ij_aux = z{rec_component_ind};
            z_ij(1:length(z{rec_component_ind})) = z_ij_aux;

            reshaped_z_ij = reshape(z_ij, 3, size(zef.source_positions,1));

            z_norm = sqrt(sum(reshaped_z_ij.^2));

            [mag_val, I] = max(z_norm);

            max_ind_vec ( rec_component_ind ) = I ;

            dir_vec_rec = z_ij(3*(I-1)+1:3*(I-1)+3);
            dir_vec_rec = dir_vec_rec/norm(dir_vec_rec,2);

            dir_vec_source = dir_mat(:,j);
            dir_vec_source = dir_vec_source/norm(dir_vec_source,2);

            pos_diffs = zef.source_positions(i,:) - zef.source_positions(I,:);

            if diff_type == "L2"

                dist_vec(rec_component_ind) = (1/sqrt(3)) * sqrt(sum(pos_diffs.^2,2));

            elseif diff_type == "minabs"

                dist_vec(rec_component_ind) = (1/sqrt(3)) * min(abs(pos_diffs), [], 2);

            else

                error("Unknown comparison type in zef_rec_diff. Aborting...")

            end

            angle_vec (rec_component_ind) = acosd(dot(dir_vec_rec, dir_vec_source));

            mag_vec (rec_component_ind) = (1/sqrt(3)) * mag_val;

        end % for

    end % for

    % Compute dispersion (spatial spread) for each reconstructed source.
    repeated_positions = repelem(zef.source_positions, 3, 1);

    for ind = 1 : numel ( max_ind_vec )

        dispersion = dispersion_fn( ...
            zef.source_positions , ...
            repeated_positions, ...
            max_ind_vec ( ind ) , ...
            dispersion_radius , ...
            mag_vec ...
        ) ;

        dispersion_vec ( ind ) = dispersion;

    end % for

end % function

function i_safe_close_waitbar(wb)
% Close a waitbar handle if it's still a valid figure; ignore otherwise.
% Headless / nodisplay sessions often leave wb as [] or an already-deleted handle,
% which makes close(wb) error during onCleanup teardown.
    try
        if ~isempty(wb) && ishghandle(wb) && isvalid(wb)
            close(wb);
        end
    catch
        % Swallow: cleanup must not throw.
    end
end

function the_dispersion = dispersion_fn( ...
    source_positions, ...
    repeated_positions, ...
    max_magnitude_ind, ...
    dispersion_radius, ...
    reconstructed_dipole_magnitudes ...
)
%
% dispersion_fn - Compute weighted spatial dispersion within an ROI.
%
% Computes the dispersion (root-mean-square distance weighted by squared
% dipole magnitudes) of reconstructed sources within a sphere of given
% radius centered on the maximum-magnitude source position.
%

    arguments

        source_positions (:,3) double

        repeated_positions (:,3) double

        max_magnitude_ind (1,1) uint32 { mustBePositive }

        dispersion_radius (1,1) double { mustBePositive }

        reconstructed_dipole_magnitudes (:,1) double

    end

    % Validate input dimensions.

    assert ( ...
        numel ( source_positions ) == numel ( reconstructed_dipole_magnitudes ), ...
        "The number of elements in source positions must match that of reconstructed dipole moments." ...
    ) ;

    assert ( ...
        3 * size ( source_positions, 1 ) == size ( repeated_positions, 1 ), ...
        "The number of source positions must be 1/3 of repeated positions." ...
    ) ;

    % Center of the ROI (position of max-magnitude reconstructed source).
    reconstruction_position = source_positions(max_magnitude_ind, :);

    % Find all sources within dispersion_radius and their squared distances.

    within_roi_inds = rangesearch ( repeated_positions, reconstruction_position, dispersion_radius ) ;

    within_roi_inds = within_roi_inds { 1 } ;

    within_roi_positions = repeated_positions ( within_roi_inds, : ) ;

    n_of_within_roi_positions = numel ( within_roi_inds ) ;

    within_roi_squared_distances = sum ( ...
        ( within_roi_positions - repmat ( reconstruction_position, n_of_within_roi_positions, 1 ) ) .^2 , ...
        2 ...
    ) ;

    within_roi_squared_magnitudes = ( reconstructed_dipole_magnitudes ( within_roi_inds ) ) .^ 2 ;

    % Weighted dispersion: sqrt(sum(r^2 * m^2) / sum(m^2)).
    dispersion_numerator = sum(within_roi_squared_distances .* within_roi_squared_magnitudes);
    dispersion_denominator = sum(within_roi_squared_magnitudes);
    the_dispersion = sqrt(dispersion_numerator / dispersion_denominator);

end % function
