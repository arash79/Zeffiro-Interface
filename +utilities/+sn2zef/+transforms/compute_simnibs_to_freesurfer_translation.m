function affine_matrix = compute_simnibs_to_freesurfer_translation(simnibs_nii, freesurfer_mgz, options)
%COMPUTE_SIMNIBS_TO_FREESURFER_TRANSLATION  4×4 SimNIBS NIfTI vox2ras → FreeSurfer RAS alignment matrix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%


%
% compute_simnibs_to_freesurfer_translation - Align SimNIBS RAS to FreeSurfer RAS
%
% Builds a 4x4 affine matrix (rotation + translation) from volume headers only.
% It maps coordinates produced by applying each volume's vox2ras to voxel indices
% in (col, row, slice) order, so that SimNIBS-derived RAS points match the
% FreeSurfer RAS frame used by mri/orig.mgz. This replaces the earlier pure
% translation between bounding-box centres, which fails when the two volumes
% differ in orientation (common between SimNIBS NIfTI and FreeSurfer .mgz).
%
% Definition:
%   Rsim = linear part of SimNIBS vox2ras, Rfs = linear part of FS vox2ras
%   R = Rfs * inv(Rsim)   maps SimNIBS RAS vectors to FS RAS (same origin choice)
%   t = cras_fs - R * cras_sim
% where cras_* are the volume centres (c_r, c_a, c_s) from MRIread.
%
% When R is ill-conditioned, falls back to pure translation between voxel-space
% centres projected through each vox2ras (legacy behaviour).
%
% Inputs:
%   simnibs_nii    - Full path to SimNIBS segmentation (final_tissues.nii.gz)
%   freesurfer_mgz - Full path to FreeSurfer reference volume (mri/orig.mgz)
%   options        - (optional) Struct:
%                    .verbose - Print diagnostic info (default: false)
%
% Outputs:
%   affine_matrix - 4x4 homogeneous matrix applied by ZEF as affine_transform
%                   (see m/mesh/zef_process_meshes.m: post-multiply mesh rows).
%
% See also: export_segmentation_meshes, save_volume_atlas_points
%

    arguments
        simnibs_nii (1,1) string { mustBeFile }
        freesurfer_mgz (1,1) string { mustBeFile }
        options.verbose (1,1) logical = false
    end

    % Ensure FreeSurfer MATLAB toolbox (MRIread) is on path
    fs_home = getenv('FREESURFER_HOME');
    if strlength(fs_home) == 0
        error('sn2zef:EnvNotSet', ...
            'FREESURFER_HOME must be set for MRIread.');
    end
    fs_matlab = fullfile(fs_home, 'matlab');
    fsf_tb = fullfile(fs_home, 'fsfast', 'toolbox');
    for p = {fs_matlab, fsf_tb}
        pth = p{1};
        if isfolder(pth) && ~contains(path, pth)
            addpath(pth);
        end
    end

    warn_id = 'MATLAB:RandStream:ActivatingLegacyGenerators';
    warn_state = warning('off', warn_id);
    try
        mri_sim = MRIread(char(simnibs_nii));
    catch ME
        warning(warn_state);
        error('sn2zef:ReadSimNIBS', ...
            'Failed to read SimNIBS volume "%s": %s', simnibs_nii, ME.message);
    end

    try
        mri_fs = MRIread(char(freesurfer_mgz));
    catch ME
        warning(warn_state);
        error('sn2zef:ReadFreeSurfer', ...
            'Failed to read FreeSurfer volume "%s": %s', freesurfer_mgz, ME.message);
    end
    warning(warn_state);

    Rsim = mri_sim.vox2ras(1:3, 1:3);
    Rfs  = mri_fs.vox2ras(1:3, 1:3);

    use_rotation = true;
    cond_sim = cond(Rsim);
    if cond_sim > 1e8 || any(~isfinite(Rsim(:)))
        use_rotation = false;
        warning('sn2zef:IllConditionedVox2Ras', ...
            'SimNIBS vox2ras linear part is ill-conditioned (cond=%.3g). Using translation-only fallback.', cond_sim);
    end

    if use_rotation
        try
            R = Rfs / Rsim;  % R * Rsim = Rfs
        catch
            use_rotation = false;
        end
    end

    % CRAS / volume centre in RAS (preferred when MRIread provides it)
    if isfield(mri_sim, 'c_r') && isfield(mri_fs, 'c_r')
        cras_sim = [mri_sim.c_r; mri_sim.c_a; mri_sim.c_s];
        cras_fs  = [mri_fs.c_r; mri_fs.c_a; mri_fs.c_s];
    else
        sz_sim = size(mri_sim.vol);
        sz_fs  = size(mri_fs.vol);
        cr_sim = (sz_sim(2) - 1) / 2 + 0.5;
        rr_sim = (sz_sim(1) - 1) / 2 + 0.5;
        sr_sim = (sz_sim(3) - 1) / 2 + 0.5;
        cras_sim = mri_sim.vox2ras(1:3, :) * [cr_sim; rr_sim; sr_sim; 1];
        cr_fs = (sz_fs(2) - 1) / 2 + 0.5;
        rr_fs = (sz_fs(1) - 1) / 2 + 0.5;
        sr_fs = (sz_fs(3) - 1) / 2 + 0.5;
        cras_fs = mri_fs.vox2ras(1:3, :) * [cr_fs; rr_fs; sr_fs; 1];
    end

    if use_rotation
        t = cras_fs - R * cras_sim;
        affine_matrix = [R, t; 0, 0, 0, 1];
    else
        % Legacy: pure translation between voxel-space centres in RAS
        t = cras_fs - cras_sim;
        affine_matrix = [eye(3), t; 0, 0, 0, 1];
    end

    if options.verbose
        fprintf('\n=== SimNIBS-to-FreeSurfer affine (header-based) ===\n');
        fprintf('SimNIBS volume: %s\n', simnibs_nii);
        fprintf('FreeSurfer volume: %s\n', freesurfer_mgz);
        fprintf('CRAS Sim (RAS): (%.4f, %.4f, %.4f)\n', cras_sim(1), cras_sim(2), cras_sim(3));
        fprintf('CRAS FS  (RAS): (%.4f, %.4f, %.4f)\n', cras_fs(1), cras_fs(2), cras_fs(3));
        if use_rotation
            fprintf('Using full linear map Rfs * inv(Rsim) plus CRAS translation.\n');
        else
            fprintf('Using translation-only fallback.\n');
        end
        fprintf('Affine (4x4):\n');
        disp(affine_matrix);
        fprintf('==================================================\n\n');
    end

end % function
