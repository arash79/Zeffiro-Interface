function [vertices, faces, surface_data, surface] = zef_bst_2_zef_surface(varargin)
%ZEF_BST_2_ZEF_SURFACE Legacy function for loading Brainstorm surface meshes.
%
% This is a legacy import function for Brainstorm surfaces. For new projects,
% consider using the orchestrated pipeline in +utilities/+brainstorm2zef/run()
% which provides better error handling, validation, and flexibility.
%
% Inputs:
%   varargin{1} - Subject index (optional, empty = use current)
%   varargin{2} - Surface index (optional, empty = return all surfaces)
%   varargin{3} - Surface properties to load (optional, cell array or string)
%
% Outputs:
%   vertices      - Surface vertices (in millimeters, scaled from meters)
%   faces         - Surface faces (triangle indices)
%   surface_data  - Loaded surface data structure
%   surface       - Brainstorm surface structure
%
% See also: utilities.brainstorm2zef.run, utilities.brainstorm2zef.zef_bst_create_compartment_data

surface_data = struct;
surface_ind_aux = [];
vertices = [];
faces = [];
surface = [];
subject = [];
surface_properties = [];
scaling_constant = 1000;

% Parse input arguments
if ~isempty(varargin)
    subject = varargin{1};
    if length(varargin) > 1
        surface_ind_aux = varargin{2};
    end
    if length(varargin) > 2
        surface_properties = varargin{3};
        if ~iscell(surface_properties)
            surface_properties = {surface_properties};
        end
    end
end

% Get Brainstorm surface structure
try
    if isempty(subject)
        surface = bst_get('ProtocolSubjects').Subject.Surface;
        surface_file = [];
    elseif isempty(surface_ind_aux)
        surface = bst_get('ProtocolSubjects').Subject(subject).Surface;
        surface_file = [];
    else
        surface = bst_get('ProtocolSubjects').Subject(subject).Surface;
        if surface_ind_aux > 0 && surface_ind_aux <= length(surface)
            surface_file = fullfile(bst_get('ProtocolInfo').SUBJECTS, ...
                surface(surface_ind_aux).FileName);
        else
            error('Invalid surface index: %d (available: 1-%d)', ...
                surface_ind_aux, length(surface));
        end
    end
catch ME
    error('Failed to get Brainstorm surface: %s', ME.message);
end

% Load surface file if specified
if ~isempty(surface_file)
    try
        if ~exist(surface_file, 'file')
            error('Surface file not found: %s', surface_file);
        end
        
        if ~isempty(surface_properties)
            surface_data = load(surface_file, surface_properties{:});
            if isequal(length(surface_properties), 1)
                surface_data = surface_data.(surface_properties{1});
            end
        else
            surface_data = load(surface_file);
        end
        
        % Extract vertices and faces with validation
        if isfield(surface_data, 'Vertices')
            vertices = scaling_constant * surface_data.Vertices;
            if size(vertices, 2) ~= 3
                warning('Vertices must have 3 columns. Found %d columns.', size(vertices, 2));
            end
        end
        
        if isfield(surface_data, 'Faces')
            faces = surface_data.Faces;
            if size(faces, 2) ~= 3
                warning('Faces must have 3 columns. Found %d columns.', size(faces, 2));
            end
        end
        
    catch ME
        error('Failed to load surface file %s: %s', surface_file, ME.message);
    end
end

end
