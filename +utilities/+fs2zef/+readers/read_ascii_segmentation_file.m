function [nodes, faces] =  read_ascii_segmentation_file ( fname )
%READ_ASCII_SEGMENTATION_FILE  Parse FreeSurfer ASCII mesh (nodes + triangle faces).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [nodes, faces] = read_ascii_segmentation_file(fname)
%
% Reads in a segmentation file line by line and extracts the information from
% within it. Throws an exception if the given file does not conform to the
% expected format.
%
% Inputs:
%
% - fname
%
%   The file name of a FreeSurfer-generated ASCII segmentation file from which
%   nodes and faces are to be extracted.
%
% Outputs:
%
% - nodes
%
%   The nodes found from the file.
%
% - faces
%
%   The node index triples found from the file.
%

    arguments

        fname (1,1) string { mustBeFile }

    end

    % Open file for reading
    fid = fopen(fname, 'r');

    if fid == -1
        error("Could not open file '" + fname + "'.");
    end

    % Ensure file is closed even if an error occurs
    cleanup_obj = onCleanup(@() cleanup_fn(fid));

    ERR = "ERR: " + fname + ": ";

    % Read and validate first line (header)
    first_line = fgetl(fid);

    if utilities.io.is_eof(first_line)
        error(ERR + "Empty file");
    end

    first_line = string(first_line);

    % Validate FreeSurfer ASCII surface file header
    if not(startsWith(first_line, "#!ascii version of"))
        error(ERR + "Invalid first line '" + first_line + "'");
    end

    % Read second line to get number of nodes and faces
    second_line = string(fgetl(fid));

    if utilities.io.is_eof(second_line)
        error(ERR + "No second line");
    end

    % Parse number of nodes and faces from second line
    n_of_nodes_and_faces = string(strsplit(second_line, " "));

    if numel(n_of_nodes_and_faces) ~= 2
        error(ERR + "Wrong 2nd line length");
    end

    n_of_nodes = double(n_of_nodes_and_faces(1));
    n_of_faces = double(n_of_nodes_and_faces(2));

    % Validate that counts are positive integers
    if not(utilities.io.float_is_int(n_of_nodes)) || n_of_nodes < 1
        error(ERR + "Number of nodes on 2nd line was not a positive integer");
    end

    if not(utilities.io.float_is_int(n_of_faces)) || n_of_faces < 1
        error(ERR + "Number of faces on 2nd line was not a positive integer");
    end

    % Initialize node array (3 coordinates x N nodes)
    nodes = zeros(3, n_of_nodes);
    SEP = " ";

    % Read node coordinates: format is [x, y, z, unused]
    for ii = 1 : n_of_nodes
        this_line = fgetl(fid);

        if utilities.io.is_eof(this_line)
            error(ERR + "Reached end of file before all nodes were handled");
        end

        this_line = string(this_line);

        coords = strsplit(this_line, SEP);

        if numel(coords) ~= 4
            error("Wrong number of columns in a node line '" + this_line + "'");
        end

        node = double(coords);

        % Validate that coordinates are numeric
        if any(isnan(node(1:3)))
            error(ERR + "One of the node coordinates '" + this_line + "' on line " + (ii + 1) + " was not a floating point number.");
        end

        % Store x, y, z coordinates (first 3 columns)
        nodes(:, ii) = node(1:3);

    end % for

    % Initialize face array (3 vertex indices x M faces)
    faces = uint64(zeros(3, n_of_faces));

    % Read face definitions: format is [v1, v2, v3, unused] where v1, v2, v3 are 0-indexed
    for ii = 1 : n_of_faces
        linenum = n_of_nodes + ii + 2;  % Line number for error reporting

        this_line = fgetl(fid);

        if utilities.io.is_eof(this_line)
            error(ERR + "Reached end of file before all faces were handled");
        end

        this_line = string(this_line);

        coords = strsplit(this_line, SEP);

        if numel(coords) ~= 4
            error(ERR + "Wrong number of columns in a face line '" + this_line + "'");
        end

        face = double(coords);

        % Validate that face indices are integers
        if not(utilities.io.float_is_int(face(1:3)))
            error(ERR + "One of the face coordinates '" + this_line + "' on line " + linenum + " was not an integer.");
        end

        % Validate that face indices are non-negative
        if any(face(1:3) < 0)
            error("Line " + linenum + " of file " + fname + " contained a negative array index.");
        end

        % Store vertex indices (first 3 columns)
        faces(:, ii) = face(1:3);

    end % for

    % Validate that all face indices are within valid range
    if any(n_of_nodes < max(faces(:)))
        error("Found faces with indices greater than the number of nodes in '" + fname + "'.");
    end

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cleanup_fn ( fid )

    fclose ( fid ) ;

end
