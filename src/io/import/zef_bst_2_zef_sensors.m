function [sensor_positions, sensor_orientations, sensor_ind, sensor_tag_cell] = zef_bst_2_zef_sensors(varargin)
% --- Zeffiro documentation header ---
% zef_bst_2_zef_sensors — Zef bst 2 zef sensors.
%
% Purpose:
%   Zef bst 2 zef sensors.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Inputs:
%   varargin
%
% Outputs:
%   sensor_positions
%   sensor_orientations
%   sensor_ind
%   sensor_tag_cell
%
% Calls (project):
%   zef_bst_2_zef_sensors
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[sensor_positions, sensor_orientations, sensor_ind]] = zef_bst_2_zef_sensors(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

sensor_counter = 0;
sensor_num = 0;
istudy = [];
sensor_type = [];
sensor_positions = [];
sensor_orientations = [];
sensor_ind = [];
sensor_tag_cell = cell(0);
scaling_constant = 1000;

% Parse input arguments
if ~isempty(varargin)
    sensor_type = varargin{1};
    if length(varargin) > 1
        istudy = varargin{2};
    end
end

% Get channel file path
try
    if ~isempty(istudy)
        study_struct = bst_get('Study', istudy);
        if isempty(study_struct) || ~isfield(study_struct, 'Channel') || isempty(study_struct.Channel)
            error('Study %d does not contain channel data', istudy);
        end
        file_name = fullfile(bst_get('ProtocolInfo').STUDIES, study_struct.Channel.FileName);
    else
        study_struct = bst_get('Study');
        if isempty(study_struct) || ~isfield(study_struct, 'Channel') || isempty(study_struct.Channel)
            error('Current study does not contain channel data');
        end
        file_name = fullfile(bst_get('ProtocolInfo').STUDIES, study_struct.Channel.FileName);
    end
    
    if ~exist(file_name, 'file')
        error('Channel file not found: %s', file_name);
    end
catch ME
    error('Failed to get Brainstorm channel file: %s', ME.message);
end

% Load channel data
try
    channel_data = load(file_name);
    if ~isfield(channel_data, 'Channel') || isempty(channel_data.Channel)
        error('Channel file does not contain Channel data');
    end
catch ME
    error('Failed to load channel file %s: %s', file_name, ME.message);
end

% Process channels
for i = 1 : length(channel_data.Channel)
    % Check if channel type matches filter
    if isempty(sensor_type) || ismember(channel_data.Channel(i).Type, sensor_type)
        % Validate channel data
        if ~isfield(channel_data.Channel(i), 'Loc') || isempty(channel_data.Channel(i).Loc)
            warning('Channel %d (type: %s) missing Loc field. Skipping.', i, channel_data.Channel(i).Type);
            continue;
        end
        
        sensor_num = sensor_num + 1;
        n_sensors_this_channel = size(channel_data.Channel(i).Loc, 2);
        
        % Extract sensor positions
        sensor_positions(sensor_counter+1:sensor_counter+n_sensors_this_channel, :) = ...
            channel_data.Channel(i).Loc';
        
        % Extract sensor orientations if available
        if isfield(channel_data.Channel(i), 'Orient') && ~isempty(channel_data.Channel(i).Orient)
            if isempty(sensor_orientations)
                % Initialize orientations array
                sensor_orientations = zeros(size(sensor_positions, 1), 3);
            end
            sensor_orientations(sensor_counter+1:sensor_counter+n_sensors_this_channel, :) = ...
                channel_data.Channel(i).Orient';
        end
        
        % Set sensor indices and tags
        sensor_ind(sensor_counter+1:sensor_counter+n_sensors_this_channel) = sensor_num;
        sensor_tag_cell(sensor_counter+1:sensor_counter+n_sensors_this_channel) = ...
            {channel_data.Channel(i).Type};
        
        sensor_counter = sensor_counter + n_sensors_this_channel;
    end
end

% Scale positions from meters to millimeters
if ~isempty(sensor_positions)
    sensor_positions = scaling_constant * sensor_positions;
end

% Ensure column vectors
if ~isempty(sensor_ind)
    sensor_ind = sensor_ind(:);
end
if ~isempty(sensor_tag_cell)
    sensor_tag_cell = sensor_tag_cell(:);
end

end
