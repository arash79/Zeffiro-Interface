function tensor_array = zef_dti_tensor_interpolate_mesh_space( ...
        mesh_centroids, dti_tensor, fa_nifti_info, register_transform, ...
        scale_value, roi_radius, mode, h_waitbar)

%ZEF_DTI_TENSOR_INTERPOLATE_MESH_SPACE  Interpolate DTI conductivity to mesh centroids.
%
%   Zeffiro Interface.
%   Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Maps mesh tetra centroids (mm) into FA voxel space via inv(T_register *
%   T_nifti), then samples dti_tensor [nx×ny×nz×6] on the regular grid.
%   Modes: 'nearest' (voxel rounding) or 'radius_average'/'kdtree' (trilinear
%   via griddedInterpolant). Enforces positive-definite symmetric tensors with
%   Sylvester check; out-of-range voxels get scale_value isotropic fallback.
%
%   tensor_array = zef_dti_tensor_interpolate_mesh_space( ...
%       mesh_centroids, dti_tensor, fa_nifti_info, register_transform, ...
%       scale_value, roi_radius, mode, h_waitbar)
%
%   Input
%     mesh_centroids     - [M × 3] tetra centroids, millimetres (mesh / tkRAS)
%     dti_tensor         - [nx ny nz 6] single/double, voxel FA space
%     fa_nifti_info      - niftiinfo struct (Transform.T, row-vector affine)
%     register_transform - 4×4 FreeSurfer register.dat (FA voxel → mesh)
%     scale_value        - isotropic fallback σ for out-of-FOV tetra
%     roi_radius         - unused in nearest/trilinear paths (kept for API)
%     mode               - 'nearest' or 'radius_average'/'kdtree' (trilinear)
%     h_waitbar          - optional waitbar handle
%
%   Output tensor_array is [M × 6], SPD-enforced (Sylvester), millimetres
%   of conductivity per tetra centroid.
%
%   See also zef_dti_apply_to_sigma, zef_freesurfer_fa_to_conductivity.


if nargin < 8, h_waitbar = []; end

% ---- Dimensions ----------------------------------------------------------
[nx, ny, nz, ~] = size(dti_tensor);
M = size(mesh_centroids, 1);

% ---- Extract NIfTI voxel→tkRAS transformation ---------------------------
T_nifti = [];
if isfield(fa_nifti_info, 'Transform')
    if isfield(fa_nifti_info.Transform, 'T')
        T_nifti = fa_nifti_info.Transform.T;
    elseif isfield(fa_nifti_info.Transform, 'Matrix')
        T_nifti = fa_nifti_info.Transform.Matrix;
    elseif isa(fa_nifti_info.Transform, 'affine3d')
        T_nifti = fa_nifti_info.Transform.T;
    end
end
if isempty(T_nifti)
    error('NIfTI transformation matrix not available.');
end

% ---- Compute inverse transform: mesh_tkRAS → FA voxel -------------------
T_combined = register_transform * T_nifti;      % FA_voxel → mesh
T_inv      = inv(T_combined);                    % mesh → FA_voxel  %#ok<MINV>

% ---- Transform all mesh centroids to FA voxel coordinates (vectorized) ---
%  [M×4] = [M×4] * [4×4]'  (row-vector convention: p_vox = p_mesh * T_inv')
pts_mesh = [mesh_centroids, ones(M, 1)];         % [M×4]
pts_vox  = pts_mesh * T_inv';                     % [M×4]
vx = pts_vox(:, 1);
vy = pts_vox(:, 2);
vz = pts_vox(:, 3);

% ---- Flatten tensor to [N×6] for fast linear-index lookup ----------------
tensor_flat = reshape(dti_tensor, [], 6);         % [N×6], single

% ---- Choose interpolation mode -------------------------------------------
wb_active = ~isempty(h_waitbar) && isvalid(h_waitbar);

