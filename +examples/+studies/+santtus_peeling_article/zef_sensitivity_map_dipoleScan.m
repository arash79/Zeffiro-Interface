function hauk_map = zef_sensitivity_map_dipoleScan( ...
    project_struct, ...
    n_reconstructions, ...
    noise_level, ...
    diff_type, ...
    dispersion_radius ...
)
%
% zef_sensitivity_map_dipoleScan - Sensitivity metrics for Dipole Scan method.
%
% Runs the Dipole Scan inverse method repeatedly with different noise
% realizations and computes position, direction, magnitude, and dispersion
% differences between true and reconstructed sources via zef_rec_diff.
%
% Inputs:
%   project_struct     Struct with mesh, lead field, and source positions
%   n_reconstructions  Number of Monte Carlo runs for statistics
%   noise_level        Noise level in dB (non-positive)
%   diff_type          "L2" or "minabs" for position error metric
%   dispersion_radius  Radius (mm) for dispersion computation
%
% Output:
%   hauk_map  Struct with dist_vec, angle_vec, mag_vec, dispersion_vec (cell arrays)
%

    arguments

        project_struct (1,1) struct

        n_reconstructions (1,1) double { mustBeInteger, mustBePositive } = 10

        noise_level (1,1) double { mustBeNonpositive } = -30

        diff_type (1,1) string { mustBeMember(diff_type, ["L2", "minabs"]) } = "L2"

        dispersion_radius (1,1) double { mustBePositive } = 30

    end

    hauk_map = struct;

    % Initialize Dipole Scan tool; one frame per source × direction.
    project_struct = zef_dipole_start(project_struct);
    project_struct.number_of_frames = 3 * size(project_struct.source_positions, 1);

    % Run Monte Carlo sensitivity analysis.
    for i = 1 : n_reconstructions

        [dist_vec, angle_vec, mag_vec, dispersion_vec] = examples.studies.santtus_peeling_article.zef_rec_diff( ...
            project_struct, ...
            @zef_dipoleScan, ...
            noise_level, ...
            diff_type, ...
            dispersion_radius ...
        );

        hauk_map.dist_vec{ i } = dist_vec ;
        hauk_map.angle_vec{ i } = angle_vec ;
        hauk_map.mag_vec{ i } = mag_vec ;
        hauk_map.dispersion_vec{ i } = dispersion_vec ;

    end

end % function
