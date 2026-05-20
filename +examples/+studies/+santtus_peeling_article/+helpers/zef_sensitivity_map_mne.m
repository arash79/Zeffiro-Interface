function sensitivity_map = zef_sensitivity_map_mne( ...
% --- Zeffiro documentation header ---
% examples.studies.santtus_peeling_article.helpers.sensitivity_map — Example or study script demonstrating sensitivity_map.
%
% Purpose:
%   Example or study script demonstrating sensitivity_map.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Inputs:
%   project_struct
%   weighting_type
%   n_reconstructions
%   noise_level
%   diff_type
%   dispersion_radius
%
% Calls (project):
%   zef_minimum_norm_estimation
%   zef_rec_diff
%   zef_sensitivity_map_mne
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `examples.studies.santtus_peeling_article.helpers.sensitivity_map(project_struct, weighting_type, n_reconstructions, noise_level, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header
    project_struct, ...
    weighting_type, ...
    n_reconstructions, ...
    noise_level, ...
    diff_type, ...
    dispersion_radius ...
)

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

        [dist_vec, angle_vec, mag_vec, dispersion_vec] = examples.studies.santtus_peeling_article.helpers.zef_rec_diff( ...
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
