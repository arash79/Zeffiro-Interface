function run_and_print_command(cmd)
%RUN_AND_PRINT_COMMAND  Run shell command with echoed stdout/stderr for sn2zef tooling.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%


%
% run_and_print_command
%
% Executes a shell command via the system() function and displays both the
% command and its output to the MATLAB console. If the command exits with
% a non-zero status code, an error is thrown with diagnostic information.
%
% Inputs:
%
% - cmd (1,1) string
%
%   The shell command to execute, as a character vector or string. The
%   command should be fully specified with all required arguments and
%   paths. Example: 'ls -l /path/to/directory' or a concatenated string
%   built from fullfile() calls.
%
% Outputs:
%
%   None. The function prints to the console and throws an error on
%   failure.
%
% Example:
%
%   FREESURFER_BIN = fullfile(getenv('FREESURFER_HOME'),'bin');
%   cmd = sprintf('%s --mov %s --ref %s --reg %s', ...
%         fullfile(FREESURFER_BIN,'mri_coreg'), ...
%         fullfile(inFolder,'final_tissues.nii.gz'), ...
%         fullfile(fsSubj,'mri/aseg.mgz'), ...
%         fullfile(outFolder,'simnibs_to_subject.lta'));
%   run_and_print_command(cmd);
%

    % Convert string array to character vector if necessary
    % MATLAB's system() function requires char input
    if isa(cmd,'string')
        cmd = char(cmd);
    end

    % Display the command that will be executed
    fprintf('\n>> Running command:\n%s\n', cmd);

    % Execute the shell command and capture output
    [status, out] = system(cmd);

    % Check command exit status
    % status = 0 indicates success, non-zero indicates failure
    if status ~= 0
        % Display error information
        fprintf('!! Command failed with status %d:\n%s\n', status, out);
        error('run_and_print_command:CommandError', ...
              'Shell command exited with status %d.', status);
    else
        % Display success message and command output
        fprintf('>> Command completed successfully. Output:\n%s\n', out);
    end

end % function
