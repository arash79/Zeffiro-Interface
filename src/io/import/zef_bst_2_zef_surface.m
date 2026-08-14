function [vertices, faces, surface_data, surface] = zef_bst_2_zef_surface(varargin)
%ZEF_BST_2_ZEF_SURFACE  Read Brainstorm subject surface geometry into Zeffiro units.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Uses Brainstorm bst_get to locate subject surfaces. With surface index
%   and optional property names, loads the surface MAT file and returns
%   Vertices scaled by 1000 (m to mm) and Faces. Without index, returns
%   the Surface struct array for browsing.
%
%   surface = zef_bst_2_zef_surface()
%   surface = zef_bst_2_zef_surface(subject)
%   [vertices, faces] = zef_bst_2_zef_surface(subject, surface_ind)
%   [vertices, faces, surface_data] = zef_bst_2_zef_surface(subject, surface_ind, properties)
%
%   Inputs
%     subject        - Brainstorm subject index (optional).
%     surface_ind    - index into Subject.Surface (optional).
%     properties     - cell of field names to load from the surface file.
%
%   Outputs
%     vertices, faces - mesh arrays when surface_ind is given.
%     surface_data    - loaded struct or selected fields.
%     surface         - Surface metadata array when mesh not loaded.
%
%   See also zef_bst_2_zef_atlas, zef_import_segmentation.

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
