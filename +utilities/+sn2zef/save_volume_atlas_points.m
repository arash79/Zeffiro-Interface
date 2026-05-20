function pts_filename = save_volume_atlas_points(volume_data, voxel_to_ras, affine_matrix, out_folder, voxel_stride)
%
% save_volume_atlas_points - Write parcellation point samples from a labeled
% volume.
%
% The output is an ASCII matrix consumed by the .dat branch of
% zef_import_parcellation_points. Rows are
% [voxel_index_0based, x, y, z].
%
% Inputs:
%
% - volume_data
%   Labeled volume. Non-zero voxels become candidate points.
%
% - voxel_to_ras (4,4) double
%   Transform from voxel coordinates to RAS coordinates.
%
% - affine_matrix
%   Optional 4-by-4 transform applied after voxel_to_ras. Pass [] to skip.
%
% - out_folder (1,1) string { mustBeFolder }
%   Existing directory where sn_atlas_points.dat is written.
%
% - voxel_stride (1,1) double
%   Sampling stride in each voxel dimension.
%
% Outputs:
%
% - pts_filename (1,1) string
%   Basename of the written point file.
%
% See also: utilities.sn2zef.export_segmentation_meshes
%

    arguments
        volume_data { mustBeNumeric }
        voxel_to_ras (4,4) double
        affine_matrix
        out_folder (1,1) string { mustBeFolder }
        voxel_stride (1,1) double { mustBePositive, mustBeInteger } = 4
    end

    if ~isempty(affine_matrix) && ~isequal(size(affine_matrix), [4 4])
        error('sn2zef:BadAffine', 'affine_matrix must be empty or 4-by-4.');
    end

    pts_filename = "sn_atlas_points.dat";
    pts_path = fullfile(out_folder, pts_filename);

    mask = volume_data > 0;
    if voxel_stride > 1
        sample_mask = false(size(mask));
        sample_mask(1:voxel_stride:end, 1:voxel_stride:end, 1:voxel_stride:end) = true;
        mask = mask & sample_mask;
    end

    voxel_idx = find(mask);
    if isempty(voxel_idx)
        error('sn2zef:NoAtlasPoints', 'Volume contains no sampled non-zero voxels.');
    end

    [i1, i2, i3] = ind2sub(size(volume_data), voxel_idx);
    pts_hom = [i2(:), i1(:), i3(:), ones(numel(voxel_idx), 1)];
    pts_ras = (voxel_to_ras * pts_hom.').';
    pts = pts_ras(:, 1:3);

    if ~isempty(affine_matrix)
        pts_affine = (affine_matrix * [pts, ones(size(pts, 1), 1)].').';
        pts = pts_affine(:, 1:3);
    end

    pts_matrix = [voxel_idx(:) - 1, pts];
    dlmwrite(pts_path, pts_matrix, 'delimiter', ' ', 'precision', 6);

end % function
