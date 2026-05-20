% process_source_space.m
%
% Processes source space grid positions from Duneuro export.
%
% Input:
%   config - Configuration structure
%
% Output:
%   success - Logical indicating success
%   error_msg - Error message if failed (empty if successful)
%
% Usage:
%   [success, error_msg] = utilities.duneuro2zef.process_source_space(config);
%
% See also: run.m, get_default_config.m

function [success, error_msg] = process_source_space(config)

    success = false;
    error_msg = '';
    
    try
        % Find source space file (supports patterns)
        [source_path, source_file] = utilities.duneuro2zef.find_files(...
            config.files.source_space, config.input_folder, config.source_space.priority);
        
        if isempty(source_path)
            error_msg = sprintf('Source space file not found: %s', config.files.source_space);
            return;
        end
        
        if config.verbose
            fprintf('Loading source space from: %s\n', source_path);
        end
        
        % Load source space file
        source_data = load(source_path);
        
        % Extract source positions (handle different variable names)
        if isfield(source_data, 'source_grid')
            source_positions = source_data.source_grid;
        elseif isfield(source_data, 'source_positions')
            source_positions = source_data.source_positions;
        elseif isfield(source_data, 'positions')
            source_positions = source_data.positions;
        else
            % Try to find Nx3 matrix
            fields = fieldnames(source_data);
            found = false;
            for i = 1:length(fields)
                data = source_data.(fields{i});
                if isnumeric(data) && size(data, 2) == 3
                    source_positions = data;
                    found = true;
                    break;
                end
            end
            if ~found
                error_msg = 'Could not identify source positions in file';
                return;
            end
        end
        
        % Validate source positions (must be Nx3)
        if ~isnumeric(source_positions) || size(source_positions, 2) ~= 3
            error_msg = 'Source positions must be an Nx3 numeric matrix';
            return;
        end
        if size(source_positions, 1) == 0
            error_msg = 'Source positions matrix is empty';
            return;
        end
        
        if config.verbose
            fprintf('Found %d source positions\n', size(source_positions, 1));
        end
        
        % Save source space
        output_path = fullfile(config.output_folder, config.output.source_space);
        if config.verbose
            fprintf('Saving source space to: %s\n', output_path);
        end
        
        save(output_path, 'source_positions', '-v7.3');
        
        success = true;
        
    catch ME
        error_msg = sprintf('Error processing source space: %s', ME.message);
        if config.verbose
            fprintf('Error: %s\n', error_msg);
        end
    end

end
