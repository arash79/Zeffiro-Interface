function lut = readSNLUT(folderPath)
%READSNLUT  Parse SimNIBS final_tissues_LUT.txt (id, name, RGBA).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   File must sit in folderPath. Lines: label_number label_name R G B A;
%   '#' comments skipped. Used by export_segmentation_meshes to name
%   compartments in import_segmentations.zef.
%
%   lut = readSNLUT(folderPath)
%   lut.No, .Name, .R, .G, .B, .A
%
%   See also export_segmentation_meshes.

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
