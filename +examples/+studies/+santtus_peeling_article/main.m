function [ sensitivities_with_statistics, L ] = main ( ...
    project_path, ...
    inverse_method, ...
    n_of_runs, ...
    noise_level_db, ...
    diff_type, ...
    dispersion_radius, ...
    args ...
)
%MAIN  Monte Carlo localization study (legacy MNE / dipole scan).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [sensitivities_with_statistics, L] = main(project_path, inverse_method, ...
%       n_of_runs, noise_level_db, diff_type, dispersion_radius, args)
%
%   project_path: .mat for zeffiro_interface('open_project', ...), or '' if
%   name-value zef= is a non-empty struct. inverse_method: 'sLORETA',
%   'dSPM', 'MNE', or 'Dipole Scan'. noise_level_db ≤ 0. Optional args:
%   use_gpu, build_mesh, mesh_resolution, build_lead_field (uses
%   zef_eeg_lead_field), n_of_sources, source_model, build_reconstructions.
%   In-memory zef is assignin('base','zef',...) for legacy tools.
%

        project_path (:,:) char = char.empty(0,0)

        inverse_method (1,:) char { mustBeMember(inverse_method, ["sLORETA", "dSPM", "MNE", "Dipole Scan"]) } = 'sLORETA'

        n_of_runs (1,1) double { mustBeInteger, mustBePositive } = 10

        noise_level_db (1,1) double { mustBeNonpositive } = -30

        diff_type (1,1) string { mustBeMember(diff_type, ["L2", "minabs"]) } = "L2"

        dispersion_radius (1,1) double { mustBePositive } = 30

        args.use_gpu (1,1) logical = false;

        args.build_mesh (1,1) logical = false;

        args.mesh_resolution (1,1) double { mustBePositive } = 3

        args.build_lead_field (1,1) logical = true;

        args.n_of_sources (1,1) double { mustBeInteger, mustBePositive } = 10000

        args.acceptable_source_depth (1,1) double { mustBeReal, mustBeNonnegative } = 0

        args.optimization_system_type (1,1) string { mustBeMember( ...
            args.optimization_system_type, ...
            ["pbo", "mpo", "none"] ...
        ) } = "pbo"

        args.source_model (1,1) core.types.ZefSourceModel = core.types.ZefSourceModel.Hdiv

        args.build_reconstructions (1,1) logical = true

        args.lead_field_filter_quantile (1,1) double { ...
            mustBeGreaterThanOrEqual(args.lead_field_filter_quantile, 0), ...
            mustBeLessThanOrEqual(args.lead_field_filter_quantile, 1) ...
        } = 1

        args.zef (1,1) struct = struct()

    end % arguments

    use_in_memory_zef = not(isempty(fieldnames(args.zef)));

    if not(use_in_memory_zef)
        if isempty(strtrim(string(project_path)))
            error("examples.studies.santtus_peeling_article:MissingProject", ...
                "Provide project_path to a .mat file, or pass name-value zef=... with a non-empty project struct.");
        end
        % Load an initial project struct from the given path.
        project_struct = zeffiro_interface( ...
            'start_mode','nodisplay', ...
            'use_github', false, ...
            'use_gpu', args.use_gpu, ...
            'open_project', project_path ...
        );
    else
        project_struct = args.zef;
    end

    % Set mesh resolution and generate a finite element mesh.

    if args.build_mesh

        project_struct.mesh_resolution = args.mesh_resolution;

        project_struct = zef_create_finite_element_mesh(project_struct);

    end

    % Set the number of (dipolar) sources to be reconstructed and build the
    % EEG lead field.

    if args.build_mesh || args.build_lead_field

        project_struct.n_sources = args.n_of_sources;

        project_struct.acceptable_source_depth = args.acceptable_source_depth;

        project_struct.optimization_system_type = args.optimization_system_type;

        project_struct.source_model = args.source_model;

        project_struct.lead_field_filter_quantile = args.lead_field_filter_quantile;

        project_struct = zef_eeg_lead_field(project_struct);

    end

    % Get lead field from within zef or set a funky return value, if L could
    % not be located.

    if isfield(project_struct, "L")

        L = project_struct.L;

    else

        L = [NaN];

    end

    % Start the MNE tool and calculate reconstruction sensitivities for the
    % given MNE type.

    project_struct = zef_minimum_norm_estimation(project_struct);

    % Legacy inverse code paths (e.g. zef_find_mne_reconstruction) read fields via eval('zef...') from base.
    if use_in_memory_zef
        assignin("base", "zef", project_struct);
    end

    sensitivities_with_statistics = struct;

    if args.build_reconstructions

        im = strtrim(char(string(inverse_method)));

        if strcmpi(im, "sLORETA") || strcmpi(im, "dSPM") || strcmpi(im, "MNE")

            sensitivities = examples.studies.santtus_peeling_article.helpers.zef_sensitivity_map_mne( ...
                project_struct, ...
                im, ...
                n_of_runs, ...
                noise_level_db, ...
                diff_type, ...
                dispersion_radius ...
            );

        elseif strcmpi(im, "Dipole Scan")

            sensitivities = examples.studies.santtus_peeling_article.helpers.zef_sensitivity_map_dipoleScan( ...
                project_struct, ...
                n_of_runs, ...
                noise_level_db, ...
                diff_type, ...
                dispersion_radius ...
            );

        else

            error("Unknown inverse method.")

        end

        sensitivities_with_statistics = add_statistics_to_struct(sensitivities, n_of_runs);

    end % if

