% import_duneuro_project.m
%
% Main entry point for importing a complete Duneuro project into Zeffiro Interface.
% This function orchestrates the entire import pipeline:
%   1. Converts Duneuro files to Zeffiro format
%   2. Imports converted data into Zeffiro Interface (via .zef file)
%   3. Configuration is handled automatically by the .zef file (line 19)
%
% The function can work in two modes:
%   - Standalone: Converts files only (without Zeffiro Interface context)
%   - Integrated: Full import into Zeffiro Interface (requires ZI to be running)
%
% Note: Step 3 (configuration) is executed by Duneuro2Zeffiro_settings() which
% is called automatically from the .zef file line 19, so this function does not
% call it separately to avoid double configuration.
%
% Input:
%   config - (Optional) Configuration structure. If not provided, uses defaults.
%            See get_default_config.m for available options.
%   import_to_zeffiro - (Optional) Logical. If true, imports data into Zeffiro
%                       Interface after conversion. Default: true if ZI is running.
%
% Output:
%   results - Structure containing:
%       .success - Logical indicating overall success
%       .errors - Cell array of error messages
%       .warnings - Cell array of warning messages
%       .processed_files - Cell array of successfully processed files
%       .config - Configuration used (validated)
%       .import_success - Logical indicating if import step succeeded
%
% Usage:
%   % Full pipeline (convert + import)
%   results = utilities.duneuro2zef.import_duneuro_project();
%
%   % Custom configuration
%   config = utilities.duneuro2zef.get_default_config();
%   config.input_folder = 'my_data/duneuro_export';
%   results = utilities.duneuro2zef.import_duneuro_project(config);
%
%   % Convert only (no import)
%   results = utilities.duneuro2zef.import_duneuro_project([], false);
%
% See also: run.m, get_default_config.m, Duneuro2Zeffiro_import.zef

