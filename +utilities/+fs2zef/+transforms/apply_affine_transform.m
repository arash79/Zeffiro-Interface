function apply_affine_transform(mesh_file, affine_matrix, options)
%
% apply_affine_transform - Apply affine transformation to mesh file
%
% Applies a 4x4 affine transformation matrix to the vertices of a mesh file.
% Supports both ASCII (.asc) and STL (.stl) formats. The transformation is
% applied in-place (file is overwritten) or to a new file if output_file is specified.
%
% Inputs:
%   mesh_file      - Path to input mesh file (.asc or .stl)
%   affine_matrix  - 4x4 homogeneous transformation matrix
%   options        - (optional) Struct with options:
%                    .output_file - Output file path (default: overwrite input)
%                    .verbose     - Print progress (default: false)
%
% Outputs:
%   None (file is written to disk)
%
% Example:
%   affine = utilities.fs2zef.transforms.compute_affine_transform(source, target);
%   utilities.fs2zef.transforms.apply_affine_transform('mesh.asc', affine);
%
% Note:
%   For now, this function is a placeholder for future implementation.
%   Mesh transformation should ideally be done during mesh generation
%   by FreeSurfer tools rather than post-processing.
%   The affine_transform parameter in ZEF import files handles the
%   transformation at import time.
%

    arguments
        mesh_file (1,1) string { mustBeFile }
        affine_matrix (4,4) double
        options.output_file (1,1) string = ""
        options.verbose (1,1) logical = false
    end
    
    % Validate affine matrix (should be valid transformation)
    if affine_matrix(4,4) ~= 1 || any(affine_matrix(4,1:3) ~= 0)
        error('apply_affine_transform:InvalidMatrix', ...
            'Invalid affine matrix: bottom row must be [0 0 0 1]');
    end
    
    % Determine output file
    if strlength(options.output_file) == 0
        output_file = mesh_file;
    else
        output_file = options.output_file;
    end
    
    % Get file extension
    [~, ~, ext] = fileparts(mesh_file);
    
    if options.verbose
        fprintf('Applying affine transform to %s...\n', mesh_file);
    end
    
    % Process based on file type
    if strcmpi(ext, '.asc')
        apply_to_ascii(mesh_file, output_file, affine_matrix, options.verbose);
    elseif strcmpi(ext, '.stl')
        apply_to_stl(mesh_file, output_file, affine_matrix, options.verbose);
    else
        error('apply_affine_transform:UnsupportedFormat', ...
            'Unsupported mesh format: %s (expected .asc or .stl)', ext);
    end
    
    if options.verbose
        fprintf('Transform applied and saved to %s\n', output_file);
    end
    
end % function

%% Helper functions

function apply_to_ascii(input_file, output_file, affine, verbose)
    % Apply transformation to ASCII format mesh
    
    % Read the ASCII file
    [nodes, faces] = utilities.fs2zef.readers.read_ascii_segmentation_file(input_file);
    
    % Transform nodes (3xN matrix)
    % Convert to homogeneous coordinates (4xN)
    nodes_homog = [nodes; ones(1, size(nodes, 2))];
    
    % Apply transformation
    nodes_transformed = affine * nodes_homog;
    
    % Convert back to 3D coordinates
    nodes_transformed = nodes_transformed(1:3, :);
    
    % Write back to file
    % Note: This requires a write function for ASCII format
    % For now, we'll use a simple implementation
    write_ascii_segmentation_file(output_file, nodes_transformed, faces);
    
end % function

function apply_to_stl(input_file, output_file, affine, verbose)
    % Apply transformation to STL format mesh
    
    % Read STL file
    try
        [vertices, faces, ~] = stlread(input_file);
    catch
        error('apply_affine_transform:STLReadFailed', ...
            'Failed to read STL file: %s', input_file);
    end
    
    % Transform vertices (Nx3 matrix, need to transpose)
    vertices_homog = [vertices, ones(size(vertices, 1), 1)]';  % 4xN
    vertices_transformed = affine * vertices_homog;  % 4xN
    vertices_transformed = vertices_transformed(1:3, :)';  % Back to Nx3
    
    % Write transformed mesh
    try
        stlwrite(output_file, faces, vertices_transformed);
    catch
        error('apply_affine_transform:STLWriteFailed', ...
            'Failed to write STL file: %s', output_file);
    end
    
end % function

function write_ascii_segmentation_file(filename, nodes, faces)
    % Write ASCII segmentation file in FreeSurfer format
    
    fid = fopen(filename, 'w');
    if fid == -1
        error('apply_affine_transform:FileWriteFailed', ...
            'Could not open file for writing: %s', filename);
    end
    
    % Ensure cleanup
    cleanup_obj = onCleanup(@() fclose(fid));
    
    % Write header
    fprintf(fid, '#!ascii version of %s\n', filename);
    fprintf(fid, '%d %d\n', size(nodes, 2), size(faces, 2));
    
    % Write nodes (x y z 0)
    for ii = 1:size(nodes, 2)
        fprintf(fid, '%.6f %.6f %.6f 0\n', nodes(1,ii), nodes(2,ii), nodes(3,ii));
    end
    
    % Write faces (v1 v2 v3 0) - 0-indexed
    for ii = 1:size(faces, 2)
        fprintf(fid, '%d %d %d 0\n', faces(1,ii), faces(2,ii), faces(3,ii));
    end
    
end % function
