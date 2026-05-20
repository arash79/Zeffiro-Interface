function ENV_VARS = FREESURFER_ENV_VARS()
% --- Zeffiro documentation header ---
% utilities.fs2zef.FREESURFER_ENV_VARS — FREESURFER ENV VARS.
%
% Purpose:
%   FREESURFER ENV VARS.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   ENV_VARS
%
% Outputs:
%   ENV_VARS
%
% Calls (project):
%   utilities.fs2zef.FREESURFER_ENV_VARS
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[ENV_VARS] = utilities.fs2zef.FREESURFER_ENV_VARS(ENV_VARS)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%
% FREESURFER_ENV_VARS
%
% A constant function, which returns a list of the environment variable names
% needed by FreeSurfer.
%
% Inputs:
%
% - None.
%
% Outputs:
%
% - ENV_VARS
%
%   The list of environment variable names.
%


    arguments end

    ENV_VARS = [
        "SUBJECTS_DIR" ;
        "FREESURFER" ;
        "FUNCTIONALS_DIR" ;
        "FSFAST_HOME" ;
        "MNI_DIR" ;
        "FSL_DIR" ;
        "FSF_OUTPUT_FORMAT" ;
        "LOCAL_DIR"
    ] ;

end % function
