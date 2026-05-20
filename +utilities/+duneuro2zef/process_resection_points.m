% process_resection_points.m
%
% Processes resection point coordinates (optional).
%
% Input:
%   config - Configuration structure
%
% Output:
%   success - Logical indicating success
%   error_msg - Error message if failed (empty if successful)
%
% Usage:
%   [success, error_msg] = utilities.duneuro2zef.process_resection_points(config);
%
% See also: run.m, get_default_config.m

function [success, error_msg] = process_resection_points(config)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.process_resection_points — Process resection points.
%
% Purpose:
%   Process resection points.
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
%   utilities.duneuro2zef.process_resection_points
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[success, error_msg]] = utilities.duneuro2zef.process_resection_points(config)` with project root and `src` on the path.
% --- End Zeffiro documentation header


    success = false;
    error_msg = '';
    
    try
        % Check if resection points should be processed
        if ~config.process_resection_points
            success = true;  % Not an error if skipped
            return;
        end
        
        % Find resection points file
        resection_path = fullfile(config.input_folder, config.files.resection_points);
        
        if ~isfile(resection_path)
            if config.verbose
                fprintf('Resection points file not found (optional): %s\n', resection_path);
            end
            success = true;  % Not an error if file doesn't exist
            return;
        end
        
        if config.verbose
            fprintf('Loading resection points from: %s\n', resection_path);
        end
        
        % Load resection points (can be .dat or .mat)
        [~, ~, ext] = fileparts(resection_path);
        if strcmpi(ext, '.dat')
            resection_points = load(resection_path);
        else
            data = load(resection_path);
            if isfield(data, 'resection_points')
                resection_points = data.resection_points;
            else
                fields = fieldnames(data);
                if length(fields) == 1
                    resection_points = data.(fields{1});
                else
                    error_msg = 'Could not identify resection points in file';
                    return;
                end
            end
        end
        
        % Validate resection points (must be Nx3)
        if ~isnumeric(resection_points) || size(resection_points, 2) ~= 3
            error_msg = 'Resection points must be an Nx3 numeric matrix';
            return;
        end
        if size(resection_points, 1) == 0
            error_msg = 'Resection points matrix is empty';
            return;
        end
        
        if config.verbose
            fprintf('Found %d resection points\n', size(resection_points, 1));
        end
        
        % Save resection points
        output_path = fullfile(config.output_folder, config.output.resection_points);
        if config.verbose
            fprintf('Saving resection points to: %s\n', output_path);
        end
        
        save(output_path, 'resection_points', '-v7.3');
        
        success = true;
        
    catch ME
        error_msg = sprintf('Error processing resection points: %s', ME.message);
        if config.verbose
            fprintf('Error: %s\n', error_msg);
        end
    end

end
