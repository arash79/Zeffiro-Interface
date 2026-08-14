function [c_r, c_s, c_a] = get_volume_centers(mgzFile)
%GET_VOLUME_CENTERS  Read c_r, c_s, c_a center offsets from mri_info on .mgz.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [c_r, c_s, c_a] = get_volume_centers(mgzFile)
%
%   [c_r, c_s, c_a] = get_volume_centers(mgzFile) sets up the FreeSurfer
%   environment, runs mri_info on the .mgz file, and parses the center
%   offsets along the R (right), S (superior), and A (anterior) axes.
%
%   Inputs:
%       mgzFile  - Full path to a FreeSurfer .mgz volume file
%
%   Outputs:
%       c_r      - Center offset along the R (right) axis
%       c_s      - Center offset along the S (superior) axis
%       c_a      - Center offset along the A (anterior) axis
%
%   The function requires FREESURFER_HOME to be set and mri_info to be
%   available in the system PATH.
%
%   Example:
%       mgzFile = fullfile(getenv('SUBJECTS_DIR'), 'subject1', 'mri', 'orig.mgz');
%       [c_r, c_s, c_a] = get_volume_centers(mgzFile);
%       fprintf('Volume center: R=%.2f, S=%.2f, A=%.2f\n', c_r, c_s, c_a);
%
%   See also: runParcellation

    % Validate input
    if nargin < 1 || isempty(mgzFile)
        error('get_volume_centers:NoInput', ...
              'Input mgzFile is required.');
    end

    % Check that FREESURFER_HOME is set
    fsHome = getenv('FREESURFER_HOME');
    if isempty(fsHome)
        error('get_volume_centers:NoFSHome', ...
              ['Environment variable FREESURFER_HOME is not set.\n' ...
               'In MATLAB run: setenv(''FREESURFER_HOME'',''/path/to/freesurfer'')']);
    end

    % Verify input file exists
    if ~exist(mgzFile, 'file')
        error('get_volume_centers:FileNotFound', ...
              'MGZ file not found: %s', mgzFile);
    end

    % Configure FreeSurfer environment by sourcing setup script
    setupCmd = sprintf('source %s/SetUpFreeSurfer.sh', fsHome);

    % Run mri_info in a login shell to ensure proper environment setup
    % The -lc flag ensures bash reads profile files and sets up environment
    bashCmd = sprintf('bash -lc "%s && mri_info %s"', setupCmd, mgzFile);
    [status, output] = system(bashCmd);

    % Check if mri_info executed successfully
    if status ~= 0
        error('get_volume_centers:mriInfoFailed', ...
              ['mri_info failed with exit code %d:\n%s\n\n' ...
               'Please verify that FREESURFER_HOME is set correctly and ' ...
               'mri_info is available in PATH.'], status, output);
    end

    % Parse center offsets from mri_info output
    % mri_info outputs lines like "c_r = 127.5" which we extract via regex
    cr_tok = regexp(output, 'c_r\s*=\s*([-\d\.]+)', 'tokens', 'once');
    cs_tok = regexp(output, 'c_s\s*=\s*([-\d\.]+)', 'tokens', 'once');
    ca_tok = regexp(output, 'c_a\s*=\s*([-\d\.]+)', 'tokens', 'once');

    % Validate that all three values were found
    if isempty(cr_tok) || isempty(cs_tok) || isempty(ca_tok)
        error('get_volume_centers:ParseFailed', ...
              ['Failed to parse center offsets from mri_info output.\n' ...
               'Expected format: c_r = <value>, c_s = <value>, c_a = <value>\n' ...
               'Actual output:\n%s'], output);
    end

    % Convert parsed strings to numeric values
    c_r = str2double(cr_tok{1});
    c_s = str2double(cs_tok{1});
    c_a = str2double(ca_tok{1});

    % Validate conversion was successful
    if isnan(c_r) || isnan(c_s) || isnan(c_a)
        error('get_volume_centers:ConversionFailed', ...
              'Failed to convert parsed center offsets to numeric values.');
    end

end
