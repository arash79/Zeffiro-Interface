function zef = zef_dti_apply_to_sigma(zef, varargin)
%ZEF_DTI_APPLY_TO_SIGMA  Apply FreeSurfer DTI conductivity to zef.sigma.
%
%   Zeffiro Interface.
%   Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   GUI: DTI Conductivity Tool → Apply (zef_dti_conductivity_apply_button_callback).
%   Requires zef.freesurfer_fa_data, zef.freesurfer_register_transform, and a
%   FEM mesh. Writes zef.sigma_anisotropy [n_tet × 6] as
%   [σ11 σ22 σ33 σ12 σ13 σ23] and copies that into zef.sigma(:,3:8)
%   for lead_field_type 6–10.
%
%   Name-value / zef fields
%     dti_conductivity_model     - 1 volume-fraction (default), 2 Tuch effective
%                                  medium, 3 direct scaling
%     dti_volume_fraction        - default 0.7
%     dti_extra_conductivity     - default 1.0 S/m
%     dti_intra_conductivity     - default 0.6 S/m
%     dti_interpolation_mode     - 'radius_average' (default) or 'nearest'
%     dti_interpolation_radius   - mm, default 2
%     dti_conductivity_scale     - isotropic fallback, default 0.33
%     dti_mean_diffusivity       - μm²/ms for model 2, default 0.7
%     dti_anisotropy_threshold   - min FA, default 0.2
%     apply_to_compartments      - cell of compartment tags, or all tetra
%
%   zef = zef_dti_apply_to_sigma(zef, varargin)
%
%   See also zef_dti_get_mesh2voxel, zef_nii_conductivity_to_sigma.




arguments
    zef (1,1) struct = struct()
end

arguments (Repeating)
    varargin
end

% Get zef from base workspace if not provided
if isempty(fieldnames(zef))
    zef = evalin('base','zef');
end

% ========================================================================
% STEP 1: VALIDATION - Ensure prerequisites are met
% ========================================================================
% WHY: Fail early with clear error messages if data is missing

% Check for FreeSurfer FA data
if ~isfield(zef,'freesurfer_fa_data') || isempty(zef.freesurfer_fa_data)
    error(['FreeSurfer FA data not loaded. Please import FA data first using:' newline ...
           '  [zef.freesurfer_fa_data, zef.freesurfer_fa_info] = zef_freesurfer_load_fa(fa_file);']);
end

% Check for register.dat transformation (required for FA voxel → mesh space)
% The interpolation step always uses freesurfer_register_transform; load path sets it from register.dat.
if ~isfield(zef,'freesurfer_register_transform') || isempty(zef.freesurfer_register_transform)
    error(['FreeSurfer register.dat transformation not loaded. Please load register.dat:' newline ...
           '  In the DTI Conductivity Tool: select register.dat and click Load.' newline ...
           '  Or: zef.freesurfer_register_transform = zef_freesurfer_read_register_dat(register_dat_file);']);
end

if ~isfield(zef,'nodes') || ~isfield(zef,'tetra') || isempty(zef.tetra)
    error(['FEM mesh not available. Please create mesh first:' newline ...
           '  zef = zef_create_fem_mesh(zef);']);
end

% Get FA data dimensions
fa_dims = size(zef.freesurfer_fa_data);
nx = fa_dims(1);
ny = fa_dims(2);
nz = fa_dims(3);

% ========================================================================
% STEP 2: GET PARAMETERS - Read conversion and interpolation settings
% ========================================================================
% WHY: Allow user customization while providing sensible defaults

% Conversion model
model_type = 1;  % Default: Volume fraction model
if isfield(zef,'dti_conductivity_model')
    model_type = zef.dti_conductivity_model;
end

% Model parameters
volume_fraction = 0.7;
if isfield(zef,'dti_volume_fraction')
    volume_fraction = zef.dti_volume_fraction;
end

extra_conductivity = 1.0;
if isfield(zef,'dti_extra_conductivity')
    extra_conductivity = zef.dti_extra_conductivity;
end

intra_conductivity = 0.6;
if isfield(zef,'dti_intra_conductivity')
    intra_conductivity = zef.dti_intra_conductivity;
end

% Interpolation parameters
interp_mode = 'radius_average';
if isfield(zef,'dti_interpolation_mode')
    interp_mode = zef.dti_interpolation_mode;
