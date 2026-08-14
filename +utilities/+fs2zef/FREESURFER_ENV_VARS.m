function ENV_VARS = FREESURFER_ENV_VARS()
%FREESURFER_ENV_VARS  Names setup_freesurfer_env may set (not including FREESURFER_HOME).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ENV_VARS = FREESURFER_ENV_VARS()
%
%   Returns SUBJECTS_DIR, FREESURFER, FUNCTIONALS_DIR, FSFAST_HOME, MNI_DIR,
%   FSL_DIR, FSF_OUTPUT_FORMAT, LOCAL_DIR. run() still requires FREESURFER_HOME
%   separately (not in this list).
%


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
