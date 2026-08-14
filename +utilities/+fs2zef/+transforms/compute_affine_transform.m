function affine_matrix = compute_affine_transform(source_mgz, target_mgz, options)
%COMPUTE_AFFINE_TRANSFORM  4×4 translation aligning two FreeSurfer volume CRAS centers.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   affine_matrix = compute_affine_transform(source_mgz, target_mgz, options)
%
% Calculates a 4x4 affine transformation matrix to align the source volume's
% coordinate space with the target volume's coordinate space. This is essential
% for aligning specialized segmentations (e.g., thalamic nuclei) with the
% standard FreeSurfer space (orig.mgz).
%
% The transformation is computed using volume center offsets (c_r, c_s, c_a)
% extracted from each volume's header via mri_info.
%
% Inputs:
%   source_mgz - Full path to source .mgz volume (e.g., ThalamicNuclei.mgz)
%   target_mgz - Full path to target .mgz volume (e.g., orig.mgz)
%   options    - (optional) Struct with options:
%                .verbose - Print detailed information (default: false)
%
% Outputs:
%   affine_matrix - 4x4 homogeneous transformation matrix:
%                   [1  0  0  dx]
%                   [0  1  0  dy]
%                   [0  0  1  dz]
%                   [0  0  0   1]
%                   where dx = source_c_r - target_c_r, etc.
%
% Example:
%   source = fullfile(subjects_dir, 'subject01', 'mri', 'ThalamicNuclei.mgz');
%   target = fullfile(subjects_dir, 'subject01', 'mri', 'orig.mgz');
%   affine = utilities.fs2zef.transforms.compute_affine_transform(source, target);
%
% See also: utilities.fs2zef.readers.get_volume_centers
%

    arguments
        source_mgz (1,1) string { mustBeFile }
        target_mgz (1,1) string { mustBeFile }
        options.verbose (1,1) logical = false
    end
    
    % Get volume centers from source
    try
        [source_cr, source_cs, source_ca] = utilities.fs2zef.readers.get_volume_centers(source_mgz);
    catch ME
        error('compute_affine_transform:SourceFailed', ...
            'Failed to get volume centers from source file "%s": %s', ...
            source_mgz, ME.message);
    end
    
    % Get volume centers from target
    try
        [target_cr, target_cs, target_ca] = utilities.fs2zef.readers.get_volume_centers(target_mgz);
    catch ME
        error('compute_affine_transform:TargetFailed', ...
            'Failed to get volume centers from target file "%s": %s', ...
            target_mgz, ME.message);
    end
    
    % Compute translation offsets
    dx = source_cr - target_cr;
    dy = source_cs - target_cs;
    dz = source_ca - target_ca;
    
    % Build 4x4 affine transformation matrix
    % This is a pure translation (no rotation or scaling)
    affine_matrix = [
        1  0  0  dx ;
        0  1  0  dy ;
        0  0  1  dz ;
        0  0  0   1
    ];
    
    % Verbose output
    if options.verbose
        fprintf('\n=== Affine Transform Computation ===\n');
        fprintf('Source volume: %s\n', source_mgz);
        fprintf('  Center (R,S,A): (%.4f, %.4f, %.4f)\n', source_cr, source_cs, source_ca);
        fprintf('Target volume: %s\n', target_mgz);
        fprintf('  Center (R,S,A): (%.4f, %.4f, %.4f)\n', target_cr, target_cs, target_ca);
        fprintf('Translation (dx, dy, dz): (%.4f, %.4f, %.4f)\n', dx, dy, dz);
        fprintf('Affine matrix:\n');
        disp(affine_matrix);
        fprintf('====================================\n\n');
    end
    
end % function
