function zef = zef_nii_conductivity_to_sigma(nii_file, varargin)
%ZEF_NII_CONDUCTIVITY_TO_SIGMA  Sample a 3-D NIfTI conductivity volume onto zef.sigma.
%
%   Zeffiro Interface.
%   Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Bypasses FA→tensor conversion: each tetra centroid is mapped through the
%   NIfTI affine (optional FreeSurfer tkRAS) and nearest/trilinear sampled.
%   Writes diagonal anisotropic columns [σ σ σ 0 0 0] into sigma(:,3:8) for
%   the selected compartments. Requires zef.nodes and zef.tetra.
%
%   zef = zef_nii_conductivity_to_sigma(nii_file, 'zef', zef, ...
%       'interp_mode', 'nearest', 'fallback_val', 0, ...
%       'apply_to_compartments', {}, 'freesurfer_coords', true)
%
%   If 'zef' is omitted, reads/writes the base workspace.
%
%   See also zef_dti_apply_to_sigma, zef_visualize_nii_slices.




arguments
    nii_file (1,:) char
end

arguments (Repeating)
    varargin
end

% -------------------------------------------------------------------------
% Parse optional name-value arguments
% -------------------------------------------------------------------------
p = inputParser;
addParameter(p, 'zef',                    struct(),  @isstruct);
addParameter(p, 'interp_mode',            'nearest', @ischar);
addParameter(p, 'fallback_val',           0,         @isnumeric);
addParameter(p, 'apply_to_compartments',  {},        @iscell);
addParameter(p, 'freesurfer_coords',      true,      @(x) islogical(x) || x==0 || x==1);
parse(p, varargin{:});

interp_mode           = p.Results.interp_mode;
fallback_val          = double(p.Results.fallback_val);
apply_to_compartments = p.Results.apply_to_compartments;
use_fs_coords         = logical(p.Results.freesurfer_coords);

% Get zef from base workspace if the caller did not supply it
zef = p.Results.zef;
if isempty(fieldnames(zef))
    zef = evalin('base', 'zef');
end

% -------------------------------------------------------------------------
% Validate inputs
% -------------------------------------------------------------------------
if ~isfile(nii_file)
    error('zef_nii_conductivity_to_sigma:fileNotFound', ...
        'NIfTI file not found: %s', nii_file);
end

if ~isfield(zef, 'nodes') || ~isfield(zef, 'tetra') || isempty(zef.tetra)
    error('zef_nii_conductivity_to_sigma:noMesh', ...
        ['FEM mesh not available. Create the mesh first.\n' ...
         'zef.nodes and zef.tetra must be populated.']);
end

% -------------------------------------------------------------------------
% Step 1: Load NIfTI volume
% -------------------------------------------------------------------------
fprintf('Loading NIfTI file: %s\n', nii_file);
nii_info = niftiinfo(nii_file);
nii_vol  = double(niftiread(nii_info));

if ndims(nii_vol) ~= 3
    error('zef_nii_conductivity_to_sigma:badDims', ...
        'Expected a 3-D NIfTI volume; got %d dimensions.', ndims(nii_vol));
end

[nx, ny, nz] = size(nii_vol);
fprintf('  Volume size: [%d × %d × %d]\n', nx, ny, nz);

% -------------------------------------------------------------------------
% Step 2: Extract voxel→world affine from NIfTI header
%
% MATLAB's niftiinfo stores the transform as an affine3d object whose T
% property follows the row-vector convention:
%   [x_world, y_world, z_world, 1] = [i_vox, j_vox, k_vox, 1] * T
% Voxel indices are 1-based (MATLAB convention).
% -------------------------------------------------------------------------
if isfield(nii_info, 'Transform')
    if isa(nii_info.Transform, 'affine3d')
        T_vox2world = nii_info.Transform.T;  % 4×4, row-vector convention
    elseif isstruct(nii_info.Transform) && isfield(nii_info.Transform, 'T')
        T_vox2world = nii_info.Transform.T;
    else
        error('zef_nii_conductivity_to_sigma:noTransform', ...
            'Cannot extract affine transform from niftiinfo.Transform.');
    end
