function [compartment_settings, surface_meshes, zef] = zef_bst_create_compartment_data(settings_file_name, zef_bst, zef)
%ZEF_BST_CREATE_COMPARTMENT_DATA Creates compartment data from Brainstorm subject structure.
%
% This function loads surface meshes from Brainstorm subject files and
% converts them into Zeffiro-compatible format. It handles both standard
% surface meshes and atlas-based volumetric data (Cube format).
%
% Inputs:
%   settings_file_name - Path to settings file (currently unused, reserved for future use)
%   zef_bst          - Structure containing Brainstorm-to-Zeffiro configuration
%   zef              - Zeffiro project structure
%
% Outputs:
%   compartment_settings - Cell array containing compartment configuration
%   surface_meshes       - Structure array of surface meshes with fields:
%                          Name, Type, Points, Triangles, Color
%   zef                  - Updated Zeffiro project structure
%
% See also: ZEF_BST_COMPARTMENT_SETTINGS, ZEF_BST_GET_ATLAS_SURFACES, ZEF_BST_FIND_COMPARTMENT

% Validate Brainstorm environment
[is_valid, error_msg] = utilities.brainstorm2zef.zef_bst_validate_environment();
if ~is_valid
    error('Brainstorm environment validation failed: %s', error_msg);
end

mesh_file_ind = 0;
compartment_types = cell(0);
A = eye(4);  % Default 4x4 identity transformation matrix

% Get Brainstorm subject structure (use provided or current active subject)
try
    if isfield(zef_bst,'subject_struct') && ~isempty(fieldnames(zef_bst.subject_struct))
        subject_struct = zef_bst.subject_struct;
    else
        subject_struct = bst_get('Subject');
        if isempty(subject_struct)
            error('No Brainstorm subject available. Please select a subject in Brainstorm.');
        end
    end
catch ME
    error('Failed to get Brainstorm subject: %s', ME.message);
end

% Get Brainstorm subject folder path (use provided or default protocol folder)
try
    if isfield(zef_bst,'subject_folder') && ~isempty(zef_bst.subject_folder)
        subject_folder = char(zef_bst.subject_folder);
        if ~isfolder(subject_folder)
            error('Subject folder does not exist: %s', subject_folder);
        end
    else
        protocol_info = bst_get('ProtocolInfo');
        if isempty(protocol_info) || ~isfield(protocol_info, 'SUBJECTS')
            error('Brainstorm protocol is not properly initialized.');
        end
        subject_folder = protocol_info.SUBJECTS;
        if ~isfolder(subject_folder)
            error('Brainstorm subjects folder does not exist: %s', subject_folder);
        end
    end
catch ME
    error('Failed to get Brainstorm subject folder: %s', ME.message);
end

% If compartment files are not specified, search for them in Brainstorm subject structure
if isempty(zef_bst.compartment_files)
    
    zef_bst.compartment_files = cell(0);
    not_found_compartments = {};
    
    % Search for each compartment in the compartment list using improved find function
    for i = 1 : length(zef_bst.compartment_list)
        [compartment_file, compartment_type, found] = ...
            utilities.brainstorm2zef.zef_bst_find_compartment(...
            zef_bst.compartment_list{i}, subject_struct, subject_folder);
        
        if found
            mesh_file_ind = mesh_file_ind + 1;
            zef_bst.compartment_files{mesh_file_ind} = compartment_file;
        else
            not_found_compartments{end+1} = zef_bst.compartment_list{i};
        end
    end
    
    % Warn about compartments that were not found
    if ~isempty(not_found_compartments)
        warning('The following compartments were not found in Brainstorm subject: %s', ...
            strjoin(not_found_compartments, ', '));
    end
    
