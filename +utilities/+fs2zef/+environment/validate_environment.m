function report = validate_environment(options)
%VALIDATE_ENVIRONMENT  Check FreeSurfer env vars, paths, and required binaries.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   report = validate_environment(options)
%
% Checks all required environment variables, directories, and dependencies
% before running the pipeline. Returns a detailed report of what's available
% and what's missing.
%
% Inputs:
%   options - (optional) Struct with validation options:
%             .required_binaries  - Cell array of required binaries
%             .optional_binaries  - Cell array of optional binaries
%             .check_subjects_dir - Validate SUBJECTS_DIR (default: true)
%             .verbose            - Print report (default: true)
%
% Outputs:
%   report - Struct with validation results:
%            .valid              - Overall validation status (true/false)
%            .errors             - Cell array of error messages
%            .warnings           - Cell array of warning messages
%            .freesurfer_home    - FREESURFER_HOME value
%            .subjects_dir       - SUBJECTS_DIR value
%            .binaries_found     - Struct of binary availability
%            .environment_vars   - Struct of environment variable values
%
% Example:
%   report = utilities.fs2zef.environment.validate_environment();
%   if ~report.valid
%       error('Environment validation failed');
%   end
%

    arguments
        options.required_binaries cell = {'mris_convert', 'mri_mc', 'mri_watershed', ...
                                          'mri_annotation2label', 'mri_mergelabels'}
        options.optional_binaries cell = {'mri_binarize', 'mri_info', 'mri_segstats', 'recon_all'}
        options.check_subjects_dir (1,1) logical = true
        options.verbose (1,1) logical = true
    end
    
    report = struct();
    report.valid = true;
    report.errors = {};
    report.warnings = {};
    report.binaries_found = struct();
    report.environment_vars = struct();
    
    if options.verbose
        fprintf('\n=== Validating FreeSurfer Environment ===\n');
    end
    
    % Check FREESURFER_HOME
    FREESURFER_HOME = getenv('FREESURFER_HOME');
    report.environment_vars.FREESURFER_HOME = FREESURFER_HOME;
    
    if isempty(FREESURFER_HOME)
        report.valid = false;
        report.errors{end+1} = 'FREESURFER_HOME is not set';
        if options.verbose
            fprintf('FREESURFER_HOME: NOT SET\n');
        end
    else
        if ~isfolder(FREESURFER_HOME)
            report.valid = false;
            report.errors{end+1} = sprintf('FREESURFER_HOME points to non-existent directory: %s', FREESURFER_HOME);
            if options.verbose
                fprintf('FREESURFER_HOME: %s (DOES NOT EXIST)\n', FREESURFER_HOME);
            end
        else
            if options.verbose
                fprintf('FREESURFER_HOME: %s\n', FREESURFER_HOME);
            end
            
            % Check for build-stamp.txt
            build_stamp = fullfile(FREESURFER_HOME, 'build-stamp.txt');
            if ~isfile(build_stamp)
                report.warnings{end+1} = 'build-stamp.txt not found - FreeSurfer may not be properly installed';
                if options.verbose
                    fprintf('build-stamp.txt: NOT FOUND\n');
                end
            end
        end
    end
    
    % Check SUBJECTS_DIR
    if options.check_subjects_dir
        SUBJECTS_DIR = getenv('SUBJECTS_DIR');
        report.environment_vars.SUBJECTS_DIR = SUBJECTS_DIR;
        
        if isempty(SUBJECTS_DIR)
            report.warnings{end+1} = 'SUBJECTS_DIR is not set';
            if options.verbose
                fprintf('SUBJECTS_DIR: NOT SET\n');
            end
        elseif ~isfolder(SUBJECTS_DIR)
            report.warnings{end+1} = sprintf('SUBJECTS_DIR does not exist: %s', SUBJECTS_DIR);
            if options.verbose
                fprintf('SUBJECTS_DIR: %s (DOES NOT EXIST)\n', SUBJECTS_DIR);
            end
        else
            report.subjects_dir = SUBJECTS_DIR;
            if options.verbose
                fprintf('SUBJECTS_DIR: %s\n', SUBJECTS_DIR);
            end
        end
    end
    
    % Check FreeSurfer bin directory
    if ~isempty(FREESURFER_HOME) && isfolder(FREESURFER_HOME)
        FS_BIN = fullfile(FREESURFER_HOME, 'bin');
        if ~isfolder(FS_BIN)
            report.valid = false;
            report.errors{end+1} = sprintf('FreeSurfer bin directory not found: %s', FS_BIN);
            if options.verbose
                fprintf('FreeSurfer bin: NOT FOUND\n');
            end
        else
            if options.verbose
                fprintf('FreeSurfer bin: %s\n', FS_BIN);
            end
        end
    end
    
    % Check required binaries
    if options.verbose
        fprintf('\nChecking required binaries:\n');
    end
    
    for ii = 1:numel(options.required_binaries)
        bin_name = options.required_binaries{ii};
        [status, ~] = system(sprintf('which %s', bin_name));
        found = (status == 0);
        % Replace hyphens with underscores for valid field names
        field_name = strrep(bin_name, '-', '_');
        report.binaries_found.(field_name) = found;
        
        if ~found
            report.valid = false;
            report.errors{end+1} = sprintf('Required binary not found: %s', bin_name);
            if options.verbose
                fprintf('%s: NOT FOUND\n', bin_name);
            end
        else
            if options.verbose
                fprintf('%s: FOUND\n', bin_name);
            end
        end
    end
    
    % Check optional binaries
    if options.verbose
        fprintf('\nChecking optional binaries:\n');
    end
    
    for ii = 1:numel(options.optional_binaries)
        bin_name = options.optional_binaries{ii};
        [status, ~] = system(sprintf('which %s', bin_name));
        found = (status == 0);
        % Replace hyphens with underscores for valid field names
        field_name = strrep(bin_name, '-', '_');
        report.binaries_found.(field_name) = found;
        
        if ~found
            report.warnings{end+1} = sprintf('Optional binary not found: %s', bin_name);
            if options.verbose
                fprintf('%s: NOT FOUND\n', bin_name);
            end
        else
            if options.verbose
                fprintf('%s: FOUND\n', bin_name);
            end
        end
    end
    
    % Summary
    if options.verbose
        fprintf('\n=== Validation Summary ===\n');
        fprintf('Status: %s\n', iff(report.valid, 'VALID', 'INVALID'));
        fprintf('Errors: %d\n', numel(report.errors));
        fprintf('Warnings: %d\n', numel(report.warnings));
        
        if ~isempty(report.errors)
            fprintf('\nErrors:\n');
            for ii = 1:numel(report.errors)
                fprintf('  - %s\n', report.errors{ii});
            end
        end
        
        if ~isempty(report.warnings)
            fprintf('\nWarnings:\n');
            for ii = 1:numel(report.warnings)
                fprintf('  - %s\n', report.warnings{ii});
            end
        end
        
        fprintf('==========================\n\n');
    end
    
end % function

function result = iff(condition, true_val, false_val)
    % Inline if-else
    if condition
        result = true_val;
    else
        result = false_val;
    end
end % function
