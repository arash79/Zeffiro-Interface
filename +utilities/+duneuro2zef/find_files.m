function [filepath, filename] = find_files(pattern, folder, priority)
%FIND_FILES  First/smallest/largest dir() match of a pattern in a folder.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   files = dir(fullfile(folder, pattern)), directories dropped. One match
%   is returned as-is. Several matches: priority 'smallest'/'largest' by
%   bytes, 'first' (dir order, typically alphabetical). Unknown priority
%   falls back to first. Missing folder or no match → empty strings.
%
%   [filepath, filename] = find_files(pattern, folder)
%   [filepath, filename] = find_files(pattern, folder, priority)
%
%   Used to pick mesh.mat / LF_*.mat / source-grid files in a DUNEuro export folder.

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
    
    switch lower(priority)
        case 'smallest'
            [~, idx] = min([files.bytes]);
        case 'largest'
            [~, idx] = max([files.bytes]);
        otherwise
            idx = 1;
    end
    filename = files(idx).name;
    filepath = fullfile(folder, filename);
end