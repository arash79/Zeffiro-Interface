%RUN_ELORETA_SHALPR_SNR_SWEEP  Lab batch: four solvers × project .mat × SNR.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. project_files are cwd-relative
%   data/icbm152_model/*.mat (not shipped here). snr_db_list = [5 17.5 30].
%   Calls zef_run_inverse_pipeline with sloreta, dipolescan, eloreta,
%   shalpr (halpr). Saves inverse_<tag>_snr_<tag>_four_solvers.mat under
%   cwd inverse_pipeline_results/ plus batch_index_four_solvers.mat.
%   Missing project files warn and skip. One-off SNR-sweep lab driver.
%

% RUN_ELORETA_SHALPR_SNR_SWEEP
% Batch runner for sLORETA, Dipole Scan, eLORETA, and SHALpR over project
% files and SNR values.
%
% Edit project_files and snr_db_list below, then run:
%
%   run_eloreta_shalpr_snr_sweep
%
% One .mat file is saved per project/SNR pair. Each file contains the
% variable "output", with metadata plus the pipeline output from
% zef_run_inverse_pipeline.

%% =============================== CONFIG ================================

project_files = [
    "data/icbm152_model/FS_WS_COMPLEX_ICBM152_mesh_lead_field.mat"
    "data/icbm152_model/FS_WS_COMPLEX_ICBM152_no_containers_mesh_lead_field.mat"
    "data/icbm152_model/FS_WS_COMPLEX_ICBM152_refined_skull_mesh_lead_field.mat"
    "data/icbm152_model/Updated_FS_WS_SIMPLE_ICBM152_mesh_updated_lead_field.mat"
    "data/icbm152_model/Updated_Merged_SN_WOS_ICBM152_mesh_updated_lead_field.mat"
    "data/icbm152_model/SN_WS_ICBM152_mesh_lead_field.mat"
    % "data/another_project.mat"
];

snr_db_list = [5 17.5 30];

output_dir = "inverse_pipeline_results";
if ~exist(char(output_dir), 'dir')
    mkdir(char(output_dir));
end

% Sensitivity calculation. The default matches test_zef_inverse_pipeline's
% static-method logic and probes every active source. For a quick smoke
% test, set sensitivity_source_mode = "synthetic_sources". Static solvers
% are reconstructed in probe batches to keep all-active-source sensitivity
% runs inside memory.
run_sensitivity = true;
sensitivity_source_mode = "all_active_sources";
max_sensitivity_probes_per_batch = 750;

%% ---------------- Measurement configuration ----------------------------

clear sources

sources(1)
.position    = [-33, -37,  80];
sources(1).orientation = [0.2,   1,   0];
sources(1).amplitude   = 10;
sources(1).time_series = "blackmanharris";

sources(2).position    = [-12, -32,  50];
sources(2).orientation = [0.2,   0.196, -0.98058];
sources(2).amplitude   = 10;
sources(2).time_series = @(t) i_thalamic_pulse(t);

mcfg_base = struct();
mcfg_base.sources                 = sources;
mcfg_base.sampling_frequency      = 2500;
mcfg_base.duration                = 0.01;
mcfg_base.rng_seed                = 1;
mcfg_base.record_inv_synth_source = true;

sensitivity_centers = vertcat(sources.position);
nearest_mask_fn = @i_nearest_brain_sources;

%% ---------------- Inverse configuration --------------------------------

icfg_base = struct();
icfg_base.execution        = "local";
icfg_base.run_inverse      = true;
icfg_base.run_sensitivity  = run_sensitivity;
icfg_base.number_of_frames = 1;
icfg_base.methods = {
    "sloreta",    "sloreta",    struct( ...
        "method_type", "sLORETA", ...
        "theta0", 1e-3)
    "dipolescan", "dipolescan", struct( ...
        "method_type", "SVD", ...
        "reg_type", "None", ...
        "reg_parameter", 1e-3)
    "eloreta", "eloreta", struct( ...
        "regularization_parameter", [], ...
        "noise_cov", [], ...
        "n_max_iterations", 200, ...
        "convergence_tolerance", 1e-6, ...
        "apply_average_reference", true)
    "shalpr",  "halpr",   struct( ...
        "estimation_type", "Standardized", ...
        "q", 1, ...
        "beta", 3, ...
        "theta0", 1e-10, ...
        "hyperprior_mode", "Sensitivity weighted", ...
        "n_map_iterations", 25, ...
        "n_L1_iterations", 5, ...
        "use_multiresolution", false)
};

icfg_base.sensitivity = struct( ...
    "n_of_runs", 10, ...
    "noise_level_db", -30, ...
    "diff_type", "L2", ...
    "dispersion_radius", 30, ...
    "isolated_frames_per_probe", 4, ...
    "max_probes_per_batch", max_sensitivity_probes_per_batch ...
);

if run_sensitivity
    switch lower(char(sensitivity_source_mode))
        case 'synthetic_sources'
            icfg_base.sensitivity.source_mask = ...
                @(z) nearest_mask_fn(z, sensitivity_centers);
        case 'all_active_sources'
            % Leave source_mask unset so zef_sensitivity_run probes the
            % whole active source set.
        otherwise
            error('Unknown sensitivity_source_mode "%s".', ...
                char(sensitivity_source_mode));
    end
end

%% =============================== RUN ===================================

batch_index = struct( ...
    "project_files", project_files, ...
    "snr_db_list", snr_db_list, ...
    "run_sensitivity", run_sensitivity, ...
    "sensitivity_source_mode", sensitivity_source_mode, ...
    "max_sensitivity_probes_per_batch", max_sensitivity_probes_per_batch, ...
    "output_files", strings(numel(project_files), numel(snr_db_list)), ...
    "status", strings(numel(project_files), numel(snr_db_list)) ...
);

for project_ind = 1:numel(project_files)
    project_file = project_files(project_ind);

    if ~exist(char(project_file), 'file')
        warning('Project file "%s" not found. Skipping.', char(project_file));
        continue
    end

    for snr_ind = 1:numel(snr_db_list)
        snr_db = snr_db_list(snr_ind);

        fprintf('\n=== Project %d/%d: %s | SNR %g dB ===\n', ...
            project_ind, numel(project_files), char(project_file), snr_db);

        mcfg = mcfg_base;
        mcfg.snr_db = snr_db;

        icfg = icfg_base;
        icfg.inv_snr_db = snr_db;

        project_tag = i_project_tag(project_file);
        snr_tag = i_snr_tag(snr_db);
        output_file = fullfile(output_dir, ...
            sprintf('inverse_%s_snr_%s_four_solvers.mat', project_tag, snr_tag));

        try
            [~, output] = zef_run_inverse_pipeline( ...
                "project_file", project_file, ...
                "measurement_config", mcfg, ...
                "inverse_config", icfg);

            run_status = i_pipeline_status(output);
            output.batch = struct( ...
                "project_file", project_file, ...
                "project_index", project_ind, ...
                "snr_db", snr_db, ...
                "snr_index", snr_ind, ...
                "run_sensitivity", run_sensitivity, ...
                "sensitivity_source_mode", sensitivity_source_mode, ...
                "max_sensitivity_probes_per_batch", max_sensitivity_probes_per_batch, ...
                "output_file", string(output_file), ...
                "status", run_status);

            batch_index.status(project_ind, snr_ind) = run_status;
            i_print_pipeline_status(output);
        catch ME
            output = struct();
            output.batch = struct( ...
                "project_file", project_file, ...
                "project_index", project_ind, ...
                "snr_db", snr_db, ...
                "snr_index", snr_ind, ...
                "run_sensitivity", run_sensitivity, ...
                "sensitivity_source_mode", sensitivity_source_mode, ...
                "max_sensitivity_probes_per_batch", max_sensitivity_probes_per_batch, ...
                "output_file", string(output_file), ...
                "status", "failed", ...
                "error_message", string(ME.message), ...
                "error_report", string(getReport(ME, 'extended', 'hyperlinks', 'off')));

            batch_index.status(project_ind, snr_ind) = "failed";
            warning('Failed for %s at SNR %g dB: %s', char(project_file), snr_db, ME.message);
        end

        save(char(output_file), "output", "-v7.3");
        batch_index.output_files(project_ind, snr_ind) = string(output_file);
        fprintf('Saved %s\n', char(output_file));
    end
end

save(char(fullfile(output_dir, "batch_index_four_solvers.mat")), "batch_index", "-v7.3");

%% =============================== HELPERS ================================

function ts = i_thalamic_pulse(t)
n = numel(t);
sz = max(1, find(t > 0.008, 1));
if isempty(sz)
    sz = n;
end
pulse = blackmanharris(sz)';
ts = [pulse, zeros(1, n - numel(pulse))];
end

function mask = i_nearest_brain_sources(zef, centers)
[~, ~, procFile] = zef_processLeadfields(zef);
n_full = size(zef.source_positions, 1);
mask = false(n_full, 1);

active = procFile.s_ind_0(:);
if isempty(active)
    return
end

P_active = zef.source_positions(active, :);

for k = 1:size(centers, 1)
    d2 = sum((P_active - centers(k, :)).^2, 2);
    [~, i_local] = min(d2);
    mask(active(i_local)) = true;
end
end

function status = i_pipeline_status(output)
status = "ok";
has_inverse_errors = i_stage_has_errors(output, "inverse");
has_sensitivity_errors = i_stage_has_errors(output, "sensitivity");
missing_sensitivity = isfield(output, "config") ...
    && isfield(output.config, "run_sensitivity") ...
    && output.config.run_sensitivity ...
    && (~isfield(output, "sensitivity") || isempty(fieldnames(output.sensitivity)));

if has_inverse_errors && has_sensitivity_errors
    status = "inverse_and_sensitivity_errors";
elseif has_inverse_errors
    status = "inverse_errors";
elseif has_sensitivity_errors
    status = "sensitivity_errors";
elseif missing_sensitivity
    status = "sensitivity_missing";
end
end

function tf = i_stage_has_errors(output, stage_name)
tf = false;
stage_name = char(stage_name);
if ~isfield(output, stage_name)
    return
end
stage = output.(stage_name);
keys = fieldnames(stage);
for k = 1:numel(keys)
    if isfield(stage.(keys{k}), "err")
        tf = true;
        return
    end
end
end

function i_print_pipeline_status(output)
status = i_pipeline_status(output);
if status == "ok"
    return
end

warning('Pipeline finished with status "%s". Inspect output.inverse/output.sensitivity error fields.', char(status));
i_print_stage_errors(output, "inverse");
i_print_stage_errors(output, "sensitivity");
end

function i_print_stage_errors(output, stage_name)
stage_name = char(stage_name);
if ~isfield(output, stage_name)
    return
end
stage = output.(stage_name);
keys = fieldnames(stage);
for k = 1:numel(keys)
    entry = stage.(keys{k});
    if isfield(entry, "err")
        fprintf(2, '  %s / %s failed: %s\n', char(stage_name), keys{k}, entry.err);
    end
end
end

function tag = i_project_tag(project_file)
[parent_dir, name, ~] = fileparts(char(project_file));
[~, parent_name] = fileparts(parent_dir);
if isempty(parent_name)
    raw_tag = name;
else
    raw_tag = [parent_name, '_', name];
end
tag = regexprep(raw_tag, '[^A-Za-z0-9_]+', '_');
tag = regexprep(tag, '^_+|_+$', '');
if isempty(tag)
    tag = 'project';
end
end

function tag = i_snr_tag(snr_db)
tag = char(string(snr_db));
tag = regexprep(tag, '-', 'minus');
tag = regexprep(tag, '\.', 'p');
tag = regexprep(tag, '[^A-Za-z0-9_]+', '_');
end
