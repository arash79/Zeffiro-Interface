function setup_freesurfer_env(FREESURFER_HOME, options)
%SETUP_FREESURFER_ENV  Set FreeSurfer environment variables (Matlab FreeSurferEnv.sh).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   setup_freesurfer_env(FREESURFER_HOME, options)
%
% Matlab implementation of FreeSurferEnv.sh that sets up all required
% environment variables for FreeSurfer operations. Validates directories
% and adds FreeSurfer binaries to PATH.
%
% This is extracted and refactored from the original fs2zef run.m function
% for better modularity and reusability.
%
% Inputs:
%   FREESURFER_HOME - Path to FreeSurfer installation directory
%   options         - (optional) Struct with options:
%                     .fs_override - Use default paths if vars not set (default: true)
%                     .verbose     - Print environment info (default: true)
%
% Outputs:
%   None (sets environment variables)
%
% Example:
%   utilities.fs2zef.environment.setup_freesurfer_env('/usr/local/freesurfer');
%

    arguments
        FREESURFER_HOME (1,1) string { mustBeFolder }
        options.fs_override (1,1) logical = true
        options.verbose (1,1) logical = true
    end
    
    if options.verbose
        disp(newline + "Setting up FreeSurfer environment…")
    end
    
    % Validate FREESURFER_HOME
    build_stamp_path = fullfile(FREESURFER_HOME, "build-stamp.txt");
    if ~isfile(build_stamp_path)
        warning("The file " + build_stamp_path + " does not exist. Is FreeSurfer installed correctly?");
    end
    
    % Get FS_OVERRIDE setting
    FS_OVERRIDE = char(getenv("FS_OVERRIDE"));
    if strlength(FS_OVERRIDE) == 0
        FS_OVERRIDE = options.fs_override;
    else
        FS_OVERRIDE = logical(str2double(FS_OVERRIDE));
    end
    
    % Set up all FreeSurfer environment variables
    env_vars = utilities.fs2zef.FREESURFER_ENV_VARS();
    
    for ii = 1:numel(env_vars)
        env_var = env_vars(ii);
        check_and_set_env_variable(env_var, FREESURFER_HOME, FS_OVERRIDE);
    end
    
    % Add FreeSurfer binaries to PATH
    FREESURFER_BIN = fullfile(FREESURFER_HOME, "bin");
    
    if ~isfolder(FREESURFER_BIN)
        error("FreeSurfer binaries could not be located in " + FREESURFER_BIN);
    end
    
    PATH = string(getenv("PATH"));
    
    if ~startsWith(PATH, FREESURFER_BIN)
        NEWPATH = FREESURFER_BIN + ":" + PATH;
        setenv("PATH", NEWPATH);
        
        if options.verbose
            disp("Added FreeSurfer binaries to PATH");
        end
    end
    
    % Display environment if verbose
    if options.verbose
        disp(newline);
        disp("FREESURFER_HOME   → " + getenv("FREESURFER_HOME"));
        disp("FSFAST_HOME       → " + getenv("FSFAST_HOME"));
        disp("FSF_OUTPUT_FORMAT → " + getenv("FSF_OUTPUT_FORMAT"));
        disp("SUBJECTS_DIR      → " + getenv("SUBJECTS_DIR"));
        disp("MNI_DIR           → " + getenv("MNI_DIR"));
        disp("FSL_DIR           → " + getenv("FSL_DIR"));
        disp(newline);
    end
    
end % main function

%% Helper function

function check_and_set_env_variable(variable_name, FREESURFER_HOME, FS_OVERRIDE)
    % Check and set individual FreeSurfer environment variable
    % This mirrors the logic from FreeSurferEnv.sh
    
    variable_value = getenv(variable_name);
    variable_set = strlength(variable_value) > 0;
    variable_not_set = ~variable_set;
    
    switch variable_name
        case "FREESURFER_HOME"
            if variable_not_set
                error("FREESURFER_HOME must be set before calling this function");
            end
            
        case "FREESURFER"
            if variable_not_set
                setenv("FREESURFER", FREESURFER_HOME);
            end
            
        case "SUBJECTS_DIR"
            if variable_not_set && FS_OVERRIDE
                variable_value = fullfile(FREESURFER_HOME, "subjects");
                setenv("SUBJECTS_DIR", variable_value);
            end
            if ~isfolder(variable_value)
                error("SUBJECTS_DIR " + variable_value + " does not exist");
            end
            
        case "FSFAST_HOME"
            if variable_not_set && FS_OVERRIDE
                variable_value = fullfile(FREESURFER_HOME, "fsfast");
                setenv("FSFAST_HOME", variable_value);
            end
            if ~isfolder(variable_value)
                error("FSFAST_HOME " + variable_value + " does not exist");
            end
            
        case "MNI_DIR"
            setup_mni_environment(FREESURFER_HOME, FS_OVERRIDE);
            
        case "FSL_DIR"
            setup_fsl_environment(FREESURFER_HOME, FS_OVERRIDE);
            
        case "FSF_OUTPUT_FORMAT"
            if variable_not_set && FS_OVERRIDE
                setenv("FSF_OUTPUT_FORMAT", "nii.gz");
            end
            
        case "FUNCTIONALS_DIR"
            if variable_not_set && FS_OVERRIDE
                setenv("FUNCTIONALS_DIR", fullfile(FREESURFER_HOME, "sessions"));
            end
            
        case "LOCAL_DIR"
            setenv("LOCAL_DIR", fullfile(FREESURFER_HOME, "local"));
            
        otherwise
            warning("Unknown FreeSurfer environment variable: " + variable_name);
    end
    
end % function

function setup_mni_environment(FREESURFER_HOME, FS_OVERRIDE)
    % Set up MNI-related environment variables
    
    NO_MINC = getenv("NO_MINC");
    NO_MINC_SET = strlength(NO_MINC) > 0;
    
    if NO_MINC_SET
        return;  % MINC disabled
    end
    
    % Try to find MINC toolkit
    default_mni_dir = fullfile(FREESURFER_HOME, "mni");
    
    if isfolder(fullfile(default_mni_dir, "bin"))
        setenv("MINC_BIN_DIR", fullfile(default_mni_dir, "bin"));
        setenv("MNI_DIR", default_mni_dir);
    end
    
    if isfolder(fullfile(default_mni_dir, "lib"))
        setenv("MINC_LIB_DIR", fullfile(default_mni_dir, "lib"));
    end
    
    if isfolder(fullfile(default_mni_dir, "data"))
        setenv("MNI_DATAPATH", fullfile(default_mni_dir, "data"));
    end
    
end % function

function setup_fsl_environment(FREESURFER_HOME, FS_OVERRIDE)
    % Set up FSL-related environment variables
    
    FSL_DIR = getenv("FSL_DIR");
    FSL_DIR_SET = strlength(FSL_DIR) > 0;
    
    if FSL_DIR_SET
        return;  % Already set
    end
    
    % Try default locations
    default_fsl_dir = fullfile(FREESURFER_HOME, "fsl");
    
    if isfolder(default_fsl_dir) && FS_OVERRIDE
        setenv("FSL_DIR", default_fsl_dir);
    end
    
end % function