else
    % If compartment files are specified, verify they exist and resolve relative paths
    for i = 1 : length(zef_bst.compartment_files)
        if ~exist(zef_bst.compartment_files{i},'file')
            % Try resolving relative to subject folder
            resolved_path = fullfile(subject_folder, zef_bst.compartment_files{i});
            if exist(resolved_path, 'file')
                zef_bst.compartment_files{i} = resolved_path;
            else
                error('Compartment file not found: %s', zef_bst.compartment_files{i});
            end
        end
    end
end

% Determine compartment types for each loaded file
n_surface_meshes = length(zef_bst.compartment_files);
if n_surface_meshes == 0
    error('No compartment files found. Please check your compartment_list settings and Brainstorm subject structure.');
end

compartment_types = cell(1,n_surface_meshes);
for i = 1 : n_surface_meshes
    try
    % Load Comment field to identify compartment type
        loaded_data = load(zef_bst.compartment_files{i},'Comment');
        if isfield(loaded_data, 'Comment')
            surface_mesh_type = loaded_data.Comment;
        else
            surface_mesh_type = '';
        end
        
    % If Comment doesn't match compartment list, get SurfaceType from Brainstorm
        if ~ismember(surface_mesh_type, zef_bst.compartment_list)
            try
        [subject_struct, ~, surface_index] = bst_get('SurfaceFile', zef_bst.compartment_files{i});
                if ~isempty(subject_struct) && surface_index > 0 && ...
                   surface_index <= length(subject_struct.Surface)
        surface_mesh_type = subject_struct.Surface(surface_index).SurfaceType;
    end
            catch
                % If Brainstorm lookup fails, use filename as fallback
                [~, surface_mesh_type] = fileparts(zef_bst.compartment_files{i});
            end
        end
        
        if isempty(surface_mesh_type)
            % Fallback: use filename
            [~, surface_mesh_type] = fileparts(zef_bst.compartment_files{i});
        end
        
        compartment_types{i} = surface_mesh_type;
    catch ME
        warning('Failed to determine type for compartment file %s: %s', ...
            zef_bst.compartment_files{i}, ME.message);
        [~, compartment_types{i}] = fileparts(zef_bst.compartment_files{i});
    end
end

% Reorder compartments according to priority list (outermost to innermost)
% Only reorder if we have a valid ordering
surface_mesh_order = zeros(n_surface_meshes,1);
surface_counter = 0;
for i = 1 : length(zef_bst.compartment_list)
    I = find(ismember(compartment_types, zef_bst.compartment_list{i}));
    n_found = length(I);
    if n_found > 0
    surface_mesh_order(I) = [1:n_found]' + surface_counter;
    surface_counter = surface_counter + n_found;
end
end

% Only reorder if we have valid ordering indices
if any(surface_mesh_order > 0)
    % Find unassigned compartments (those not in compartment_list)
    unassigned = find(surface_mesh_order == 0);
    if ~isempty(unassigned)
        % Assign unassigned compartments to the end
        surface_mesh_order(unassigned) = [1:length(unassigned)]' + surface_counter;
    end
zef_bst.compartment_files = zef_bst.compartment_files(surface_mesh_order);
compartment_types = compartment_types(surface_mesh_order);
else
    % If no compartments matched the list, keep original order
    warning('No compartments matched the compartment_list. Using original order.');
end

% Load and convert surface meshes from Brainstorm format to Zeffiro format
surface_meshes = struct;
surface_mesh_counter = 0;

