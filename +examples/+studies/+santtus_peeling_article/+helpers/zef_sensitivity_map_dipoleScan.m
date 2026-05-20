function hauk_map = zef_sensitivity_map_dipoleScan( ...
% --- Zeffiro documentation header ---
% examples.studies.santtus_peeling_article.helpers.hauk_map — Example or study script demonstrating hauk_map.
%
% Purpose:
%   Example or study script demonstrating hauk_map.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Inputs:
%   project_struct
%   n_reconstructions
%   noise_level
%   diff_type
%   dispersion_radius
%
% Calls (project):
%   zef_dipole_start
%   zef_rec_diff
%   zef_sensitivity_map_dipoleScan
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `examples.studies.santtus_peeling_article.helpers.hauk_map(project_struct, n_reconstructions, noise_level, diff_type, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header
    project_struct, ...
    n_reconstructions, ...
    noise_level, ...
    diff_type, ...
    dispersion_radius ...
)

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