end % function

%% Local helper functions

function output_struct = add_statistics_to_struct(input_struct, n_reconstructions)

    %
    % add_statistics_to_struct - Add mean and std over Monte Carlo runs.
    %
    % Requires input_struct to have fields dist_vec, angle_vec, mag_vec,
    % dispersion_vec (each a cell array of length n_reconstructions). Adds
    % dist_vec_avg, dist_vec_std, angle_vec_avg, angle_vec_std, mag_vec_avg,
    % mag_vec_std, dispersion_avg, dispersion_std.
    %

    arguments

        input_struct (1,1) struct

        n_reconstructions (1,1) double { mustBeInteger, mustBePositive }

    end

    % Preallocate space for the statistics.

    input_struct.dist_vec_avg = zeros(size(input_struct.dist_vec{1}));
    input_struct.angle_vec_avg = zeros(size(input_struct.angle_vec{1}));
    input_struct.mag_vec_avg = zeros(size(input_struct.mag_vec{1}));
    input_struct.dispersion_avg = zeros(size(input_struct.dispersion_vec{1}));

    input_struct.dist_vec_std = zeros(size(input_struct.dist_vec{1}));
    input_struct.angle_vec_std = zeros(size(input_struct.angle_vec{1}));
    input_struct.mag_vec_std = zeros(size(input_struct.mag_vec{1}));
    input_struct.dispersion_std = zeros(size(input_struct.dispersion_vec{1}));

    % Compute means.

    for i = 1 : n_reconstructions

        input_struct.dist_vec_avg = input_struct.dist_vec_avg + input_struct.dist_vec{i};
        input_struct.angle_vec_avg = input_struct.angle_vec_avg + input_struct.angle_vec{i};
        input_struct.mag_vec_avg = input_struct.mag_vec_avg + input_struct.mag_vec{i};
        input_struct.dispersion_avg = input_struct.dispersion_avg + input_struct.dispersion_vec{i};

    end

    input_struct.dist_vec_avg = input_struct.dist_vec_avg/n_reconstructions;
    input_struct.angle_vec_avg = input_struct.angle_vec_avg/n_reconstructions;
    input_struct.mag_vec_avg = input_struct.mag_vec_avg / n_reconstructions;
    input_struct.dispersion_avg = input_struct.dispersion_avg/n_reconstructions;

    % Compute standard deviations.

    for i = 1 : n_reconstructions
        input_struct.dist_vec_std = input_struct.dist_vec_std + (input_struct.dist_vec{i} - input_struct.dist_vec_avg).^2;
        input_struct.angle_vec_std = input_struct.angle_vec_std + (input_struct.angle_vec{i} - input_struct.angle_vec_avg).^2;
        input_struct.mag_vec_std = input_struct.mag_vec_std + (input_struct.mag_vec{i} - input_struct.mag_vec_avg).^2;
        input_struct.dispersion_std = input_struct.dispersion_std + (input_struct.dispersion_vec{i} - input_struct.dispersion_avg).^2;
    end

    input_struct.dist_vec_std = sqrt(input_struct.dist_vec_std/(n_reconstructions-1));
    input_struct.angle_vec_std = sqrt(input_struct.angle_vec_std/(n_reconstructions-1));
    input_struct.mag_vec_std = sqrt(input_struct.mag_vec_std/(n_reconstructions-1));
    input_struct.dispersion_std = sqrt(input_struct.dispersion_std/(n_reconstructions-1));

    % Everything succeeded, so set output value.

    output_struct = input_struct;

end