if strcmp(mode, 'nearest')
    % ------------------------------------------------------------------
    %  Nearest-neighbor: round to nearest voxel, clamp, linear-index
    % ------------------------------------------------------------------
    ix = max(1, min(nx, round(vx)));
    iy = max(1, min(ny, round(vy)));
    iz = max(1, min(nz, round(vz)));
    lin_idx = sub2ind([nx, ny, nz], ix, iy, iz);  % [M×1]
    tensor_array = tensor_flat(lin_idx, :);        % [M×6]

    if wb_active
        try zef_waitbar(0.65, 1, h_waitbar, 'Nearest-neighbor lookup complete.'); drawnow; catch, end
    end

elseif strcmp(mode, 'radius_average') || strcmp(mode, 'kdtree')
    % ------------------------------------------------------------------
    %  Trilinear interpolation via griddedInterpolant (standard in
    %  neuroimaging; uses the 8 enclosing voxels with distance weights).
    % ------------------------------------------------------------------
    %  griddedInterpolant expects double grid vectors and query points.
    gx = double(1:nx);
    gy = double(1:ny);
    gz = double(1:nz);
    vx_d = double(vx);
    vy_d = double(vy);
    vz_d = double(vz);

    tensor_array = zeros(M, 6, 'single');

    for comp = 1:6
        vol = double(dti_tensor(:,:,:,comp));      % [nx×ny×nz]
        F = griddedInterpolant({gx, gy, gz}, vol, 'linear', 'nearest');
        tensor_array(:, comp) = single(F(vx_d, vy_d, vz_d));

        if wb_active && mod(comp, 2) == 0
            frac = 0.40 + 0.25 * (comp / 6);      % 0.40 → 0.65
            try zef_waitbar(frac, 1, h_waitbar, ...
                sprintf('Interpolating tensor component %d/6...', comp)); drawnow; catch, end
        end
    end
else
    error('Unknown interpolation mode: "%s". Use "nearest" or "radius_average".', mode);
end

% ---- Handle out-of-bounds / zero tensors ---------------------------------
zero_mask = sum(abs(tensor_array), 2) == 0;
if any(zero_mask)
    tensor_array(zero_mask, 1) = scale_value;
    tensor_array(zero_mask, 2) = scale_value;
    tensor_array(zero_mask, 3) = scale_value;
end

% ---- Vectorized positive-definiteness enforcement (Sylvester criterion) --
%  A 3×3 symmetric matrix [a b c; b d e; c e f] is positive definite iff:
%    (1) a > 0
%    (2) a*d - b² > 0
%    (3) det = a*(d*f - e²) - b*(b*f - c*e) + c*(b*e - c*d) > 0
if wb_active
    try zef_waitbar(0.70, 1, h_waitbar, 'Enforcing positive-definite tensors...'); drawnow; catch, end
end

a = double(tensor_array(:,1));  % s11
d = double(tensor_array(:,2));  % s22
f = double(tensor_array(:,3));  % s33
b = double(tensor_array(:,4));  % s12
c = double(tensor_array(:,5));  % s13
e = double(tensor_array(:,6));  % s23

sigma_min = max(1e-10, abs(scale_value) * 1e-4);

minor1 = a;
minor2 = a .* d - b.^2;
det3   = a .* (d .* f - e.^2) - b .* (b .* f - c .* e) + c .* (b .* e - c .* d);

bad = (minor1 <= sigma_min) | (minor2 <= sigma_min) | (det3 <= sigma_min);
n_bad = sum(bad);

if n_bad > 0
    % For the (typically few) non-PD tensors, clamp eigenvalues.
    % Use MATLAB's eig only on the failing subset.
    bad_idx = find(bad);
    for k = 1:n_bad
        i = bad_idx(k);
        S = [a(i) b(i) c(i); b(i) d(i) e(i); c(i) e(i) f(i)];
        [V, D] = eig(S, 'vector');
        D = max(D, sigma_min);
        S = V * diag(D) * V';
        tensor_array(i,:) = single([S(1,1) S(2,2) S(3,3) S(1,2) S(1,3) S(2,3)]);
    end
end

if wb_active
    try zef_waitbar(0.75, 1, h_waitbar, ...
        sprintf('Interpolation complete. %d/%d tensors were repaired.', n_bad, M)); drawnow; catch, end
end

end
