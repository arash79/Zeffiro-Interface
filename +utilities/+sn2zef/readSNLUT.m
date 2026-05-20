function lut = readSNLUT(folderPath)
% --- Zeffiro documentation header ---
% utilities.sn2zef.readSNLUT — Read SNLUT.
%
% Purpose:
%   Read SNLUT.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   folderPath
%
% Outputs:
%   lut
%
% Calls (project):
%   utilities.sn2zef.readSNLUT
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[lut] = utilities.sn2zef.readSNLUT(folderPath)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
