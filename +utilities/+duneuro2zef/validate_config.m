% validate_config.m
%
% Validates the configuration structure and ensures all required fields are
% present with valid values. Creates missing directories if needed.
%
% Input:
%   config - Configuration structure to validate
%
% Output:
%   config - Validated configuration structure (with defaults filled in)
%   is_valid - Logical indicating if configuration is valid
%   errors - Cell array of error messages (empty if valid)
%
% Usage:
%   [config, is_valid, errors] = utilities.duneuro2zef.validate_config(config);
%
% See also: get_default_config.m, run.m

function [config, is_valid, errors] = validate_config(config)

    errors = {};
    is_valid = true;
    
    % Get default config for comparison
    default_config = utilities.duneuro2zef.get_default_config();
    
    % Validate and set defaults for file paths
    if ~isfield(config, 'input_folder') || isempty(config.input_folder)
        config.input_folder = default_config.input_folder;
    end
    if ~isfield(config, 'output_folder') || isempty(config.output_folder)
        config.output_folder = default_config.output_folder;
    end
    
    % Ensure paths use fullfile for cross-platform compatibility
    config.input_folder = fullfile(config.input_folder);
    config.output_folder = fullfile(config.output_folder);
    
    % Check if input folder exists
    if ~isfolder(config.input_folder)
        errors{end+1} = sprintf('Input folder does not exist: %s', config.input_folder);
        is_valid = false;
    end
    
    % Validate verbose flag early (needed for output folder creation message)
    if ~isfield(config, 'verbose')
        config.verbose = default_config.verbose;
    end
    
    % Create output folder if it doesn't exist
    if ~isfolder(config.output_folder)
        try
            mkdir(config.output_folder);
            if config.verbose
                fprintf('Created output folder: %s\n', config.output_folder);
            end
        catch ME
            errors{end+1} = sprintf('Could not create output folder %s: %s', ...
                config.output_folder, ME.message);
            is_valid = false;
        end
    end
    
    % Validate file names (set defaults if missing)
    if ~isfield(config, 'files')
        config.files = default_config.files;
    else
        file_fields = fieldnames(default_config.files);
        for i = 1:length(file_fields)
            if ~isfield(config.files, file_fields{i})
                config.files.(file_fields{i}) = default_config.files.(file_fields{i});
            end
        end
    end
    
    % Validate processing options
    if ~isfield(config, 'process_eeg')
        config.process_eeg = default_config.process_eeg;
    end
    if ~isfield(config, 'process_meg')
        config.process_meg = default_config.process_meg;
    end
    if ~isfield(config, 'process_resection_points')
        config.process_resection_points = default_config.process_resection_points;
    end
    if ~isfield(config, 'invert_domain_labels')
        config.invert_domain_labels = default_config.invert_domain_labels;
    end
    % verbose already validated above
    if ~isfield(config, 'continue_on_error')
        config.continue_on_error = default_config.continue_on_error;
    end
    
    % Validate domain configuration
    if ~isfield(config, 'domain_labels')
        config.domain_labels = default_config.domain_labels;
    elseif ~isfield(config.domain_labels, 'brain')
        config.domain_labels.brain = default_config.domain_labels.brain;
    end
    
    % Validate EEG configuration
    if ~isfield(config, 'eeg')
        config.eeg = default_config.eeg;
    else
        if ~isfield(config.eeg, 'channel_indices')
            config.eeg.channel_indices = default_config.eeg.channel_indices;
        end
        if ~isfield(config.eeg, 'channel_path')
            config.eeg.channel_path = default_config.eeg.channel_path;
        end
        if ~isfield(config.eeg, 'measurement_field')
            config.eeg.measurement_field = default_config.eeg.measurement_field;
        end
    end
    
    % Validate MEG configuration
    if ~isfield(config, 'meg')
        config.meg = default_config.meg;
    else
        if ~isfield(config.meg, 'max_channels')
            config.meg.max_channels = default_config.meg.max_channels;
        end
        if ~isfield(config.meg, 'use_magnetometers')
            config.meg.use_magnetometers = default_config.meg.use_magnetometers;
        end
        if ~isfield(config.meg, 'measurement_field')
            config.meg.measurement_field = default_config.meg.measurement_field;
        end
    end
    
    % Validate source space configuration
    if ~isfield(config, 'source_space')
        config.source_space = default_config.source_space;
    elseif ~isfield(config.source_space, 'priority')
        config.source_space.priority = default_config.source_space.priority;
    end
    
    % Validate mesh options
    if ~isfield(config, 'mesh')
        config.mesh = default_config.mesh;
    elseif ~isfield(config.mesh, 'save_brain_ind')
        config.mesh.save_brain_ind = default_config.mesh.save_brain_ind;
    end
    
    % Validate output file names
    if ~isfield(config, 'output')
        config.output = default_config.output;
    else
        output_fields = fieldnames(default_config.output);
        for i = 1:length(output_fields)
            if ~isfield(config.output, output_fields{i})
                config.output.(output_fields{i}) = default_config.output.(output_fields{i});
            end
        end
    end
    
    % Type validation
    if ~islogical(config.process_eeg)
        errors{end+1} = 'config.process_eeg must be logical';
        is_valid = false;
    end
    if ~islogical(config.process_meg)
        errors{end+1} = 'config.process_meg must be logical';
        is_valid = false;
    end
    if ~isnumeric(config.domain_labels.brain) || ~isscalar(config.domain_labels.brain)
        errors{end+1} = 'config.domain_labels.brain must be a numeric scalar';
        is_valid = false;
    end
    if ~isnumeric(config.meg.max_channels) || ~isscalar(config.meg.max_channels) || config.meg.max_channels < 1
        errors{end+1} = 'config.meg.max_channels must be a positive numeric scalar';
        is_valid = false;
    end

end