end

roi_radius = 2.0;  % mm
if isfield(zef,'dti_interpolation_radius')
    roi_radius = zef.dti_interpolation_radius;
end

scale_value = 0.33;  % Default isotropic fallback
if isfield(zef,'dti_conductivity_scale')
    scale_value = zef.dti_conductivity_scale;
end

% Mean diffusivity (μm²/ms) for Effective Medium model (model 2); Tuch et al. use ~0.7 for WM
mean_diffusivity = 0.7;
if isfield(zef,'dti_mean_diffusivity')
    mean_diffusivity = zef.dti_mean_diffusivity;
end

% Anisotropy threshold (minimum FA to apply anisotropy)
anisotropy_threshold = 0.2;
if isfield(zef,'dti_anisotropy_threshold')
    anisotropy_threshold = zef.dti_anisotropy_threshold;
end

% Compartment selection
apply_to_compartments = {};
if isfield(zef,'dti_apply_to_compartments') && ~isempty(zef.dti_apply_to_compartments)
    apply_to_compartments = zef.dti_apply_to_compartments;
    if ischar(apply_to_compartments)
        apply_to_compartments = {apply_to_compartments};
    end
end

% ========================================================================
% STEP 3: CONVERT FREE SURFER FA → CONDUCTIVITY TENSOR
% ========================================================================
% WHY: This is the biophysical conversion step
% Uses FreeSurfer FA data directly (no DTI tensor computation needed)

% Create waitbar (respects Zeffiro menu ZefUseWaitbar when present).
% The handle is passed through to sub-functions for live progress.
h_waitbar = [];
try
    h_waitbar = zef_waitbar(0, 1, 'DTI conductivity: starting...');
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        zef_waitbar(0.02, 1, h_waitbar, 'Converting FA to conductivity tensor...');
        drawnow;
    end
catch
    h_waitbar = [];
end

try
    % Convert FreeSurfer FA to conductivity tensor (fully vectorized)
    principal_direction = [];
    if isfield(zef,'freesurfer_v1_data') && ~isempty(zef.freesurfer_v1_data)
        principal_direction = zef.freesurfer_v1_data;
    end
    
    conductivity_tensor = zef_freesurfer_fa_to_conductivity(...
        zef.freesurfer_fa_data, ...
        model_type, ...
        'volume_fraction', volume_fraction, ...
        'extra_conductivity', extra_conductivity, ...
        'intra_conductivity', intra_conductivity, ...
        'scale_factor', scale_value, ...
        'anisotropy_threshold', anisotropy_threshold, ...
        'principal_direction', principal_direction, ...
        'mean_diffusivity', mean_diffusivity);
catch ME
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try set(h_waitbar, 'DeleteFcn', ''); delete(h_waitbar); catch, end
    end
    error('FA to conductivity conversion failed: %s', ME.message);
end

% ========================================================================
% STEP 4: COMPUTE TETRAHEDRON CENTROIDS (vectorized)
% ========================================================================

if ~isempty(h_waitbar) && isvalid(h_waitbar)
    try zef_waitbar(0.15, 1, h_waitbar, 'Computing tetrahedron centroids...'); drawnow; catch, end
end

nodes = zef.nodes;
tetra = zef.tetra;
M = size(tetra, 1);

tetra_centroids = (nodes(tetra(:,1),:) + nodes(tetra(:,2),:) + ...
                   nodes(tetra(:,3),:) + nodes(tetra(:,4),:)) / 4;

% ========================================================================
% STEP 5: INTERPOLATE CONDUCTIVITY TO MESH
% ========================================================================
% Transforms mesh centroids to FA voxel space. When FreeSurfer
% vox2ras-tkr + orig.mgz + register.dat are available, uses the same
% zef_dti_get_mesh2voxel chain as Kalman structural Q (0-based +1).
% If register.dat is present but the chain cannot be built, this errors
% rather than mixing tkRAS with scanner-space NIfTI. Without register.dat,
% interpolation may use T_nifti alone.

if ~isempty(h_waitbar) && isvalid(h_waitbar)
    try zef_waitbar(0.20, 1, h_waitbar, 'Interpolating conductivity to FEM mesh...'); drawnow; catch, end
end

T_mesh2voxel = zef_dti_resolve_mesh2voxel(zef);

