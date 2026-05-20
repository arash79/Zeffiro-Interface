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
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.get_default_config — Get default config.
%
% Purpose:
%   Get default config.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Outputs:
%   config
%
% Calls (project):
%   utilities.duneuro2zef.get_default_config
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `utilities.duneuro2zef.get_default_config` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
