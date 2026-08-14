function results = run(config)
%RUN  Convert a Duneuro export folder to Zeffiro .mat files (no session import).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   results = run(config)
%
%   If config is omitted, uses get_default_config (input_folder 'data/exported',
%   output_folder 'data/converted'). validate_config must pass. Writes
%   tetra_mesh.mat (hex→tet via zef_hexa_to_tetra), source_space.mat, optional
%   resection_points.mat, and EEG/MEG L / measurements / sensors according to
%   config.process_eeg / process_meg / process_resection_points.
%
%   invert_domain_labels (default true) remaps hex labels. Paths are relative
%   to pwd. Does not start Zeffiro; if base workspace has zef, initializes
%   databank only. For session import see import_duneuro_project.
%
%   results: .success, .errors, .warnings, .processed_files, .config.
%
%   See also get_default_config, import_duneuro_project, convert_mesh.
%

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
