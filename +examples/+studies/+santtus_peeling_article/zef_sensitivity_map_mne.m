function sensitivity_map = zef_sensitivity_map_mne( ...
    project_struct, ...
    weighting_type, ...
    n_reconstructions, ...
    noise_level, ...
    diff_type, ...
    dispersion_radius ...
)
%
% zef_sensitivity_map_mne - Sensitivity metrics for MNE-family methods.
%
% Runs MNE, dSPM, or sLORETA repeatedly with different noise realizations
% and computes position, direction, magnitude, and dispersion differences
% between true and reconstructed sources via zef_rec_diff.
%
% Inputs:
%   project_struct     Struct with mesh, lead field, and source positions
%   weighting_type     'MNE', 'dSPM', or 'sLORETA'
%   n_reconstructions  Number of Monte Carlo runs for statistics
%   noise_level        Noise level in dB (non-positive)
%   diff_type          "L2" or "minabs" for position error metric
%   dispersion_radius  Radius (mm) for dispersion computation
%
% Output:
%   sensitivity_map  Struct with dist_vec, angle_vec, mag_vec, dispersion_vec (cell arrays)
%

    arguments

        project_struct (1,1) struct

        weighting_type (1,:) char { mustBeMember(weighting_type, {'MNE', 'dSPM', 'sLORETA'}) } = 'sLORETA'

        n_reconstructions (1,1) double { mustBeInteger, mustBePositive } = 10

        noise_level (1,1) double { mustBeNonpositive } = -30

        diff_type (1,1) string { mustBeMember(diff_type, ["L2", "minabs"]) } = "L2"

        dispersion_radius (1,1) double { mustBePositive } = 30

    end

    weighting_type_cell = {'MNE', 'dSPM', 'sLORETA'};
    weighting_type_as_num = find(ismember(weighting_type_cell, weighting_type));

    % Initialize output struct and MNE tool.

    sensitivity_map = struct;

    sensitivity_map.weighting_type = weighting_type;

    project_struct = zef_minimum_norm_estimation(project_struct);

    project_struct.mne_number_of_frames = 3*size(project_struct.source_positions,1);

    project_struct.mne_type = weighting_type_as_num;

    project_struct.mne_prior = 2;

    % Run Monte Carlo sensitivity analysis.
    for i = 1 : n_reconstructions

        [dist_vec, angle_vec, mag_vec, dispersion_vec] = examples.studies.santtus_peeling_article.zef_rec_diff( ...
            project_struct, ...
            @zef_find_mne_reconstruction, ...
            noise_level, ...
            diff_type, ...
            dispersion_radius ...
        );

        sensitivity_map.dist_vec{ i } = dist_vec ;
        sensitivity_map.angle_vec{ i } = angle_vec ;
        sensitivity_map.mag_vec{ i } = mag_vec ;
        sensitivity_map.dispersion_vec{ i } = dispersion_vec ;

    end

end % function
