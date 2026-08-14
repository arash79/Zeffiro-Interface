function lut = readFSLUT()
%READFSLUT  Load FreeSurferColorLUT.txt into a struct of label IDs and RGBA.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   lut = readFSLUT()
%
%   LUT = readFSLUT() reads the FreeSurfer color lookup table from
%   $FREESURFER_HOME/FreeSurferColorLUT.txt, parses the table of label
%   numbers, names, and RGBA values, and returns a struct with fields:
%
%       lut.No    : numeric array of label IDs
%       lut.Name  : cell array of label names (strings)
%       lut.R     : numeric array of red values (0-255)
%       lut.G     : numeric array of green values (0-255)
%       lut.B     : numeric array of blue values (0-255)
%       lut.A     : numeric array of alpha values (0-255)
%
%   The function requires the FREESURFER_HOME environment variable to be set.
%
%   Example:
%       setenv('FREESURFER_HOME', '/usr/local/freesurfer');
%       lut = readFSLUT();
%       idx = strcmp(lut.Name, 'Left-Cerebral-White-Matter');
%       fprintf('Label %d: RGB = [%d, %d, %d]\n', ...
%               lut.No(idx), lut.R(idx), lut.G(idx), lut.B(idx));
%
%   See also: runParcellation

    % Check that FREESURFER_HOME is set
    fsHome = getenv('FREESURFER_HOME');
    if isempty(fsHome)
        error('readFSLUT:NoFSHome', ...
              ['Environment variable FREESURFER_HOME is not set.\n' ...
               'In MATLAB run: setenv(''FREESURFER_HOME'',''/path/to/freesurfer'')']);
    end

    % Build full path to FreeSurferColorLUT.txt
    fname = fullfile(fsHome, 'FreeSurferColorLUT.txt');

    % Verify file exists
    if ~exist(fname, 'file')
        error('readFSLUT:NoFile', ...
              ['Could not find ''FreeSurferColorLUT.txt'' at:\n' ...
               '  %s\n\n' ...
               'Please verify that FREESURFER_HOME is set correctly.'], fname);
    end

    % Open file for reading
    fid = fopen(fname, 'rt');
    if fid < 0
        error('readFSLUT:OpenFailed', ...
              'Failed to open "%s" for reading.', fname);
    end

    % Parse LUT file: format is "ID Name R G B A"
    % Skip header lines starting with '#', then parse each data row
    C = textscan(fid, '%d %s %d %d %d %d', ...
                 'CommentStyle', '#', ...
                 'CollectOutput', false);
    fclose(fid);

    % Pack parsed data into output struct
    lut.No   = C{1};  % Label ID numbers
    lut.Name = C{2};  % Label names (cell array of strings)
    lut.R    = C{3};  % Red channel values (0-255)
    lut.G    = C{4};  % Green channel values (0-255)
    lut.B    = C{5};  % Blue channel values (0-255)
    lut.A    = C{6};  % Alpha channel values (0-255)

end
