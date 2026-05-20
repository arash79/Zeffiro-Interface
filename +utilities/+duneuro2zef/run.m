% run.m
%
% Main conversion function for importing Duneuro-generated FEM meshes and
% associated data into Zeffiro Interface format. This function provides a
% programmatic interface with comprehensive error handling and validation.
%
% Input:
%   config - (Optional) Configuration structure. If not provided, uses defaults.
%            See get_default_config.m for available options.
%
% Output:
%   results - Structure containing:
%       .success - Logical indicating overall success
%       .errors - Cell array of error messages
%       .warnings - Cell array of warning messages
%       .processed_files - Cell array of successfully processed files
%       .config - Configuration used (validated)
%
% Usage:
%   % Use default configuration
%   results = utilities.duneuro2zef.run();
%
%   % Customize configuration
%   config = utilities.duneuro2zef.get_default_config();
%   config.input_folder = 'my_data/duneuro_export';
%   config.output_folder = 'my_data/zeffiro_import';
%   results = utilities.duneuro2zef.run(config);
%
% See also: get_default_config.m, validate_config.m

function results = run(config)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.run — Run.
%
% Purpose:
%   Run.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   config
%
% Outputs:
%   results
%
% Calls (project):
%   utilities.duneuro2zef.convert_mesh
%   utilities.duneuro2zef.get_default_config
%   utilities.duneuro2zef.process_eeg_data
%   utilities.duneuro2zef.process_meg_data
%   utilities.duneuro2zef.process_resection_points
%   utilities.duneuro2zef.process_source_space
%   utilities.duneuro2zef.run
%   utilities.duneuro2zef.validate_config
%   zef_start_dataBank
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[results] = utilities.duneuro2zef.run(config)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    results = struct();
    results.success = false;
    results.errors = {};
    results.warnings = {};
    results.processed_files = {};
    results.config = [];
    
    % Use default configuration if not provided
    if nargin < 1 || isempty(config)
        config = utilities.duneuro2zef.get_default_config();
    end
    
    % Validate configuration
    [config, is_valid, validation_errors] = utilities.duneuro2zef.validate_config(config);
    results.config = config;
    
    if ~is_valid
        results.errors = validation_errors;
        if config.verbose
            fprintf('Configuration validation failed:\n');
            for i = 1:length(validation_errors)
                fprintf('  - %s\n', validation_errors{i});
            end
        end
        return;
    end
    
    if config.verbose
        fprintf('\n=== Duneuro to Zeffiro Interface Conversion ===\n');
        fprintf('Input folder: %s\n', config.input_folder);
        fprintf('Output folder: %s\n', config.output_folder);
        fprintf('\n');
    end
    
    % Initialize databank if in Zeffiro Interface context
    try
        if evalin('base', 'exist(''zef'', ''var'')')
            zef = evalin('base', 'zef');
            zef = zef_start_dataBank(zef);
            assignin('base', 'zef', zef);
        end
    catch
        % Not in Zeffiro Interface context, continue without databank
        if config.verbose
            fprintf('Note: Not in Zeffiro Interface context, skipping databank initialization\n');
        end
    end
    
    % Process mesh conversion
    if config.verbose
        fprintf('\n=== Converting Mesh ===\n');
    end
    [success, error_msg] = utilities.duneuro2zef.convert_mesh(config);
    if success
        results.processed_files{end+1} = config.output.mesh;
    else
        results.errors{end+1} = error_msg;
        if ~config.continue_on_error
            return;
        end
    end
    
    % Process source space
    if config.verbose
        fprintf('\n=== Processing Source Space ===\n');
    end
    [success, error_msg] = utilities.duneuro2zef.process_source_space(config);
    if success
        results.processed_files{end+1} = config.output.source_space;
    else
        results.errors{end+1} = error_msg;
        if ~config.continue_on_error
            return;
        end
    end
    
    % Process resection points (optional)
    if config.process_resection_points
        if config.verbose
            fprintf('\n=== Processing Resection Points ===\n');
        end
        [success, error_msg] = utilities.duneuro2zef.process_resection_points(config);
        if success
            results.processed_files{end+1} = config.output.resection_points;
        else
            results.warnings{end+1} = error_msg;  % Warning, not error (optional)
        end
    end
    
    % Process EEG data
    if config.process_eeg
        [success, error_msg] = utilities.duneuro2zef.process_eeg_data(config);
        if success
            results.processed_files{end+1} = config.output.leadfield_eeg;
            results.processed_files{end+1} = config.output.measurements_eeg;
            results.processed_files{end+1} = config.output.sensors_eeg;
        else
            results.errors{end+1} = error_msg;
            if ~config.continue_on_error
                return;
            end
        end
    end
    
    % Process MEG data
    if config.process_meg
        [success, error_msg] = utilities.duneuro2zef.process_meg_data(config);
        if success
            results.processed_files{end+1} = config.output.leadfield_meg;
            results.processed_files{end+1} = config.output.measurements_meg;
            results.processed_files{end+1} = config.output.sensors_meg;
        else
            results.errors{end+1} = error_msg;
            if ~config.continue_on_error
                return;
            end
        end
    end
    
    % Determine overall success
    results.success = isempty(results.errors);
    
    % Print summary
    if config.verbose
        fprintf('\n=== Conversion Summary ===\n');
        if results.success
            fprintf('Conversion completed successfully!\n');
            fprintf('Processed %d files:\n', length(results.processed_files));
            for i = 1:length(results.processed_files)
                fprintf('  - %s\n', results.processed_files{i});
            end
        else
            fprintf('Conversion completed with errors:\n');
            for i = 1:length(results.errors)
                fprintf('  - %s\n', results.errors{i});
            end
        end
        
        if ~isempty(results.warnings)
            fprintf('\nWarnings:\n');
            for i = 1:length(results.warnings)
                fprintf('  - %s\n', results.warnings{i});
            end
        end
        fprintf('\n');
    end

end
