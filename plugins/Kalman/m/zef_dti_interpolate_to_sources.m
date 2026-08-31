function [fa_sources, v1_sources] = zef_dti_interpolate_to_sources(zef, source_positions)
%ZEF_DTI_INTERPOLATE_TO_SOURCES  Trilinear FA and v1 from the DTI volume onto source_positions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [fa_sources, v1_sources] = zef_dti_interpolate_to_sources(zef, source_positions)
%
%   Called from zef_dti_structural_Q on the legacy Kalman plugin path only
%   (not inverse.KalmanInverter). Reads zef.freesurfer_fa_data, optional
%   zef.freesurfer_v1_data, and the mesh-to-voxel affine from
%   zef_dti_get_mesh2voxel (0-based voxels; +1 for MATLAB indexing). v1 is
%   rotated into mesh space via inv(R) of that affine, then normalized.
%
%   See also zef_dti_get_mesh2voxel, zef_dti_fa_covariance,
%   zef_dti_tractography_covariance.

arguments
    zef (1,1) struct
    source_positions (:,3) double
end

% ========================================================================
% VALIDATE INPUTS
% ========================================================================

if ~isfield(zef, 'freesurfer_fa_data') || isempty(zef.freesurfer_fa_data)
    error('zef_dti_interpolate_to_sources:noFA', ...
        ['FreeSurfer FA data not loaded. Please load fa.nii.gz first:\n' ...
         '  [zef.freesurfer_fa_data, zef.freesurfer_fa_info] = zef_freesurfer_load_fa(fa_file);']);
end

fa_data = double(zef.freesurfer_fa_data);
[nx, ny, nz] = size(fa_data);
N = size(source_positions, 1);

% ========================================================================
% COORDINATE TRANSFORMATION: mesh display → FA voxel (1-based)
% ========================================================================
% zef_dti_get_mesh2voxel returns 0-based voxel indices (FreeSurfer convention).
% MATLAB arrays are 1-based, so we add +1 after transformation.

T_mesh2voxel = zef_dti_get_mesh2voxel(zef);

pts_mesh = [source_positions, ones(N, 1)];      % [N×4] homogeneous
pts_vox_0based = (T_mesh2voxel * pts_mesh')';    % [N×4], 0-based voxel
pts_vox = pts_vox_0based(:, 1:3) + 1;            % [N×3], 1-based for MATLAB

% ========================================================================
% INTERPOLATE FA
% ========================================================================
% griddedInterpolant with grid vectors {1:nx, 1:ny, 1:nz} matches MATLAB
% array indexing. 'linear' gives trilinear interpolation; 'nearest' for
% out-of-bounds extrapolation (clamps to boundary).

gx = double(1:nx);
gy = double(1:ny);
gz = double(1:nz);

F_fa = griddedInterpolant({gx, gy, gz}, fa_data, 'linear', 'nearest');
fa_sources = F_fa(pts_vox(:,1), pts_vox(:,2), pts_vox(:,3));
fa_sources = max(0, min(1, fa_sources));  % Clamp to valid FA range

% Report coverage
n_inside = sum(pts_vox(:,1) >= 1 & pts_vox(:,1) <= nx & ...
               pts_vox(:,2) >= 1 & pts_vox(:,2) <= ny & ...
               pts_vox(:,3) >= 1 & pts_vox(:,3) <= nz);
if n_inside < N
    fprintf('  DTI interpolation: %d/%d sources inside FA volume (%.1f%%)\n', ...
        n_inside, N, 100*n_inside/N);
end

% ========================================================================
% INTERPOLATE V1 (principal eigenvector) — if available
% ========================================================================

v1_sources = [];

if isfield(zef, 'freesurfer_v1_data') && ~isempty(zef.freesurfer_v1_data)
    v1_data = double(zef.freesurfer_v1_data);

    % Validate v1 dimensions
    if ndims(v1_data) == 4 && size(v1_data, 4) == 3 && ...
       size(v1_data,1) == nx && size(v1_data,2) == ny && size(v1_data,3) == nz

        % Trilinear interpolation of each v1 component
        v1_voxel = zeros(N, 3);
        for comp = 1:3
            F_v1 = griddedInterpolant({gx, gy, gz}, ...
                v1_data(:,:,:,comp), 'linear', 'nearest');
            v1_voxel(:, comp) = F_v1(pts_vox(:,1), pts_vox(:,2), pts_vox(:,3));
        end

        % Rotate v1 from voxel-aligned frame to mesh display frame.
        % T_mesh2voxel maps: v_voxel = R * v_mesh (for directions)
        % So: v_mesh = R^{-1} * v_voxel
        R = T_mesh2voxel(1:3, 1:3);   % Rotation + scaling part
        R_inv = R \ eye(3);            % inv(R), handles non-orthogonal case

        v1_sources = (R_inv * v1_voxel')';   % [N×3] in mesh space

        % Normalize to unit vectors
        nrm = sqrt(sum(v1_sources.^2, 2));
        nrm(nrm < 1e-12) = 1;
        v1_sources = v1_sources ./ nrm;
    else
        warning('zef_dti_interpolate_to_sources:v1DimMismatch', ...
            'v1 data dimensions [%s] do not match FA volume [%d %d %d]. Skipping v1.', ...
            mat2str(size(v1_data)), nx, ny, nz);
    end
end

end
