function affine_matrix = compute_simnibs_to_freesurfer_translation(simnibs_nii, freesurfer_mgz, options)
    %COMPUTE_SIMNIBS_TO_FREESURFER_TRANSLATION  Compute FreeSurfer translation matrix.
    %
    %   Zeffiro Interface.
    %   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
    %   See: https://github.com/sampsapursiainen/zeffiro_interface
    %   Licensed under the GNU General Public License v3.0 (see LICENSE).
    %
    % Computes a 4x4 translation matrix using the FreeSurfer CRAS coordinates:
    %
    %   t = -cras_fs
    %
    % Inputs:
    %   simnibs_nii    - SimNIBS volume path (unused, retained for compatibility)
    %   freesurfer_mgz - FreeSurfer reference volume path
    %   options        - Optional settings:
    %                    .verbose - Print diagnostic information (default: false)
    %
    % Output:
    %   affine_matrix - 4x4 homogeneous translation matrix.
    
        arguments
            simnibs_nii (1,1) string
            freesurfer_mgz (1,1) string {mustBeFile}
            options.verbose (1,1) logical = false
        end
    
        fs_home = getenv('FREESURFER_HOME');
    
        if strlength(fs_home) == 0
            error('sn2zef:EnvNotSet', ...
                'FREESURFER_HOME must be set for MRIread.');
        end
    
        fs_matlab = fullfile(fs_home, 'matlab');
    
        if isfolder(fs_matlab) && ~contains(path, fs_matlab)
            addpath(fs_matlab);
        end
    
        mri_fs = MRIread(char(freesurfer_mgz));
    
        cras_fs = [mri_fs.c_r; mri_fs.c_a; mri_fs.c_s];
    
        t = -cras_fs;
    
        affine_matrix = eye(4);
        affine_matrix(1:3, 4) = t;
    
        if options.verbose
            fprintf('Translation (mm): [%.4f, %.4f, %.4f]\n', t);
            disp(affine_matrix);
        end
    
    end