% process_sensors.m
%
% Processes sensor configurations for EEG or MEG.
%
% Input:
%   config - Configuration structure
%   modality - 'EEG' or 'MEG'
%   channel_indices - For EEG: indices into sensor array for used channels.
%                     For MEG: number of channels to use (scalar) or empty for all.
%
% Output:
%   success - Logical indicating success
%   error_msg - Error message if failed (empty if successful)
%
% Usage:
%   [success, error_msg] = utilities.duneuro2zef.process_sensors(config, 'EEG', channel_indices);
%   [success, error_msg] = utilities.duneuro2zef.process_sensors(config, 'MEG', max_channels);
%
% See also: run.m, process_eeg_data.m, process_meg_data.m

function [success, error_msg] = process_sensors(config, modality, channel_indices)

    success = false;
    error_msg = '';
    
    try
        % Load sensor configuration
        sensor_path = fullfile(config.input_folder, config.files.sensors);
        if ~isfile(sensor_path)
            error_msg = sprintf('Sensor file not found: %s', sensor_path);
            return;
        end
        
        if config.verbose
            fprintf('Loading sensor configuration from: %s\n', sensor_path);
        end
        
        sensor_data = load(sensor_path);
        
        % Extract sensor structure (handle different variable names)
        if isfield(sensor_data, 'sensors')
            sensors = sensor_data.sensors;
        else
            fields = fieldnames(sensor_data);
            if length(fields) == 1
                sensors = sensor_data.(fields{1});
            else
                error_msg = 'Could not identify sensor structure in file';
                return;
            end
        end
        
        % Process based on modality
        switch upper(modality)
            case 'EEG'
                % Extract EEG electrode positions
                if ~isfield(sensors, 'elec') || ~isfield(sensors.elec, 'chanpos')
                    error_msg = 'Sensor structure must contain elec.chanpos for EEG';
                    return;
                end
                
                if ~isempty(channel_indices)
                    points = sensors.elec.chanpos(channel_indices, :);
                else
                    points = sensors.elec.chanpos;
                end
                
                imaging_method_name = 'EEG';
                
                % Construct affine transformation if available
                if isfield(sensors, 'rot') && isfield(sensors, 'transl')
                    affine_transform = {[sensors.rot' -sensors.transl; 0 0 0 1]};
                else
                    affine_transform = {eye(4)};
                    if config.verbose
                        fprintf('Warning: No affine transformation found, using identity\n');
                    end
                end
                
                % Save EEG sensors
                output_path = fullfile(config.output_folder, config.output.sensors_eeg);
                if config.verbose
                    fprintf('Saving EEG sensors to: %s\n', output_path);
                end
                save(output_path, 'points', 'affine_transform', 'imaging_method_name', '-v7.3');
                
            case 'MEG'
                % Extract MEG sensor positions and orientations
                if ~isfield(sensors, 'grad')
                    error_msg = 'Sensor structure must contain grad field for MEG';
                    return;
                end
                
                if ~isfield(sensors.grad, 'chanpos')
                    error_msg = 'Sensor structure must contain grad.chanpos for MEG';
                    return;
                end
                
                % Filter sensors to match number of channels used in lead field
                if ~isempty(channel_indices) && isnumeric(channel_indices) && isscalar(channel_indices)
                    % channel_indices is the number of channels to use
                    max_channels = min(channel_indices, size(sensors.grad.chanpos, 1));
                    points = sensors.grad.chanpos(1:max_channels, :);
                    
                    if isfield(sensors.grad, 'chanori')
                        if size(sensors.grad.chanori, 1) >= max_channels
                            directions = sensors.grad.chanori(1:max_channels, :);
                        else
                            directions = sensors.grad.chanori;
                            if config.verbose
                                fprintf('Warning: Sensor orientations have fewer channels than positions\n');
                            end
                        end
                    else
                        directions = [];
                        if config.verbose
                            fprintf('Warning: No sensor orientations found\n');
                        end
                    end
                else
                    % Use all sensors
                    points = sensors.grad.chanpos;
                    
                    if isfield(sensors.grad, 'chanori')
                        directions = sensors.grad.chanori;
                    else
                        directions = [];
                        if config.verbose
                            fprintf('Warning: No sensor orientations found\n');
                        end
                    end
                end
                
                imaging_method_name = 'MEG magnetometer';
                
                % Reuse affine transformation from EEG if available
                if isfield(sensors, 'rot') && isfield(sensors, 'transl')
                    affine_transform = {[sensors.rot' -sensors.transl; 0 0 0 1]};
                else
                    affine_transform = {eye(4)};
                    if config.verbose
                        fprintf('Warning: No affine transformation found, using identity\n');
                    end
                end
                
                % Save MEG sensors
                output_path = fullfile(config.output_folder, config.output.sensors_meg);
                if config.verbose
                    fprintf('Saving MEG sensors to: %s\n', output_path);
                end
                
                if ~isempty(directions)
                    save(output_path, 'points', 'directions', 'affine_transform', 'imaging_method_name', '-v7.3');
                else
                    save(output_path, 'points', 'affine_transform', 'imaging_method_name', '-v7.3');
                end
                
            otherwise
                error_msg = sprintf('Unknown modality: %s (must be EEG or MEG)', modality);
                return;
        end
        
        success = true;
        
    catch ME
        error_msg = sprintf('Error processing %s sensors: %s', modality, ME.message);
        if config.verbose
            fprintf('Error: %s\n', error_msg);
        end
    end

end