elseif isfield(nii_info, 'Qfactor') || isfield(nii_info, 'ImageSize')
    warning('zef_nii_conductivity_to_sigma:fallbackTransform', ...
        ['NIfTI Transform field missing; constructing identity-like transform ' ...
         'from PixelDimensions only. Verify that voxel and mesh coordinates match.']);
    voxsz = nii_info.PixelDimensions(1:3);
    T_vox2world = diag([voxsz, 1]);
else
    error('zef_nii_conductivity_to_sigma:noTransform', ...
        'Cannot determine spatial transform from NIfTI header.');
end

T_vox2world = double(T_vox2world);

% -------------------------------------------------------------------------
% Step 2b: FreeSurfer coordinate correction — scanner RAS → tkRAS
%
% The NIfTI sform encodes scanner RAS. Zeffiro mesh nodes are in tkRAS
% (FreeSurfer surface RAS) = scanner RAS − c_ras, where c_ras is the
% scanner-RAS coordinate of the centre voxel (floor(N/2)+1 in 1-based).
% Subtracting c_ras from the affine translation makes the inverse transform
% correctly map tkRAS centroid positions to voxel indices.
% -------------------------------------------------------------------------
if use_fs_coords
    ctr_vox = [floor(nx/2)+1, floor(ny/2)+1, floor(nz/2)+1, 1];
    c_ras = ctr_vox * T_vox2world;          % scanner-RAS of centre voxel
    T_vox2world(4, 1:3) = T_vox2world(4, 1:3) - c_ras(1:3);
    fprintf('  FreeSurfer c_ras     : [%.4f  %.4f  %.4f] mm (subtracted)\n', ...
        c_ras(1), c_ras(2), c_ras(3));
    fprintf('  Coordinates now in   : tkRAS (FreeSurfer surface / mesh space)\n');
else
    fprintf('  freesurfer_coords=false: using raw scanner RAS from NIfTI sform.\n');
end

T_world2vox = inv(T_vox2world);  %#ok<MINV>

% -------------------------------------------------------------------------
% Step 3: Compute tetrahedron centroids in mesh (= world) space
% -------------------------------------------------------------------------
nodes = double(zef.nodes);
tetra = zef.tetra;
M     = size(tetra, 1);

fprintf('  Number of tetrahedra: %d\n', M);

centroids = (nodes(tetra(:,1), :) + nodes(tetra(:,2), :) + ...
             nodes(tetra(:,3), :) + nodes(tetra(:,4), :)) / 4;  % [M×3]

% -------------------------------------------------------------------------
% Step 4: Transform centroids (tkRAS) to NIfTI voxel coordinates
%
% Row-vector convention:
%   [vx, vy, vz, 1] = [wx, wy, wz, 1] * T_world2vox
% -------------------------------------------------------------------------
pts_world = [centroids, ones(M, 1)];       % [M×4]
pts_vox   = pts_world * T_world2vox;       % [M×4]

vx = pts_vox(:, 1);
vy = pts_vox(:, 2);
vz = pts_vox(:, 3);

% -------------------------------------------------------------------------
% Step 5: Interpolate conductivity at each centroid
% -------------------------------------------------------------------------
fprintf('  Interpolating conductivity (mode: %s)...\n', interp_mode);

out_of_bounds = (vx < 1) | (vx > nx) | ...
                (vy < 1) | (vy > ny) | ...
                (vz < 1) | (vz > nz);
n_oob = sum(out_of_bounds);
if n_oob > 0
    fprintf('  Warning: %d / %d centroids fall outside the NIfTI FOV and will use fallback_val = %g.\n', ...
        n_oob, M, fallback_val);
end

sigma_per_tetra = fallback_val * ones(M, 1);

