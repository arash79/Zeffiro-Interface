%COMPARTMENT_WISE  Lab batch: parcellation stats of sensitivity .mat files.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Hard-coded absolute paths (edit before run):
%     modelsPath        /Users/hsc476/Documents/ICBM152_Models
%     sensitivitiesPath /Users/hsc476/Projects/Revision/data
%   Walks sensitivitiesPath/<eloreta|hal1r|hal2r|shal2r>/<head-model>/
%   noise_*/ *.mat expecting sensitivities_with_statistics.<method>
%   (dist_vec_avg/std, angle_vec_*, dispersion_*). Opens each mapped
%   project via zeffiro_interface('open_project', ...), copies the
%   method vector into zef.reconstruction{1}, runs
%   zef_parcellation_time_series, writes CSV under cwd Figures/<tag>/...
%   One-off ICBM152 revision study; those folders are not in this repo.
%

% === Paths ===
modelsPath = '/Users/hsc476/Documents/ICBM152_Models';
sensitivitiesPath = '/Users/hsc476/Projects/Revision/data';

% === Solvers to iterate (top-level subfolders inside `data/`) ===
solvers = ["eloreta", "hal1r", "hal2r", "shal2r"];

% === Evaluation methods (fields of `sensitivities_with_statistics`) ===
methods = ["dist_vec_avg", ...
           "dist_vec_std", ...
           "angle_vec_avg", ...
           "angle_vec_std", ...
           "dispersion_avg", ...
           "dispersion_std"];

% === Outdated head-model folders to skip ===
% The bare sn_ws / sn_wos folders are superseded by the corresponding
% "updated_*" folders below and must NOT be processed.
outdatedFolders = [ ...
    "sn_ws_icbm152_mesh_lead_field_1", ...
    "sn_wos_icbm152_mesh_lead_field_1"];

% === Head-model folder -> base name of the project .mat in modelsPath ===
% The data hierarchy uses lowercase folder names that sometimes carry a
% trailing suffix (e.g. _1, _2) or an "updated_" prefix. These map back
% to the actual project files inside modelsPath. The "Simple" and
% "Naive" configurations are now sourced from the updated folders.
folderToModel = dictionary( ...
    ["fs_ws_complex_icbm152_mesh_lead_field", ...
     "fs_ws_complex_icbm152_no_containers_mesh_lead_field", ...
     "fs_ws_complex_icbm152_no_containers_mesh_lead_field_2", ...
     "fs_ws_complex_icbm152_refined_skull_mesh_lead_field_2", ...
     "fs_ws_simple_icbm152_mesh_lead_field_1", ...
     "updated_fs_ws_simple_icbm152_mesh_updated_lead_field", ...
     "updated_merged_sn_wos_icbm152_mesh_updated_lead_field"], ...
    ["FS_WS_COMPLEX_ICBM152_mesh_lead_field", ...
     "FS_WS_COMPLEX_ICBM152_no_containers_mesh_lead_field", ...
     "FS_WS_COMPLEX_ICBM152_no_containers_mesh_lead_field", ...
     "FS_WS_COMPLEX_ICBM152_refined_skull_mesh_lead_field", ...
     "FS_WS_SIMPLE_ICBM152_mesh_lead_field", ...
     "FS_WS_SIMPLE_ICBM152_mesh_lead_field", ...
     "SN_WOS_ICBM152_mesh_lead_field"]);

% === Head-model folder -> display tag used in output folders/filenames ===
folderToDisplay = dictionary( ...
    ["fs_ws_complex_icbm152_mesh_lead_field", ...
     "fs_ws_complex_icbm152_no_containers_mesh_lead_field", ...
     "fs_ws_complex_icbm152_no_containers_mesh_lead_field_2", ...
     "fs_ws_complex_icbm152_refined_skull_mesh_lead_field_2", ...
     "fs_ws_simple_icbm152_mesh_lead_field_1", ...
     "updated_fs_ws_simple_icbm152_mesh_updated_lead_field", ...
     "updated_merged_sn_wos_icbm152_mesh_updated_lead_field"], ...
    ["Complex", ...
     "Containerless", ...
     "Containerless", ...
     "Refined", ...
     "Hybrid", ...
     "Simple", ...
     "Naive"]);

