function [success, error_msg] = process_eeg_data(config)
%PROCESS_EEG_DATA  Duneuro EEG L + measurements → converted .mat + sensors.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Stage of utilities.duneuro2zef.run. No-op success if ~config.process_eeg.
%   Loads input_folder/files.leadfield_eeg (variable LF_EEG, else L, else the
%   sole field) and files.measurements_eeg (spikeAvg_EEG, eeg_data, or sole
%   field). Measurements are struct.(config.eeg.measurement_field) or .data;
%   labels must exist. Channel subset: config.eeg.channel_indices with inf
%   meaning end, matched to spikeAvg label vs the nested channel_path.
%   Writes output.leadfield_eeg as L and output.measurements_eeg as
%   measurements (-v7.3), then process_sensors(config,'EEG', used_indices).
%
%   [success, error_msg] = process_eeg_data(config)
%
%   See also process_meg_data, process_sensors, run.

    success = false;
    error_msg = '';
    
    try
        % Check if EEG should be processed
        if ~config.process_eeg
            success = true;
            return;
        end
        
        if config.verbose
            fprintf('\n=== Processing EEG Data ===\n');
        end
        
        % Load lead field
        lf_path = fullfile(config.input_folder, config.files.leadfield_eeg);
        if ~isfile(lf_path)
            error_msg = sprintf('EEG lead field file not found: %s', lf_path);
            return;
        end
        
        if config.verbose
            fprintf('Loading EEG lead field from: %s\n', lf_path);
        end
        
        lf_data = load(lf_path);
        
        % Extract lead field (handle different variable names)
        if isfield(lf_data, 'LF_EEG')
            LF_EEG = lf_data.LF_EEG;
        elseif isfield(lf_data, 'L')
            LF_EEG = lf_data.L;
        else
            fields = fieldnames(lf_data);
            if length(fields) == 1
                LF_EEG = lf_data.(fields{1});
            else
                error_msg = 'Could not identify lead field in file';
                return;
            end
        end
        
        % Validate lead field
        if ~isnumeric(LF_EEG) || ndims(LF_EEG) ~= 2
            error_msg = 'Lead field must be a 2D numeric matrix';
            return;
        end
        if size(LF_EEG, 1) == 0 || size(LF_EEG, 2) == 0
            error_msg = 'Lead field matrix is empty';
            return;
        end
        
        % Load measurements
        meas_path = fullfile(config.input_folder, config.files.measurements_eeg);
        if ~isfile(meas_path)
            error_msg = sprintf('EEG measurements file not found: %s', meas_path);
            return;
        end
        
        if config.verbose
            fprintf('Loading EEG measurements from: %s\n', meas_path);
        end
        
        meas_data = load(meas_path);
        
        % Extract measurement structure (handle different variable names)
        if isfield(meas_data, 'spikeAvg_EEG')
            spikeAvg_EEG = meas_data.spikeAvg_EEG;
        elseif isfield(meas_data, 'eeg_data')
            spikeAvg_EEG = meas_data.eeg_data;
        else
            fields = fieldnames(meas_data);
            if length(fields) == 1
                spikeAvg_EEG = meas_data.(fields{1});
            else
                error_msg = 'Could not identify measurement structure in file';
                return;
            end
        end
        
        % Extract measurements
        if isfield(spikeAvg_EEG, config.eeg.measurement_field)
            measurements = spikeAvg_EEG.(config.eeg.measurement_field);
        elseif isfield(spikeAvg_EEG, 'data')
            measurements = spikeAvg_EEG.data;
        else
            error_msg = sprintf('Measurement structure must contain field: %s', config.eeg.measurement_field);
            return;
        end
        
        % Extract channel information
        if ~isfield(spikeAvg_EEG, 'label')
            error_msg = 'Measurement structure must contain label field';
            return;
        end
        channels_used = spikeAvg_EEG.label;
        
        % Get full channel list from nested structure
        channels_all = spikeAvg_EEG;
        for i = 1:length(config.eeg.channel_path)
            if isfield(channels_all, config.eeg.channel_path{i})
                channels_all = channels_all.(config.eeg.channel_path{i});
            else
                % Try alternative: direct access to channel field
                if isfield(spikeAvg_EEG, 'channel')
                    channels_all = spikeAvg_EEG.channel;
                    break;
                else
                    error_msg = sprintf('Could not find channel path: %s', strjoin(config.eeg.channel_path, '.'));
                    return;
                end
            end
        end
        
        % Handle channel indices (inf means end)
        channel_indices = config.eeg.channel_indices;
        if any(isinf(channel_indices))
            inf_idx = find(isinf(channel_indices));
            channel_indices(inf_idx) = length(channels_all);
        end
        
        % Validate channel indices
        max_idx = max(channel_indices);
        if isnumeric(channels_all)
            if length(channels_all) < max_idx
                error_msg = sprintf('Channel indices exceed available channels (%d > %d)', max_idx, length(channels_all));
                return;
            end
            channels_all_subset = channels_all(channel_indices);
        elseif iscell(channels_all)
            if length(channels_all) < max_idx
                error_msg = sprintf('Channel indices exceed available channels (%d > %d)', max_idx, length(channels_all));
                return;
            end
            channels_all_subset = channels_all(channel_indices);
        else
            error_msg = 'Channels must be numeric array or cell array';
            return;
        end
        
        % Find which channels in the subset match the used channels
        % This gives indices into channels_all_subset
        matching_mask = ismember(channels_all_subset, channels_used);
        channels_used_ind = find(matching_mask);
        
        if isempty(channels_used_ind)
            error_msg = 'No matching channels found between lead field and measurements';
            return;
        end
        
        % Map indices: channels_used_ind are indices into channels_all_subset
        % which correspond to channel_indices into the full channels_all
        % We need to map these to indices into LF_EEG
        % If LF_EEG is ordered according to channels_all_subset, we can use channels_used_ind directly
        % But we need to verify the lead field dimensions match
        
        % Validate lead field dimensions
        if size(LF_EEG, 1) ~= length(channels_all_subset)
            if config.verbose
                fprintf('Warning: Lead field has %d channels, expected %d. Attempting to match by channel names...\n', ...
                    size(LF_EEG, 1), length(channels_all_subset));
            end
            % Try to match by finding channels in LF_EEG that match channels_used
            % This assumes LF_EEG might be in a different order
            if isfield(lf_data, 'channel_names') || isfield(lf_data, 'channels')
                % If lead field has channel names, use those
                if isfield(lf_data, 'channel_names')
                    lf_channels = lf_data.channel_names;
                else
                    lf_channels = lf_data.channels;
                end
                [~, lf_indices] = ismember(channels_used, lf_channels);
                channels_used_ind = lf_indices(lf_indices > 0);
                if isempty(channels_used_ind)
                    error_msg = 'Could not match channels between lead field and measurements';
                    return;
                end
            else
                % Assume LF_EEG rows correspond to channels_all_subset in order
                % Use channels_used_ind as-is
                if size(LF_EEG, 1) < max(channels_used_ind)
                    error_msg = sprintf('Lead field has insufficient channels (%d < %d)', ...
                        size(LF_EEG, 1), max(channels_used_ind));
                    return;
                end
            end
        end
        
        if config.verbose
            fprintf('Using %d of %d available channels\n', length(channels_used_ind), size(LF_EEG, 1));
        end
        
        % Filter lead field to match used channels
        L = LF_EEG(channels_used_ind, :);
        
        % Save processed lead field
        output_path = fullfile(config.output_folder, config.output.leadfield_eeg);
        if config.verbose
            fprintf('Saving EEG lead field to: %s\n', output_path);
        end
        save(output_path, 'L', '-v7.3');
        
        % Save measurements
        output_path = fullfile(config.output_folder, config.output.measurements_eeg);
        if config.verbose
            fprintf('Saving EEG measurements to: %s\n', output_path);
        end
        save(output_path, 'measurements', '-v7.3');
        
        % Process sensors (requires channels_used_ind)
        [sensor_success, sensor_error] = utilities.duneuro2zef.process_sensors(...
            config, 'EEG', channels_used_ind);
        
        if ~sensor_success
            error_msg = sprintf('Error processing EEG sensors: %s', sensor_error);
            return;
        end
        
        success = true;
        
    catch ME
        error_msg = sprintf('Error processing EEG data: %s', ME.message);
        if config.verbose
            fprintf('Error: %s\n', error_msg);
            fprintf('Stack trace:\n');
            for i = 1:min(3, length(ME.stack))
                fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
    end

end