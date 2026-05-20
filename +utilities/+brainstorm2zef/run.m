function results = run(config)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.run — Run.
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
% Zef fields (observed):
%   zef.domain_labels (read)
%   zef.name_tags (read)
%   zef.nodes (read)
%   zef.tetra (read)
%
% Calls (project):
%   utilities.brainstorm2zef.run
%   utilities.brainstorm2zef.zef_bst_create_project
%   utilities.brainstorm2zef.zef_bst_get_settings
%   utilities.brainstorm2zef.zef_bst_validate_environment
%   zef_bst_edit_project
%   zef_close_all
%   zef_create_finite_element_mesh
%   zef_save
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[results] = utilities.brainstorm2zef.run(config)` with project root and `src` on the path.
% --- End Zeffiro documentation header

results = struct();
results.success = false;
results.zef = [];
results.mesh_data = struct('nodes', [], 'tetra', [], 'name_tags', {});
results.errors = {};
results.warnings = {};
results.config = [];
results.processing_time = 0;

start_time = tic;

% Use default configuration if not provided
if nargin < 1 || isempty(config)
    config = struct();
end

% Validate and set default configuration values
config = validate_and_set_defaults(config);

% Store validated configuration
results.config = config;

% Step 1: Validate Brainstorm environment
try
    [is_valid, error_msg] = utilities.brainstorm2zef.zef_bst_validate_environment();
    if ~is_valid
        results.errors{end+1} = sprintf('Brainstorm environment validation failed: %s', error_msg);
        results.processing_time = toc(start_time);
        return;
    end
catch ME
    results.errors{end+1} = sprintf('Failed to validate Brainstorm environment: %s', ME.message);
    results.processing_time = toc(start_time);
    return;
end

% Step 2: Load and merge settings
try
    zef_bst = utilities.brainstorm2zef.zef_bst_get_settings(config.settings_file_name, config.zef_bst);
    
    % Override settings from config if provided
    if isfield(config, 'verbose')
        zef_bst.verbose_mode = config.verbose;
    end
    if isfield(config, 'use_gpu')
        zef_bst.use_gpu = config.use_gpu;
    end
    if isfield(config, 'parallel_processes')
        zef_bst.parallel_processes = config.parallel_processes;
    end
    if isfield(config, 'subject_struct')
        zef_bst.subject_struct = config.subject_struct;
    end
    if isfield(config, 'subject_folder')
        zef_bst.subject_folder = config.subject_folder;
    end
    if isfield(config, 'save_project')
        zef_bst.save_project = config.save_project;
    elseif ~isempty(config.project_file_name)
        % Auto-set save_project if project_file_name is provided
        zef_bst.save_project = true;
    end
    
catch ME
    results.errors{end+1} = sprintf('Failed to load settings: %s', ME.message);
    results.processing_time = toc(start_time);
    return;
end

% Step 3: Initialize Zeffiro Interface
try
    zef = zeffiro_interface('start_mode', 'nodisplay', ...
        'verbose_mode', zef_bst.verbose_mode, ...
        'use_gpu', zef_bst.use_gpu, ...
        'parallel_processes', zef_bst.parallel_processes, ...
        'always_show_waitbar', zef_bst.always_show_waitbar);
catch ME
    results.errors{end+1} = sprintf('Failed to initialize Zeffiro Interface: %s', ME.message);
    results.processing_time = toc(start_time);
    return;
end

% Step 4: Create project from Brainstorm data
try
    if config.verbose
        fprintf('Creating Zeffiro project from Brainstorm data...\n');
    end
    
    zef = utilities.brainstorm2zef.zef_bst_create_project(...
        config.settings_file_name, ...
        [], ...  % Don't save yet, we'll save at the end if requested
        config.run_type, ...
        config.input_mode, ...
        zef_bst, ...
        zef);
    
    if config.verbose
        fprintf('Project created successfully.\n');
    end
    
catch ME
    results.errors{end+1} = sprintf('Failed to create project: %s', ME.message);
    try
        zef_close_all(zef);
    catch
        % Ignore cleanup errors
    end
    results.processing_time = toc(start_time);
    return;
end

% Step 5: Generate finite element mesh
try
    if config.verbose
        fprintf('Generating finite element mesh...\n');
    end
    
    zef = zef_create_finite_element_mesh(zef);
    
    if config.verbose
        fprintf('Mesh generation completed.\n');
    end
    
catch ME
    results.errors{end+1} = sprintf('Failed to generate finite element mesh: %s', ME.message);
    try
        zef_close_all(zef);
    catch
        % Ignore cleanup errors
    end
    results.processing_time = toc(start_time);
    return;
end

% Step 6: Extract mesh data
try
    if isfield(zef, 'nodes') && ~isempty(zef.nodes)
        % Convert from millimeters (Zeffiro) to meters (Brainstorm compatibility)
        results.mesh_data.nodes = zef.nodes / zef_bst.unit_conversion;
    else
        results.warnings{end+1} = 'Mesh nodes are empty';
    end
    
    if isfield(zef, 'tetra') && isfield(zef, 'domain_labels')
        results.mesh_data.tetra = [zef.tetra zef.domain_labels];
    else
        results.warnings{end+1} = 'Mesh tetrahedra or domain labels are missing';
    end
    
    if isfield(zef, 'name_tags') && ~isempty(zef.name_tags)
        results.mesh_data.name_tags = zef.name_tags(1:end-1);
    else
        results.warnings{end+1} = 'Compartment name tags are missing';
    end
    
    if config.verbose
        fprintf('Mesh data extracted: %d nodes, %d tetrahedra, %d compartments\n', ...
            size(results.mesh_data.nodes, 1), ...
            size(results.mesh_data.tetra, 1), ...
            length(results.mesh_data.name_tags));
    end
    
catch ME
    results.warnings{end+1} = sprintf('Failed to extract mesh data: %s', ME.message);
end

% Step 7: Save project if requested
if zef_bst.save_project && ~isempty(config.project_file_name)
    try
        [file_path, file_name] = fileparts(config.project_file_name);
        if isempty(file_path)
            file_path = pwd;
        end
        
        if config.verbose
            fprintf('Saving project to %s...\n', fullfile(file_path, [file_name '.mat']));
        end
        
        zef_save(zef, file_name, file_path, 1);
        
        if config.verbose
            fprintf('Project saved successfully.\n');
        end
        
    catch ME
        results.warnings{end+1} = sprintf('Failed to save project file: %s', ME.message);
    end
end

% Store Zeffiro structure (user may want to continue working with it)
results.zef = zef;

% Mark as successful if no critical errors occurred
results.success = isempty(results.errors);

% Calculate processing time
results.processing_time = toc(start_time);

% Final summary
if config.verbose
    if results.success
        fprintf('\n=== Conversion Pipeline Completed Successfully ===\n');
        fprintf('Processing time: %.2f seconds\n', results.processing_time);
        if ~isempty(results.warnings)
            fprintf('Warnings: %d\n', length(results.warnings));
        end
    else
        fprintf('\n=== Conversion Pipeline Failed ===\n');
        fprintf('Errors: %d\n', length(results.errors));
        for i = 1:length(results.errors)
            fprintf('  %d. %s\n', i, results.errors{i});
        end
    end
end

% Note: We don't close zef here to allow user to continue working with it
% User should call zef_close_all(results.zef) when done

end

%% Helper function to validate and set default configuration
function config = validate_and_set_defaults(config)

% Default settings file name
if ~isfield(config, 'settings_file_name') || isempty(config.settings_file_name)
    config.settings_file_name = 'zef_bst_default';
end

% Default project file name (empty = don't save)
if ~isfield(config, 'project_file_name')
    config.project_file_name = '';
end

% Default run type (1 = Fresh start)
if ~isfield(config, 'run_type') || isempty(config.run_type)
    config.run_type = 1;
else
    if ~ismember(config.run_type, [1, 2])
        error('run_type must be 1 (fresh start) or 2 (import compartments). For existing projects, use zef_bst_edit_project() or zeffiro_interface() directly.');
    end
end

% Default input mode (1 = Use input files)
if ~isfield(config, 'input_mode') || isempty(config.input_mode)
    config.input_mode = 1;
else
    if ~ismember(config.input_mode, [1, 2])
        error('input_mode must be 1 (use input files) or 2 (ignore input files)');
    end
end

% Default verbose mode
if ~isfield(config, 'verbose') || isempty(config.verbose)
    config.verbose = true;
end

% Default save_project (auto-set based on project_file_name if not specified)
if ~isfield(config, 'save_project')
    config.save_project = ~isempty(config.project_file_name);
end

% Optional: subject_struct and subject_folder (will use Brainstorm defaults if not provided)
if ~isfield(config, 'subject_struct')
    config.subject_struct = [];
end

if ~isfield(config, 'subject_folder')
    config.subject_folder = '';
end

% Optional: zef_bst overrides
if ~isfield(config, 'zef_bst')
    config.zef_bst = struct();
end

% Optional: GPU and parallel processing settings
if ~isfield(config, 'use_gpu')
    config.use_gpu = [];
end

if ~isfield(config, 'parallel_processes')
    config.parallel_processes = [];
end

end