% === Iterate over solvers ===
for s = 1:numel(solvers)

    solverName = solvers(s);
    solverDir  = fullfile(sensitivitiesPath, char(solverName));

    if ~isfolder(solverDir)
        fprintf('Skipping missing solver folder: %s\n', solverDir);
        continue
    end

    headModelEntries = dir(solverDir);
    headModelEntries = headModelEntries([headModelEntries.isdir] & ...
        ~ismember({headModelEntries.name}, {'.', '..'}));

    % === Iterate over head-model folders ===
    for h = 1:numel(headModelEntries)

        headModelFolder = string(headModelEntries(h).name);

        if ismember(headModelFolder, outdatedFolders)
            fprintf('Skipping outdated head-model folder: %s/%s\n', ...
                solverName, headModelFolder);
            continue
        end

        if ~isKey(folderToModel, headModelFolder)
            fprintf('Skipping unknown head-model folder: %s/%s\n', ...
                solverName, headModelFolder);
            continue
        end

        modelBaseName = folderToModel(headModelFolder);
        modelFileName = char(modelBaseName + ".mat");
        modelPath     = fullfile(modelsPath, modelFileName);

        if ~isfile(modelPath)
            fprintf('Model file not found, skipping: %s\n', modelPath);
            continue
        end

        fprintf('\nLoading base file: %s\n', modelFileName);
        zeffiro_interface('open_project', modelPath);

        headModelTag = folderToDisplay(headModelFolder);
        headModelDir = fullfile(solverDir, char(headModelFolder));

        noiseEntries = dir(headModelDir);
        noiseEntries = noiseEntries([noiseEntries.isdir] & ...
            ~ismember({noiseEntries.name}, {'.', '..'}));

        % === Iterate over noise-level folders ===
        for n = 1:numel(noiseEntries)

            noiseFolder = string(noiseEntries(n).name);
            noiseDir    = fullfile(headModelDir, char(noiseFolder));

            % Strip the leading "noise_" prefix so output names stay
            % consistent with the previous implementation (e.g. "5",
            % "17p5", "30").
            noiseTag = regexprep(noiseFolder, '^noise_', '');

            sensitivityFiles = dir(fullfile(noiseDir, '*.mat'));

            % === Iterate over sensitivity .mat files ===
            for r = 1:numel(sensitivityFiles)

                sensitivityFileName = sensitivityFiles(r).name;
                sensitivityFilePath = fullfile(noiseDir, sensitivityFileName);

                fprintf('\nLoading Inverse Solutions file: %s\n', sensitivityFileName);
                sensitivityData = load(sensitivityFilePath);
                stats = sensitivityData.sensitivities_with_statistics;

                % === Iterate over evaluation methods ===
                for m = 1:numel(methods)

                    methodName = methods(m);

                    if ~isfield(stats, char(methodName))
                        fprintf('Method "%s" missing in %s, skipping.\n', ...
                            methodName, sensitivityFileName);
                        continue
                    end

                    methodValues = stats.(char(methodName));

                    outputDirectory = fullfile('Figures', ...
                        char(headModelTag), char(solverName), ...
                        char(noiseTag), char(methodName));
                    if ~exist(outputDirectory, 'dir')
                        mkdir(outputDirectory);
                    end

                    % ========= Prepare reconstruction vector =========
                    zef.reconstruction = cell(0);
                    zef.reconstruction{1} = zeros(3 * size(zef.source_positions, 1), 1);

                    sensitivityDataLength = length(methodValues);
                    zef.reconstruction{1}(1:sensitivityDataLength) = ...
                        methodValues / sqrt(3);

                    % ======== Prepare Timeseries Data ===========
                    zef.parcellation_time_series_mode = 2; % set to sample instead of amplitude
                    zef.parcellation_time_series = zef_parcellation_time_series([]);

                    % ========== Create the Table ===========
                    nSeries  = length(zef.parcellation_colortable{1}{2});
                    varStats = {'min','max','mean','std','kurtosis','skewness','p25','p50','p75'};
                    varNames = ['Compartment', varStats];
                    varTypes = [{'string'}, repmat({'double'}, 1, numel(varStats))];

                    T = table('Size', [nSeries numel(varNames)], ...
                        'VariableTypes', varTypes, ...
                        'VariableNames', varNames);

                    for j = 1:nSeries
                        x = zef.parcellation_time_series{j};
                        x = x(~isnan(x));                 % ignore NaNs
                        name = string(zef.parcellation_colortable{1}{2}{j});
                        if isempty(x)
                            T{j,:} = NaN(1, numel(varNames));
                            continue
                        end
                        p = prctile(x, [25 50 75]);       % [p25 p50 p75]
                        T{j,:} = [name min(x) max(x) mean(x) std(x,0) kurtosis(x,0) ...
                            skewness(x,0) p(1) p(2) p(3)];
                    end

                    % ============ Saving Results ==============
                    file_name = headModelTag + "_" + solverName + "_" + noiseTag + ...
                        "_" + methodName + "_compartmentwise_errors.csv";
                    writetable(T, fullfile(outputDirectory, char(file_name)));

                end

            end
        end

        zef_close_all

    end
end
