function [labels, colors] = read_ascii_label_file ( fname )
% --- Zeffiro documentation header ---
% utilities.fs2zef.readers.read_ascii_label_file — Read ascii label file.
%
% Purpose:
%   Read ascii label file.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   fname
%
% Outputs:
%   labels
%   colors
%
% Calls (project):
%   utilities.fs2zef.readers.read_ascii_label_file
%   utilities.io.float_is_int
%   utilities.io.is_eof
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[labels, colors]] = utilities.fs2zef.readers.read_ascii_label_file(fname)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%
% read_ascii_label_file ( fname )
%
% Reads a given FreeSurfer-generated ASCII label file.
%
% Inputs:
%
% - fname
%
%   The ASCII label file.
%
% Outputs:
%
% - labels
%
%   The labels as a column vector of integers.
%
% - colors
%
%   The RGB color values of the labels as a 3-by-N double matrix.
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
    cleanup_fn = @(ff) fclose(ff);
    cleanup_obj = onCleanup(@() cleanup_fn(fid));

    ERR = "ERR: " + fname + ": ";

    % Read and validate first line (header)
    first_line = fgetl(fid);

    if utilities.io.is_eof(first_line)
        error(ERR + "Empty file");
    end

    first_line = string(first_line);

    % Validate FreeSurfer ASCII label file header
    if not(startsWith(first_line, "#!ascii label"))
        error(ERR + "Invalid first line '" + first_line + "'");
    end

    % Read second line to get number of labels
    second_line = string(fgetl(fid));

    if utilities.io.is_eof(second_line)
        error(ERR + "No second line");
    end

    % Parse number of labels from second line
    n_of_labels = string(strsplit(second_line, " "));

    if numel(n_of_labels) ~= 1
        error(ERR + "Wrong 2nd line length. Should be 1.");
    end

    n_of_labels = double(n_of_labels);

    % Validate that the number of labels is a positive integer
    if not(utilities.io.float_is_int(n_of_labels)) || n_of_labels < 1
        error(ERR + "Number of labels on 2nd line was not a positive integer");
    end

    % Initialize output arrays
    labels = uint64(zeros(n_of_labels, 1));  % Label indices
    colors = zeros(3, n_of_labels);          % RGB color values (3 x N matrix)

    % Read each label line: format is [label_index, R, G, B, unused]
    for ii = 1 : n_of_labels
        this_line = fgetl(fid);

        if utilities.io.is_eof(this_line)
            error(ERR + "Reached end of file before all labels were handled");
        end

        this_line = string(this_line);

        % Parse line into components (label index and RGB values)
        coords = strsplit(this_line);

        if numel(coords) ~= 5
            error("Wrong number of columns in a label line '" + this_line + "'");
        end

        double_line = double(coords);

        % Validate that label index and color values are numeric
        if any(isnan(double_line(1:4)))
            error(ERR + "The label or one of the color coordinates '" + this_line + "' on line " + (ii + 2) + " was not a floating point number.");
        end

        % Extract label index (first column)
        labels(ii) = double_line(1);

        % Extract RGB color values (columns 2-4)
        colors(:, ii) = double_line(2:4);

    end % for

end % function
