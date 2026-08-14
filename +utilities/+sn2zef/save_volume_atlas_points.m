function pts_filename = save_volume_atlas_points(volume_data, voxel_to_ras, affine_matrix, out_folder, voxel_stride)
%SAVE_VOLUME_ATLAS_POINTS  Subsampled labelled voxels → RAS sn_atlas_points.dat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Positive voxels of volume_data, strided by voxel_stride (default 4) on
%   each axis. Voxel ijk (MATLAB i1,i2,i3) mapped as [i2 i1 i3 1] through
%   4×4 voxel_to_ras, then optional affine_matrix (empty or 4×4). Rows:
%   [linear_index_0based, x, y, z]. Called from export_segmentation_meshes
%   when exporting from a volume atlas rather than tets.
%
%   pts_filename = save_volume_atlas_points(volume, voxel_to_ras, affine, out_folder)
%   pts_filename = save_volume_atlas_points(..., voxel_stride)

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

    % Same (col, row, slice) reorder as STL vertices: MATLAB dim2, dim1, dim3.
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