try
    sigma_mesh = zef_dti_tensor_interpolate_mesh_space(...
        tetra_centroids, ...
        conductivity_tensor, ...
        zef.freesurfer_fa_info, ...
        zef.freesurfer_register_transform, ...
        scale_value, ...
        roi_radius, ...
        interp_mode, ...
        h_waitbar, ...
        T_mesh2voxel);
catch ME
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try set(h_waitbar, 'DeleteFcn', ''); delete(h_waitbar); catch, end
    end
    error('Interpolation failed: %s', ME.message);
end

% sigma_mesh is now [M×6] array with conductivity tensor for each tetrahedron

% ========================================================================
% STEP 6: DETERMINE WHICH TETRAHEDRA TO UPDATE
% ========================================================================
% WHY: User may want to apply DTI only to specific compartments
% (e.g., only white matter, not gray matter or CSF)

if ~isempty(h_waitbar) && isvalid(h_waitbar)
    try zef_waitbar(0.80, 1, h_waitbar, 'Selecting compartments...'); drawnow; catch, end
end

if ~isempty(apply_to_compartments) && isfield(zef,'domain_labels') && ~isempty(zef.domain_labels)
    % Find tetrahedra in selected compartments
    % IMPORTANT: domain_labels uses indices of ACTIVE compartments (those with _on flag),
    % not direct compartment tag indices. We need to map compartment tags to domain label indices.
    
    update_indices = [];
    
    if isfield(zef,'compartment_tags') && ~isempty(zef.compartment_tags)
        aux_compartment_ind = zef_dti_active_compartment_map(zef);

        % Now find tetrahedra for each selected compartment tag
        for tag_cell = apply_to_compartments
            tag = tag_cell{1};
            if ischar(tag)
                tag = {tag};
            end
            
            % Find compartment tag index
            tag_idx = find(strcmp(zef.compartment_tags, tag{1}));
            if ~isempty(tag_idx) && tag_idx <= length(aux_compartment_ind)
                % Map to domain label index
                domain_label_idx = aux_compartment_ind(tag_idx);
                if domain_label_idx > 0
                    % Find tetrahedra in this compartment
                    comp_tetra = find(zef.domain_labels == domain_label_idx);
                    update_indices = [update_indices; comp_tetra(:)];
                else
                    warning('Compartment "%s" is not active (turned off). Skipping.', tag{1});
                end
            else
                warning('Compartment tag "%s" not found in compartment_tags. Skipping.', tag{1});
            end
        end
        update_indices = unique(update_indices);
        
        if isempty(update_indices)
            warning('No tetrahedra found in selected compartments. Applying to all tetrahedra.');
            update_indices = 1:M;
        end
    else
        % No compartment tags → apply to all
        update_indices = 1:M;
    end
else
    % No compartment selection → apply to all tetrahedra
    update_indices = 1:M;
end

% ========================================================================
% STEP 7: UPDATE ZEF.SIGMA_ANISOTROPY AND ZEF.SIGMA(:,3:8)
% ========================================================================
% Lead-field types 6–10 read zef.sigma(:,3:8) as
% [σ11 σ22 σ33 σ12 σ13 σ23]. Keep sigma_anisotropy as the 6-column
% working copy used by the anisotropy report.

% Initialize sigma_anisotropy if it doesn't exist
if ~isfield(zef,'sigma_anisotropy') || isempty(zef.sigma_anisotropy)
    % Initialize with zeros (isotropic = no anisotropy)
    zef.sigma_anisotropy = zeros(M, 6);
end

% Ensure sigma_anisotropy has correct size
if size(zef.sigma_anisotropy, 1) ~= M
    % Resize if needed (e.g., after mesh refinement)
    if size(zef.sigma_anisotropy, 1) < M
        % Expand with zeros for new tetrahedra
        zef.sigma_anisotropy = [zef.sigma_anisotropy; zeros(M - size(zef.sigma_anisotropy, 1), 6)];
    else
        % Truncate if mesh was simplified
        zef.sigma_anisotropy = zef.sigma_anisotropy(1:M, :);
    end
end

% Apply DTI-derived anisotropic conductivity to selected tetrahedra
% Format: [σ11, σ22, σ33, σ12, σ13, σ23]
zef.sigma_anisotropy(update_indices, :) = sigma_mesh(update_indices, :);