function results = import_duneuro_project(config, import_to_zeffiro)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.import_duneuro_project — Import duneuro project.
%
% Purpose:
%   Import duneuro project.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   config
%   import_to_zeffiro
%
% Outputs:
%   results
%
% Zef fields (observed):
%   zef.file (read, write)
%   zef.file_path (read, write)
%   zef.new_empty_project (read, write)
%
% Calls (project):
%   utilities.duneuro2zef.get_default_config
%   utilities.duneuro2zef.import_duneuro_project
%   utilities.duneuro2zef.run
%   zef_build_compartment_table
%   zef_import_segmentation
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[results] = utilities.duneuro2zef.import_duneuro_project(config, import_to_zeffiro)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    results = struct();
    results.success = false;
    results.errors = {};
    results.warnings = {};
    results.processed_files = {};
    results.config = [];
    results.import_success = false;
    
    % Use default configuration if not provided
    if nargin < 1 || isempty(config)
        config = utilities.duneuro2zef.get_default_config();
    end
    
    % Determine if we should import to Zeffiro Interface
    if nargin < 2 || isempty(import_to_zeffiro)
        % Auto-detect: try to check if ZI is running
        try
            import_to_zeffiro = evalin('base', 'exist(''zef'', ''var'')');
        catch
            import_to_zeffiro = false;
        end
    end
    
    %% Step 1: Convert Duneuro files to Zeffiro format
    if config.verbose
        fprintf('\n========================================\n');
        fprintf('Duneuro to Zeffiro Interface Import\n');
        fprintf('========================================\n\n');
        fprintf('Step 1/3: Converting Duneuro files...\n');
    end
    
    conversion_results = utilities.duneuro2zef.run(config);
    results.config = conversion_results.config;
    results.processed_files = conversion_results.processed_files;
    results.errors = conversion_results.errors;
    results.warnings = conversion_results.warnings;
    
    if ~conversion_results.success
        results.success = false;
        if config.verbose
            fprintf('\nConversion failed. Aborting import.\n');
        end
        return;
    end
    
    if config.verbose
        fprintf('\n✓ Conversion completed successfully\n');
    end
    
    %% Step 2: Import into Zeffiro Interface (if requested and available)
    if import_to_zeffiro
        if config.verbose
            fprintf('\nStep 2/3: Importing data into Zeffiro Interface...\n');
        end
        
        try
            % Check if Zeffiro Interface is available
            if ~evalin('base', 'exist(''zef'', ''var'')')
                error('Zeffiro Interface structure ''zef'' not found in base workspace');
            end
            
            % Get import file path (relative to this function's location)
            [package_folder, ~, ~] = fileparts(mfilename('fullpath'));
            import_file = fullfile(package_folder, 'Duneuro2Zeffiro_import.zef');
            
            if ~isfile(import_file)
                error('Import file not found: %s', import_file);
            end
            
            % Get the folder containing the import file
            [import_folder, import_filename, ~] = fileparts(import_file);
            
            % IMPORTANT: The .zef file uses relative paths (data/converted/)
            % which are resolved relative to the CURRENT WORKING DIRECTORY (pwd)
            % when zef_import_segmentation processes them.
            % 
            % We need to verify that the output folder exists relative to pwd.
            % If config uses relative paths, they should be relative to pwd.
            output_folder_check = fullfile(config.output_folder);
            if ~isfolder(output_folder_check)
                error(['Output folder not found: %s\n' ...
                    'Please ensure you are in the project root directory where data/ folder exists.\n' ...
                    'Current working directory: %s'], output_folder_check, pwd);
            end
            
            % Import using Zeffiro Interface's import system
            zef = evalin('base', 'zef');
            zef.file = [import_filename, '.zef'];
            zef.file_path = import_folder;
            zef.new_empty_project = 0;  % Import to existing project
            
            if config.verbose
                fprintf('Loading import configuration from: %s\n', import_file);
                fprintf('Working directory (base for relative paths): %s\n', pwd);
                fprintf('Output folder: %s\n', output_folder_check);
            end
            
            zef = zef_import_segmentation(zef);
            zef = zef_build_compartment_table(zef);
            
            % Update base workspace
            assignin('base', 'zef', zef);
            
            results.import_success = true;
            
            if config.verbose
                fprintf('✓ Import completed successfully\n');
                fprintf('  Note: Configuration step (Duneuro2Zeffiro_settings) was executed by .zef file\n');
            end
            
        catch ME
            results.import_success = false;
            error_msg = sprintf('Error importing into Zeffiro Interface: %s', ME.message);
            results.errors{end+1} = error_msg;
            results.warnings{end+1} = 'Data was converted but not imported into Zeffiro Interface';
            
            if config.verbose
                fprintf('✗ Import failed: %s\n', ME.message);
                fprintf('  Note: Files were converted successfully and are available in: %s\n', ...
                    config.output_folder);
            end
        end
    else
        if config.verbose
            fprintf('\nStep 2/3: Skipping import (not requested or ZI not available)\n');
            fprintf('  Converted files are available in: %s\n', config.output_folder);
            fprintf('  To import later, use Zeffiro Interface import menu with:\n');
            fprintf('    %s\n', fullfile(fileparts(mfilename('fullpath')), 'Duneuro2Zeffiro_import.zef'));
        end
    end
    
    % Note: Step 3 (Configuration) is handled by the .zef file (line 19)
    % which calls Duneuro2Zeffiro_settings() automatically after import
    % No need to call it again here to avoid double configuration
    
    %% Final summary
    results.success = conversion_results.success && results.import_success;
    
    if config.verbose
        fprintf('\n========================================\n');
        fprintf('Import Pipeline Summary\n');
        fprintf('========================================\n');
        fprintf('Conversion: %s\n', iif(conversion_results.success, '✓ Success', '✗ Failed'));
        fprintf('Import:     %s\n', iif(results.import_success, '✓ Success', '✗ Failed/Skipped'));
        fprintf('Overall:    %s\n', iif(results.success, '✓ Success', '⚠ Partial/Failed'));
        
        if ~isempty(results.errors)
            fprintf('\nErrors:\n');
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

% Helper function for inline if-else
function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
