%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_INTERPOLATE_TO_SOURCES
%
%Interpolates DTI fractional anisotropy (FA) and principal eigenvector (v1)
%from the FA voxel grid to EEG/MEG source positions. Handles the full
%coordinate transformation chain from mesh display space to FA voxel space,
%then performs trilinear interpolation using griddedInterpolant.
%
%Coordinate transformation (mesh_display → FA_voxel):
%  Uses zef_dti_get_mesh2voxel which computes the combined affine:
%    T = inv(T_dwi_vox2ras_tkr) * T_register * T_ref_vox2ras_tkr
%        * inv(T_ref_vox2ras) * T_translate(+ref_center)
%  This maps mesh display coordinates (mm) to 0-based FA voxel indices.
%  We add +1 for MATLAB's 1-based array indexing before interpolation.
%
%Direction vector transformation:
%  v1 eigenvectors are defined in FA voxel space. To express them in mesh
%  display space (needed for directional covariance weighting), we apply
%  the inverse of the rotation/scaling part of T_mesh2voxel:
%    v1_mesh = inv(R) * v1_voxel, then normalize.
%
%Inputs:
%   zef              - Zeffiro struct with DTI data loaded:
%                        .freesurfer_fa_data  [nx×ny×nz] FA volume
%                        .freesurfer_v1_data  [nx×ny×nz×3] eigenvectors (optional)
%                        Plus transformation matrices (see zef_dti_get_mesh2voxel)
%   source_positions - [N×3] Source locations in mesh display coordinates (mm)
%
%Outputs:
%   fa_sources  - [N×1] FA values at source positions, clamped to [0,1]
%   v1_sources  - [N×3] Principal eigenvectors at source positions, rotated
%                 to mesh display space and normalized. Empty [] if v1 data
%                 is not available in zef.
%
%See also: zef_dti_get_mesh2voxel, zef_dti_fa_covariance,
%          zef_dti_tractography_covariance

function [fa_sources, v1_sources] = zef_dti_interpolate_to_sources(zef, source_positions)
% --- Zeffiro documentation header ---
% zef_dti_interpolate_to_sources — Zef dti interpolate to sources.
%
% Purpose:
%   Zef dti interpolate to sources.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   source_positions
%
% Outputs:
%   fa_sources
%   v1_sources
%
% Zef fields (observed):
%   zef.freesurfer_fa_data (read)
%   zef.freesurfer_fa_info (read)
%   zef.freesurfer_v1_data (read)
%
% Calls (project):
%   zef_dti_get_mesh2voxel
%   zef_dti_interpolate_to_sources
%   zef_freesurfer_load_fa
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[fa_sources, v1_sources]] = zef_dti_interpolate_to_sources(zef, source_positions)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