% Isotropic fallback only on tetrahedra this Apply actually wrote.
% domain_labels stores ACTIVE-compartment indices, not tag positions.
iso_mask = false(M, 1);
iso_mask(update_indices) = all(zef.sigma_anisotropy(update_indices, :) == 0, 2);
if any(iso_mask)
    sigma_per_tetra = scale_value * ones(M, 1);
    if isfield(zef, 'domain_labels') && numel(zef.domain_labels) >= M && ...
       isfield(zef, 'compartment_tags') && ~isempty(zef.compartment_tags)
        dl = zef.domain_labels(1:M);
        aux_map = zef_dti_active_compartment_map(zef);
        for k = 1:length(zef.compartment_tags)
            tag_name = zef.compartment_tags{k};
            sigma_var = [tag_name '_sigma'];
            if isfield(zef, sigma_var) && aux_map(k) > 0
                I = (dl == aux_map(k));
                sigma_per_tetra(I) = zef.(sigma_var);
            end
        end
    end
    zef.sigma_anisotropy(iso_mask, 1) = sigma_per_tetra(iso_mask);
    zef.sigma_anisotropy(iso_mask, 2) = sigma_per_tetra(iso_mask);
    zef.sigma_anisotropy(iso_mask, 3) = sigma_per_tetra(iso_mask);
end

if isfield(zef, 'sigma') && ~isempty(zef.sigma) && size(zef.sigma, 1) == M
    if size(zef.sigma, 2) < 8
        zef.sigma = [zef.sigma, zeros(M, 8 - size(zef.sigma, 2))];
    end
    write_rows = unique([update_indices(:); find(iso_mask)]);
    zef.sigma(write_rows, 3:8) = zef.sigma_anisotropy(write_rows, :);
end

% ========================================================================
% STEP 8: CLEANUP AND FLAGS
% ========================================================================

zef.dti_applied = true;
zef.dti_applied_time = now;

% Store metadata for reference
if ~isfield(zef,'dti_conductivity_metadata')
    zef.dti_conductivity_metadata = struct;
end

zef.dti_conductivity_metadata.model_type = model_type;
zef.dti_conductivity_metadata.volume_fraction = volume_fraction;
zef.dti_conductivity_metadata.extra_conductivity = extra_conductivity;
zef.dti_conductivity_metadata.intra_conductivity = intra_conductivity;
zef.dti_conductivity_metadata.anisotropy_threshold = anisotropy_threshold;
zef.dti_conductivity_metadata.mean_diffusivity = mean_diffusivity;
zef.dti_conductivity_metadata.interpolation_mode = interp_mode;
zef.dti_conductivity_metadata.interpolation_radius = roi_radius;
zef.dti_conductivity_metadata.applied_to_compartments = apply_to_compartments;
zef.dti_conductivity_metadata.n_tetrahedra_updated = length(update_indices);
zef.dti_conductivity_metadata.source = 'FreeSurfer_dt_recon';

% ========================================================================
% STEP 9: PRINT ANISOTROPY REPORT
% ========================================================================
% WHY: Immediate verification that anisotropy was applied correctly.
% Prints a per-compartment summary table and sample eigenvalue
% decompositions to the command window.

if ~isempty(h_waitbar) && isvalid(h_waitbar)
    try zef_waitbar(0.95, 1, h_waitbar, 'Generating anisotropy report...'); drawnow; catch, end
end

try
    zef_dti_print_anisotropy_report(zef);
catch ME_report
    fprintf(2, 'Warning: Could not generate anisotropy report: %s\n', ME_report.message);
end

if ~isempty(h_waitbar) && isvalid(h_waitbar)
    try
        n_up = length(update_indices);
        zef_waitbar(1, 1, h_waitbar, ...
            sprintf('Done! Updated %d tetrahedra.', n_up));
        drawnow; pause(0.5);
        set(h_waitbar, 'DeleteFcn', ''); delete(h_waitbar);
    catch
        try
            if isvalid(h_waitbar), set(h_waitbar,'DeleteFcn',''); delete(h_waitbar); end
        catch, end
    end
end

% ========================================================================
% STEP 10: RETURN OR ASSIGN TO BASE WORKSPACE
% ========================================================================

if nargout == 0
    assignin('base','zef',zef);
    clear zef;
end

end