for i = 1 : n_surface_meshes
    
    try
    compartment_struct = load(zef_bst.compartment_files{i});
    
    % Handle standard surface mesh format (Vertices and Faces)
        if isfield(compartment_struct, 'Vertices') && isfield(compartment_struct, 'Faces')
            % Validate mesh data before processing
            if isempty(compartment_struct.Vertices) || isempty(compartment_struct.Faces)
                warning('Compartment file %s has empty Vertices or Faces. Skipping.', zef_bst.compartment_files{i});
                continue;
            end
            
            if size(compartment_struct.Vertices, 2) ~= 3
                error('Vertices in %s must have 3 columns (x, y, z coordinates), found %d', ...
                    zef_bst.compartment_files{i}, size(compartment_struct.Vertices, 2));
            end
            if size(compartment_struct.Faces, 2) ~= 3
                error('Faces in %s must have 3 columns (triangle vertex indices), found %d', ...
                    zef_bst.compartment_files{i}, size(compartment_struct.Faces, 2));
            end
            
            % Validate vertex indices in Faces
            max_vertex_index = max(compartment_struct.Faces(:));
            if max_vertex_index > size(compartment_struct.Vertices, 1)
                error('Faces in %s reference vertex index %d, but only %d vertices exist', ...
                    zef_bst.compartment_files{i}, max_vertex_index, size(compartment_struct.Vertices, 1));
            end
            if min(compartment_struct.Faces(:)) < 1
                error('Faces in %s contain invalid vertex indices (must be >= 1)', zef_bst.compartment_files{i});
            end
            
            surface_mesh_counter = surface_mesh_counter + 1;
            surface_meshes(surface_mesh_counter).Name = compartment_types{i};
            surface_meshes(surface_mesh_counter).Type = compartment_types{i};
            surface_meshes(surface_mesh_counter).Color = [];
            
        % Convert from meters (Brainstorm) to millimeters (Zeffiro)
            surface_meshes(surface_mesh_counter).Points = zef_bst.unit_conversion * compartment_struct.Vertices;
            surface_meshes(surface_mesh_counter).Triangles = compartment_struct.Faces;
    end
    
    % Handle atlas-based volumetric format (Cube with labels)
        if isfield(compartment_struct, 'Cube')
        % Get or set transformation matrix
            if isfield(compartment_struct, 'InitTransf') && ~isempty(compartment_struct.InitTransf) && ...
               length(compartment_struct.InitTransf) >= 2
            A = compartment_struct.InitTransf{2};
        else
                if ~isfield(compartment_struct, 'InitTransf')
                    compartment_struct.InitTransf = cell(1, 2);
                end
            compartment_struct.InitTransf{2} = A;
        end
            
        % Extract surfaces from volumetric atlas data
            try
                surface_meshes_aux = utilities.brainstorm2zef.zef_bst_get_atlas_surfaces(...
                    zef, compartment_struct, zef_bst.n_inflation_steps, ...
                    zef_bst.transform_cell, compartment_types{i});
                
        % Append atlas surfaces to existing surface meshes
                if surface_mesh_counter > 0
            surface_meshes = [surface_meshes surface_meshes_aux];
        else
            surface_meshes = surface_meshes_aux;
        end
                surface_mesh_counter = surface_mesh_counter + length(surface_meshes_aux);
            catch ME
                warning('Failed to extract atlas surfaces from %s: %s', ...
                    zef_bst.compartment_files{i}, ME.message);
            end
        end
        
    catch ME
        error('Failed to load compartment file %s: %s', zef_bst.compartment_files{i}, ME.message);
    end
    
end

% Ensure we have at least one surface mesh
if surface_mesh_counter == 0 && isempty(fieldnames(surface_meshes))
    error('No valid surface meshes were loaded from the compartment files.');
end

% Generate compartment settings from loaded surface meshes
compartment_settings = utilities.brainstorm2zef.zef_bst_compartment_settings(zef_bst,surface_meshes);

% Filter out invalid surface meshes (must have at least 4 points to form a tetrahedron)
n_surface_meshes = size(compartment_settings,1);
ind_vec_aux = zeros(n_surface_meshes,1);
for i = 1 : n_surface_meshes
    if size(surface_meshes(i).Points,1) >= 4
        ind_vec_aux(i) = 1;
    end
end
ind_vec_aux = find(ind_vec_aux);
surface_meshes = surface_meshes(ind_vec_aux);
compartment_settings = compartment_settings(ind_vec_aux,:);

end