switch lower(interp_mode)

    case 'nearest'
        % Round to nearest voxel, clamp to valid range
        ix = max(1, min(nx, round(vx)));
        iy = max(1, min(ny, round(vy)));
        iz = max(1, min(nz, round(vz)));
        lin_idx = sub2ind([nx, ny, nz], ix, iy, iz);
        in_bounds = ~out_of_bounds;
        sigma_per_tetra(in_bounds) = nii_vol(lin_idx(in_bounds));

    case 'linear'
        % Trilinear interpolation via griddedInterpolant
        F = griddedInterpolant({1:nx, 1:ny, 1:nz}, nii_vol, 'linear', 'nearest');
        % Clamp query coords before interpolation (extrapolation uses 'nearest')
        vx_c = max(1, min(double(nx), double(vx)));
        vy_c = max(1, min(double(ny), double(vy)));
        vz_c = max(1, min(double(nz), double(vz)));
        sigma_per_tetra = F(vx_c, vy_c, vz_c);
        sigma_per_tetra(out_of_bounds) = fallback_val;

    otherwise
        error('zef_nii_conductivity_to_sigma:badMode', ...
            'Unknown interp_mode "%s". Use ''nearest'' or ''linear''.', interp_mode);
end

% -------------------------------------------------------------------------
% Step 6: Determine which tetrahedra to update
% -------------------------------------------------------------------------
update_mask = true(M, 1);

if ~isempty(apply_to_compartments)
    if isfield(zef, 'domain_labels') && ~isempty(zef.domain_labels) && ...
       isfield(zef, 'compartment_tags') && ~isempty(zef.compartment_tags)

        % Build active compartment index map (same as mesh postprocess)
        aux_compartment_ind = zeros(length(zef.compartment_tags), 1);
        i_active = 0;
        for k = 1:length(zef.compartment_tags)
            tag_name = zef.compartment_tags{k};
            if isfield(zef, [tag_name '_on']) && zef.([tag_name '_on'])
                i_active = i_active + 1;
                aux_compartment_ind(k) = i_active;
            end
        end

        update_mask = false(M, 1);
        for ci = 1:length(apply_to_compartments)
            tag = apply_to_compartments{ci};
            tag_idx = find(strcmp(zef.compartment_tags, tag));
            if isempty(tag_idx)
                warning('Compartment tag "%s" not found. Skipping.', tag);
                continue;
            end
            dom_idx = aux_compartment_ind(tag_idx);
            if dom_idx == 0
                warning('Compartment "%s" is inactive. Skipping.', tag);
                continue;
            end
            update_mask = update_mask | (zef.domain_labels(1:M) == dom_idx);
        end

        if ~any(update_mask)
            warning('No tetrahedra matched the requested compartments. Applying to all.');
            update_mask = true(M, 1);
        end
    else
        warning(['apply_to_compartments specified but domain_labels / compartment_tags ' ...
                 'not available. Applying to all tetrahedra.']);
    end
end

% -------------------------------------------------------------------------
% Step 7: Write isotropic tensors to zef.sigma_anisotropy
%
% Format used by the anisotropic lead-field solvers (zef.sigma(:,3:8)):
%   [sigma11, sigma22, sigma33, sigma12, sigma13, sigma23]
% For isotropic conductivity sigma:
%   [sigma, sigma, sigma, 0, 0, 0]
% -------------------------------------------------------------------------
if ~isfield(zef, 'sigma_anisotropy') || isempty(zef.sigma_anisotropy) || ...
        size(zef.sigma_anisotropy, 1) ~= M
    zef.sigma_anisotropy = zeros(M, 6);
end

