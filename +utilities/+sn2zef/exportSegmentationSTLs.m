function exportSegmentationSTLs(zef, inFolder, outFolder, inflation_parameter, freesurfer_subject_folder)
%
% exportSegmentationSTLs - Backward-compatible wrapper for export_segmentation_meshes
%
% This function is deprecated. Use export_segmentation_meshes instead, which
% supports translation-only alignment (no coregistration) and returns the
% affine matrix for ZEF import.
%
% Calls export_segmentation_meshes with alignment_mode = 'coregistration'
% to preserve the original behavior (mri_coreg + mri_vol2vol).
%
% See also: export_segmentation_meshes
%

    utilities.sn2zef.export_segmentation_meshes(zef, inFolder, outFolder, ...
        inflation_parameter, freesurfer_subject_folder, ...
        struct('alignment_mode', 'coregistration', 'verbose', false));

end % function
