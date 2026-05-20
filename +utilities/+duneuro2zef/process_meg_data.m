% process_meg_data.m
%
% Processes MEG lead fields, measurements, and sensor configurations.
%
% Input:
%   config - Configuration structure
%
% Output:
%   success - Logical indicating success
%   error_msg - Error message if failed (empty if successful)
%
% Usage:
%   [success, error_msg] = utilities.duneuro2zef.process_meg_data(config);
%
% See also: run.m, get_default_config.m, process_sensors.m

function [success, error_msg] = process_meg_data(config)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.process_meg_data — Process meg data.
%
% Purpose:
%   Process meg data.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   config
%
% Outputs:
%   success
%   error_msg
%
% Calls (project):
%   utilities.duneuro2zef.process_meg_data
%   utilities.duneuro2zef.process_sensors
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[success, error_msg]] = utilities.duneuro2zef.process_meg_data(config)` with project root and `src` on the path.
% --- End Zeffiro documentation header


    success = false;
    error_msg = '';
    
    try
        % Check if MEG should be processed
        if ~config.process_meg
            success = true;
            return;
        end
        
        if config.verbose
            fprintf('\n=== Processing MEG Data ===\n');
        end
        
        % Load lead field
        lf_path = fullfile(config.input_folder, config.files.leadfield_meg);
        if ~isfile(lf_path)
            error_msg = sprintf('MEG lead field file not found: %s', lf_path);
            return;
        end
        
        if config.verbose
            fprintf('Loading MEG lead field from: %s\n', lf_path);
        end
        
        lf_data = load(lf_path);
        
        % Extract lead field (handle different variable names)
        if isfield(lf_data, 'LF_MEG')
            LF_MEG = lf_data.LF_MEG;
        elseif isfield(lf_data, 'L')
            LF_MEG = lf_data.L;
        else
            fields = fieldnames(lf_data);
            if length(fields) == 1
                LF_MEG = lf_data.(fields{1});
            else
                error_msg = 'Could not identify lead field in file';
                return;
            end
        end
        
        % Validate lead field
        if ~isnumeric(LF_MEG) || ndims(LF_MEG) ~= 2
            error_msg = 'Lead field must be a 2D numeric matrix';
            return;
        end
        if size(LF_MEG, 1) == 0 || size(LF_MEG, 2) == 0
            error_msg = 'Lead field matrix is empty';
            return;
        end
        
        % Load measurements
        meas_path = fullfile(config.input_folder, config.files.measurements_meg);
        if ~isfile(meas_path)
            error_msg = sprintf('MEG measurements file not found: %s', meas_path);
            return;
        end
        
        if config.verbose
            fprintf('Loading MEG measurements from: %s\n', meas_path);
        end
        
        meas_data = load(meas_path);
        
        % Extract measurement structure (handle different variable names)
        if isfield(meas_data, 'spikeAvg_MEG')
            spikeAvg_MEG = meas_data.spikeAvg_MEG;
        elseif isfield(meas_data, 'meg_data')
            spikeAvg_MEG = meas_data.meg_data;
        else
            fields = fieldnames(meas_data);
            if length(fields) == 1
                spikeAvg_MEG = meas_data.(fields{1});
            else
                error_msg = 'Could not identify measurement structure in file';
                return;
            end
        end
        
        % Extract measurements
        if isfield(spikeAvg_MEG, config.meg.measurement_field)
            measurements = spikeAvg_MEG.(config.meg.measurement_field);
        elseif isfield(spikeAvg_MEG, 'data')
            measurements = spikeAvg_MEG.data;
        else
            error_msg = sprintf('Measurement structure must contain field: %s', config.meg.measurement_field);
            return;
        end
        
        % Apply transformation matrix if available
        if isfield(spikeAvg_MEG, 'grad') && isfield(spikeAvg_MEG.grad, 'tra')
            T_mat = spikeAvg_MEG.grad.tra;
            
            % Validate transformation matrix dimensions
            if size(T_mat, 2) ~= size(LF_MEG, 1)
                error_msg = sprintf('Transformation matrix dimensions mismatch: T_mat is %dx%d, but lead field has %d channels', ...
                    size(T_mat, 1), size(T_mat, 2), size(LF_MEG, 1));
                return;
            end
            
            if config.verbose
                fprintf('Applying MEG transformation matrix (%dx%d)\n', size(T_mat, 1), size(T_mat, 2));
            end
            L = T_mat * LF_MEG;
        else
            if config.verbose
                fprintf('Warning: No transformation matrix found, using lead field directly\n');
            end
            L = LF_MEG;
        end
        
        % Select channels (typically magnetometers first)
        max_channels = min(config.meg.max_channels, size(L, 1));
        L = L(1:max_channels, :);
        
        if config.verbose
            fprintf('Using %d MEG channels\n', max_channels);
        end
        
        % Validate measurements match lead field dimensions
        if size(measurements, 1) ~= size(L, 1) && size(measurements, 1) > size(L, 1)
            if config.verbose
                fprintf('Warning: Measurements have %d channels, lead field has %d. Truncating measurements.\n', ...
                    size(measurements, 1), size(L, 1));
            end
            measurements = measurements(1:size(L, 1), :);
        end
        
        % Save processed lead field
        output_path = fullfile(config.output_folder, config.output.leadfield_meg);
        if config.verbose
            fprintf('Saving MEG lead field to: %s\n', output_path);
        end
        save(output_path, 'L', '-v7.3');
        
        % Save measurements
        output_path = fullfile(config.output_folder, config.output.measurements_meg);
        if config.verbose
            fprintf('Saving MEG measurements to: %s\n', output_path);
        end
        save(output_path, 'measurements', '-v7.3');
        
        % Process sensors (pass number of channels used for filtering)
        [sensor_success, sensor_error] = utilities.duneuro2zef.process_sensors(...
            config, 'MEG', max_channels);
        
        if ~sensor_success
            error_msg = sprintf('Error processing MEG sensors: %s', sensor_error);
            return;
        end
        
        success = true;
        
    catch ME
        error_msg = sprintf('Error processing MEG data: %s', ME.message);
        if config.verbose
            fprintf('Error: %s\n', error_msg);
            fprintf('Stack trace:\n');
            for i = 1:min(3, length(ME.stack))
                fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
    end

end
