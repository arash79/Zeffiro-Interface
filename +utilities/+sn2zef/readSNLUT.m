function lut = readSNLUT(folderPath)
%
% readSNLUT
%
% Reads a SimNIBS label lookup table (LUT) from final_tissues_LUT.txt in
% the specified folder. The LUT file contains label numbers, names, and
% RGBA color values for each tissue type in the segmentation.
%
% Inputs:
%
% - folderPath (1,1) string { mustBeFolder }
%
%   The directory containing final_tissues_LUT.txt. The file should be a
%   space-separated text file with columns: label_number, label_name,
%   red, green, blue, alpha. Lines starting with '#' are treated as
%   comments and ignored.
%
% Outputs:
%
% - lut (1,1) struct
%
%   A structure containing the parsed LUT data with fields:
%     • No   - Column vector of label ID numbers (integers)
%     • Name - Cell array of label name strings
%     • R    - Column vector of red color values (0-255)
%     • G    - Column vector of green color values (0-255)
%     • B    - Column vector of blue color values (0-255)
%     • A    - Column vector of alpha color values (0-255)
%
% Throws an error if the file cannot be found or opened.
%

    % Construct full path to SimNIBS label lookup table file
    fname = fullfile(folderPath, 'final_tissues_LUT.txt');

    % Validate that the LUT file exists
    if ~exist(fname,'file')
        error('readSNLUT:NoFile', ...
              'Could not find ''final_tissues_LUT.txt'' in folder "%s".', folderPath);
    end

    % Open file for reading
    fid = fopen(fname,'rt');

    if fid<0
        error('readSNLUT:OpenFailed', ...
              'Failed to open "%s" for reading.', fname);
    end

    % Parse LUT file format:
    % Each line: label_number label_name red green blue alpha
    % Lines starting with '#' are treated as comments and ignored
    C = textscan(fid, '%d %s %d %d %d %d', ...
                 'CommentStyle', '#', ...
                 'CollectOutput', false);

    fclose(fid);

    % Extract parsed data into output structure
    lut.No   = C{1};  % Label numbers (integers)
    lut.Name = C{2};  % Label names (cell array of strings)
    lut.R    = C{3};  % Red color component (0-255)
    lut.G    = C{4};  % Green color component (0-255)
    lut.B    = C{5};  % Blue color component (0-255)
    lut.A    = C{6};  % Alpha (transparency) component (0-255)

end % function