% Restrict writes to tetrahedra that were successfully mapped to an
% in-bounds NIfTI voxel.  Writing s = 0 (fallback) from out-of-FOV
% tetrahedra to zef.sigma(:,3:5) would zero σ11/σ22/σ33 and make the
% FEM stiffness matrix singular → all-NaN lead field.
%
% NOTE: zef_lead_field_matrix uses zef.sigma(:,3:8) for anisotropic
% lead_field_type 6–10. zef.sigma must already hold valid conductivity
% for every tetrahedron before the lead field is computed. Out-of-FOV
% tetrahedra retain the parametric compartment conductivity stored in
% zef.sigma when the mesh was post-processed.
% Only write tetrahedra that (a) are in-bounds AND (b) have a positive
% NIfTI conductivity.  An in-bounds voxel whose value is 0 (e.g. a
% background-masked region of the NIfTI) would zero the diagonal of the
% conductivity tensor and make the FEM stiffness matrix singular.
in_bounds_update = update_mask & ~out_of_bounds & (sigma_per_tetra > 0);
s_in = sigma_per_tetra(in_bounds_update);

if isfield(zef, 'sigma') && ~isempty(zef.sigma) && ...
        size(zef.sigma, 1) == M && size(zef.sigma, 2) >= 5
    zef.sigma(in_bounds_update, 1) = s_in;
    zef.sigma(in_bounds_update, 3) = s_in;
    zef.sigma(in_bounds_update, 4) = s_in;
    zef.sigma(in_bounds_update, 5) = s_in;
    % Zero off-diagonal terms (σ12, σ13, σ23) for tetra being assigned an
    % isotropic NIfTI conductivity.  If the project was previously run with
    % DTI-based conductivities, columns 6-8 may hold non-zero off-diagonal
    % values.  A mixed tensor [σ_NIfTI σ_NIfTI σ_NIfTI | σ12_DTI σ13_DTI σ23_DTI]
    % can violate positive-definiteness → non-PD stiffness matrix → PCG
    % diverges → T = [] → dimension error in the lead-field assembly.
    if size(zef.sigma, 2) >= 8
        zef.sigma(in_bounds_update, 6) = 0;
        zef.sigma(in_bounds_update, 7) = 0;
        zef.sigma(in_bounds_update, 8) = 0;
    end
end

% Only update sigma_anisotropy for in-bounds, positive-conductivity tetra.
% Out-of-FOV rows stay all-zeros; those tetra keep existing zef.sigma.
zef.sigma_anisotropy(in_bounds_update, 1) = s_in;
zef.sigma_anisotropy(in_bounds_update, 2) = s_in;
zef.sigma_anisotropy(in_bounds_update, 3) = s_in;
zef.sigma_anisotropy(in_bounds_update, 4) = 0;
zef.sigma_anisotropy(in_bounds_update, 5) = 0;
zef.sigma_anisotropy(in_bounds_update, 6) = 0;

% -------------------------------------------------------------------------
% Step 8: Summary report
% -------------------------------------------------------------------------
n_updated   = sum(in_bounds_update);
n_skipped   = sum(out_of_bounds & update_mask);
if n_updated > 0
    s_report = sigma_per_tetra(in_bounds_update);
    s_min = min(s_report);
    s_max = max(s_report);
    s_mean = mean(s_report);
else
    s_min = NaN; s_max = NaN; s_mean = NaN;
end
fprintf('\n--- NIfTI conductivity assignment complete ---\n');
fprintf('  Tetrahedra updated   : %d / %d\n', n_updated, M);
fprintf('  Conductivity range   : [%.4g, %.4g] S/m\n', s_min, s_max);
fprintf('  Conductivity mean    : %.4g S/m\n', s_mean);
fprintf('  Out-of-FOV elements  : %d (skipped; existing zef.sigma preserved)\n', n_skipped);
fprintf('  zef.sigma_anisotropy : updated [%d × 6]\n', M);
fprintf('----------------------------------------------\n');

% -------------------------------------------------------------------------
% Step 9: Assign to base workspace if called without output argument
% -------------------------------------------------------------------------
if nargout == 0
    assignin('base', 'zef', zef);
    clear zef;
end

end
