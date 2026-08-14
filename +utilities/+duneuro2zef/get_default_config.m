% get_default_config.m
%
% Returns a default configuration structure for Duneuro to Zeffiro Interface
% conversion. This configuration can be customized for different projects.
%
% Output:
%   config - Structure containing all configuration parameters
%
% Usage:
%   config = utilities.duneuro2zef.get_default_config();
%   % Customize as needed
%   config.input_folder = 'my_data/duneuro_export';
%   results = utilities.duneuro2zef.run(config);
%
% See also: run.m, validate_config.m

function config = get_default_config()
%GET_DEFAULT_CONFIG  Default folder paths and filenames for Duneuro import.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   config = get_default_config()
%
%   input_folder 'data/exported', output_folder 'data/converted'. File patterns:
%   mesh.mat (hex), sp_vol_rgv_N*.mat, sensors.mat, LF_EEG.mat / LF_MEG.mat,
%   spikeAvgEEG.mat / spikeAvgMEG.mat, resection_points.dat. Flags process_eeg,
%   process_meg, process_resection_points, invert_domain_labels, verbose,
%   continue_on_error. EEG channel_indices default [302:358, inf] (dataset-
%   specific). Outputs tetra_mesh.mat, source_space.mat, L_EEG.mat, etc.
%


    config.input_folder = 'data/exported';
    config.output_folder = 'data/converted';
    
    % Input file names (can be exact names or patterns)
    config.files.mesh = 'mesh.mat';
    config.files.source_space = 'sp_vol_rgv_N*.mat';  % Pattern for auto-discovery
    config.files.resection_points = 'resection_points.dat';
    config.files.leadfield_eeg = 'LF_EEG.mat';
    config.files.leadfield_meg = 'LF_MEG.mat';
    config.files.measurements_eeg = 'spikeAvgEEG.mat';
    config.files.measurements_meg = 'spikeAvgMEG.mat';
    config.files.sensors = 'sensors.mat';
    
    % Processing options
    config.process_eeg = true;
    config.process_meg = true;
    config.process_resection_points = true;
    config.invert_domain_labels = true;  % Duneuro uses opposite convention
    config.verbose = true;  % Print progress messages
    config.continue_on_error = false;  % Stop on first error
    
    % Domain configuration
    config.domain_labels.brain = 2;  % Domain label for brain compartment
    
    % EEG configuration
    config.eeg.channel_indices = [302:358, inf];  % Indices in full channel set, inf = end
    config.eeg.channel_path = {'cfg', 'previous', 'previous', 'channel'};  % Path in FieldTrip structure
    config.eeg.measurement_field = 'avg';  % Field name in measurement structure
    
    % MEG configuration
    config.meg.max_channels = 274;  % Maximum number of channels to use
    config.meg.use_magnetometers = true;  % Use magnetometers (first N channels)
    config.meg.measurement_field = 'avg';  % Field name in measurement structure
    
    % Source space configuration
    config.source_space.priority = 'smallest';  % 'smallest', 'largest', or specific pattern
    
    % Mesh conversion options
    config.mesh.save_brain_ind = true;  % Save brain compartment indices
    
    % Output file names (standardized)
    config.output.mesh = 'tetra_mesh.mat';
    config.output.source_space = 'source_space.mat';
    config.output.resection_points = 'resection_points.mat';
    config.output.leadfield_eeg = 'L_EEG.mat';
    config.output.leadfield_meg = 'L_MEG.mat';
    config.output.measurements_eeg = 'EEG_measurements.mat';
    config.output.measurements_meg = 'MEG_measurements.mat';
    config.output.sensors_eeg = 'EEG_sensors.mat';
    config.output.sensors_meg = 'MEG_sensors.mat';
    
end
