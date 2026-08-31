function hauk_map = zef_sensitivity_map_dipoleScan( ...
    project_struct, ...
    n_reconstructions, ...
    noise_level, ...
    diff_type, ...
    dispersion_radius ...
)
%ZEF_SENSITIVITY_MAP_DIPOLESCAN  Monte Carlo dipole-scan sensitivity maps for the Santtus peeling study.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Repeats zef_rec_diff(..., @zef_dipoleScan, ...) n_reconstructions times
%   (independent noise draws when noise_level < 0). Each trial probes every
%   source × xyz axis; it does not jitter source positions. Dipole scan stores
%   goodness-of-fit, not current amplitude, in the reconstruction cell.
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

    % Run Monte Carlo sensitivity analysis (one zef_rec_diff per noise draw).
    for i = 1 : n_reconstructions

        [dist_vec, angle_vec, mag_vec, dispersion_vec] = examples.studies.santtus_peeling_article.helpers.zef_rec_diff( ...
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
