function [vertices, faces, surface_data, surface] = zef_bst_2_zef_surface(varargin)
% --- Zeffiro documentation header ---
% zef_bst_2_zef_surface — Zef bst 2 zef surface.
%
% Purpose:
%   Zef bst 2 zef surface.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Inputs:
%   varargin
%
% Outputs:
%   vertices
%   faces
%   surface_data
%   surface
%
% Calls (project):
%   zef_bst_2_zef_surface
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[vertices, faces, surface_data]] = zef_bst_2_zef_surface(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
