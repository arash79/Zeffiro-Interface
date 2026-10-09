function affine_matrix = compute_ras_center_translation(reference_mgz, options)
%COMPUTE_RAS_CENTER_TRANSLATION  Scanner RAS → surface RAS translation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   affine_matrix = compute_ras_center_translation(reference_mgz, options)
%
% Watershed head surfaces written without mri_watershed -useSRAS
% (inner_skull, outer_skull, outer_skin) store vertices in scanner RAS.
% FreeSurfer volume meshes from mri_mc, and the pial/white surfaces, are
% in surface RAS. Those frames differ by the volume CRAS:
%
%   surface_RAS = scanner_RAS - cras
%   t = -cras,   cras = [c_r; c_a; c_s]
%
% This is the same translation as
% utilities.sn2zef.transforms.compute_simnibs_to_freesurfer_translation.
% Vertex columns are (R, A, S), so the translation is [-c_r; -c_a; -c_s]
% even though get_volume_centers returns c_s before c_a.
%
% Inputs:
%   reference_mgz - FreeSurfer volume whose CRAS defines surface RAS
%                   (normally mri/orig.mgz)
%   options       - .verbose prints the center and the 4x4 (default: false)
%
% Output:
%   affine_matrix - 4x4 homogeneous translation. Embed it as affine_transform
%                   on the head-surface rows; do not rewrite the mesh files.

    arguments
        reference_mgz (1,1) string {mustBeFile}
        options.verbose (1,1) logical = false
    end

    [c_r, c_s, c_a] = utilities.fs2zef.readers.get_volume_centers(reference_mgz);

    t = [-c_r; -c_a; -c_s];

    affine_matrix = eye(4);
    affine_matrix(1:3, 4) = t;

    if options.verbose
        fprintf('RAS center (R, A, S): [%.4f, %.4f, %.4f]\n', c_r, c_a, c_s);
        fprintf('Translation (mm): [%.4f, %.4f, %.4f]\n', t);
        disp(affine_matrix);
    end

end
