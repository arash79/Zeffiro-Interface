function [compartment_file, compartment_type, found] = zef_bst_find_compartment(compartment_name, subject_struct, subject_folder)
%ZEF_BST_FIND_COMPARTMENT Finds a compartment in Brainstorm subject structure.
%
% This function searches for a compartment by name in various locations within
% the Brainstorm subject structure, providing a flexible and robust way to
% locate compartments regardless of how they are stored.
%
% Inputs:
%   compartment_name - String name of the compartment to find (e.g., 'Scalp', 'Cortex')
%   subject_struct   - Brainstorm subject structure
%   subject_folder   - Path to Brainstorm subject folder
%
% Outputs:
%   compartment_file - Full path to the compartment file (empty if not found)
%   compartment_type - Type of compartment found: 'Surface', 'Anatomy', or ''
%   found            - Logical indicating if compartment was found
%
% Example:
%   [file, type, found] = utilities.brainstorm2zef.zef_bst_find_compartment(...
%       'Scalp', subject_struct, subject_folder);
%   if found
%       fprintf('Found %s compartment: %s\n', type, file);
%   end
%
% See also: ZEF_BST_CREATE_COMPARTMENT_DATA

compartment_file = '';
compartment_type = '';
found = false;

% Validate inputs
if isempty(compartment_name) || (~ischar(compartment_name) && ~isstring(compartment_name))
    found = false;
    return;
end

if isempty(subject_struct) || ~isstruct(subject_struct)
    found = false;
    return;
end

% Check if compartment has a direct index field (e.g., iScalp, iCortex)
index_field = ['i' compartment_name];
if isfield(subject_struct, index_field)
    surface_index = subject_struct.(index_field);
    if ~isempty(surface_index) && isnumeric(surface_index) && surface_index > 0
        if isfield(subject_struct, 'Surface') && ~isempty(subject_struct.Surface) && ...
           isstruct(subject_struct.Surface) && surface_index <= length(subject_struct.Surface)
            if isfield(subject_struct.Surface(surface_index), 'FileName')
                compartment_file = fullfile(subject_folder, ...
                    subject_struct.Surface(surface_index).FileName);
                compartment_type = 'Surface';
                found = true;
                return;
            end
        end
    end
end

% Search in Surface structures by Comment field
if isfield(subject_struct, 'Surface') && ~isempty(subject_struct.Surface) && ...
   isstruct(subject_struct.Surface) && isfield(subject_struct.Surface, 'Comment')
    % Check if Comment field exists and is accessible
    try
        surface_comments = {subject_struct.Surface.Comment};
        surface_indices = find(ismember(surface_comments, compartment_name));
        if ~isempty(surface_indices)
            % Validate FileName field exists
            if isfield(subject_struct.Surface(surface_indices(1)), 'FileName')
                compartment_file = fullfile(subject_folder, ...
                    subject_struct.Surface(surface_indices(1)).FileName);
                compartment_type = 'Surface';
                found = true;
                return;
            end
        end
        
        % Also try case-insensitive and normalized search
        normalized_compartment = utilities.brainstorm2zef.zef_bst_normalize_compartment_name(compartment_name);
        normalized_comments = cellfun(@(x) utilities.brainstorm2zef.zef_bst_normalize_compartment_name(x), ...
            surface_comments, 'UniformOutput', false);
        surface_indices = find(ismember(normalized_comments, normalized_compartment));
        if ~isempty(surface_indices)
            if isfield(subject_struct.Surface(surface_indices(1)), 'FileName')
                compartment_file = fullfile(subject_folder, ...
                    subject_struct.Surface(surface_indices(1)).FileName);
                compartment_type = 'Surface';
                found = true;
                return;
            end
        end
    catch ME
        % If accessing Surface structure fails, continue to next search method
        % (error is silently handled to allow other search methods to try)
    end
end

% Search in Anatomy structures by Comment field
if isfield(subject_struct, 'Anatomy') && ~isempty(subject_struct.Anatomy) && ...
   isstruct(subject_struct.Anatomy) && isfield(subject_struct.Anatomy, 'Comment')
    try
        anatomy_comments = {subject_struct.Anatomy.Comment};
        anatomy_indices = find(ismember(anatomy_comments, compartment_name));
        if ~isempty(anatomy_indices)
            if isfield(subject_struct.Anatomy(anatomy_indices(1)), 'FileName')
                compartment_file = fullfile(subject_folder, ...
                    subject_struct.Anatomy(anatomy_indices(1)).FileName);
                compartment_type = 'Anatomy';
                found = true;
                return;
            end
        end
        
        % Also try normalized search
        normalized_compartment = utilities.brainstorm2zef.zef_bst_normalize_compartment_name(compartment_name);
        normalized_comments = cellfun(@(x) utilities.brainstorm2zef.zef_bst_normalize_compartment_name(x), ...
            anatomy_comments, 'UniformOutput', false);
        anatomy_indices = find(ismember(normalized_comments, normalized_compartment));
        if ~isempty(anatomy_indices)
            if isfield(subject_struct.Anatomy(anatomy_indices(1)), 'FileName')
                compartment_file = fullfile(subject_folder, ...
                    subject_struct.Anatomy(anatomy_indices(1)).FileName);
                compartment_type = 'Anatomy';
                found = true;
                return;
            end
        end
    catch ME
        % If accessing Anatomy structure fails, continue (error handled silently)
    end
end

% If not found, return empty results
found = false;

end
