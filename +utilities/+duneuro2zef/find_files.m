% find_files.m
%
% Finds files matching patterns in the input folder. Supports wildcards and
% pattern matching for flexible file discovery.
%
% Input:
%   pattern - File name pattern (can include wildcards like '*.mat')
%   folder - Folder to search in
%   priority - 'smallest', 'largest', or 'first' (for multiple matches)
%
% Output:
%   filepath - Full path to found file (empty if not found)
%   filename - Name of found file (empty if not found)
%
% Usage:
%   [filepath, filename] = utilities.duneuro2zef.find_files('sp_vol_rgv_N*.mat', 'data/exported', 'smallest');
%
% See also: run.m

function [filepath, filename] = find_files(pattern, folder, priority)

    if nargin < 3
        priority = 'first';
    end
    
    filepath = '';
    filename = '';
    
    % Check if folder exists
    if ~isfolder(folder)
        return;
    end
    
    % Search for files matching pattern
    files = dir(fullfile(folder, pattern));
    
    % Filter out directories
    files = files(~[files.isdir]);
    
    if isempty(files)
        return;
    end
    
    % If only one match, return it
    if length(files) == 1
        filename = files(1).name;
        filepath = fullfile(folder, filename);
        return;
    end
    
    % Multiple matches - apply priority
    switch lower(priority)
        case 'smallest'
            % Find file with smallest size (typically lowest resolution)
            [~, idx] = min([files.bytes]);
            filename = files(idx).name;
            filepath = fullfile(folder, filename);
            
        case 'largest'
            % Find file with largest size (typically highest resolution)
            [~, idx] = max([files.bytes]);
            filename = files(idx).name;
            filepath = fullfile(folder, filename);
            
        case 'first'
            % Use first match (alphabetical order)
            filename = files(1).name;
            filepath = fullfile(folder, filename);
            
        otherwise
            % Default to first
            filename = files(1).name;
            filepath = fullfile(folder, filename);
    end

end
