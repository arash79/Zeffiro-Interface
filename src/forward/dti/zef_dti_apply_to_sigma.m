%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_APPLY_TO_SIGMA
%
%MAIN INTEGRATION FUNCTION: Applies FreeSurfer DTI-derived anisotropic conductivity
%to zef.sigma. This function uses FreeSurfer's dt_recon outputs (fa.nii.gz) and
%register.dat transformation file.
%
%WHY THIS IS NEEDED:
%This function:
%1. Converts FreeSurfer FA → conductivity (using zef_freesurfer_fa_to_conductivity)
%2. Interpolates conductivity to mesh using KD-Tree algorithm (in mesh space)
%3. Updates zef.sigma with anisotropic values
%4. Handles compartment-specific application
%5. Triggers necessary updates
%
%FreeSurfer Integration:
%  - Uses fa.nii.gz from dt_recon output (no need to compute DTI tensor)
%  - Uses register.dat transformation: transforms FA data TO mesh space (direct transformation)
%  - Interpolation happens directly in mesh space (no coordinate transformation needed)
%
%Inputs:
%   zef - Zeffiro struct (optional, reads from base workspace if not provided)
%
%Outputs:
%   zef - Updated Zeffiro struct with anisotropic conductivity in zef.sigma
%
%Process:
%   1. Validate prerequisites (FreeSurfer FA loaded, mesh exists, register.dat available)
%   2. Convert FA → conductivity tensor
%   3. Compute tetrahedron centroids
%   4. Interpolate conductivity to mesh using KD-Tree (in mesh space)
%   5. Apply to selected compartments
%   6. Update zef.sigma_anisotropy
%   7. Clear sigma_bypass to force recomputation

function zef = zef_dti_apply_to_sigma(zef, varargin)
% --- Zeffiro documentation header ---
% zef_dti_apply_to_sigma — Zef dti apply to sigma.
%
% Purpose:
%   Zef dti apply to sigma.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   zef
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.domain_labels (read, write)
%   zef.dti_anisotropy_threshold (read)
%   zef.dti_applied (read, write)
%   zef.dti_applied_time (read, write)
%   zef.dti_apply_to_compartments (read)
%   zef.dti_conductivity_metadata (read, write)
%   zef.dti_conductivity_model (read)
%   zef.dti_conductivity_scale (read)
%   zef.dti_extra_conductivity (read)
%   zef.dti_interpolation_mode (read)
%   zef.dti_interpolation_radius (read)
%   zef.dti_intra_conductivity (read)
%   zef.dti_mean_diffusivity (read)
%   zef.dti_volume_fraction (read)
%   … (8 more)
%
% Calls (project):
%   zef_create_fem_mesh
%   zef_dti_apply_to_sigma
%   zef_dti_print_anisotropy_report
%   zef_dti_tensor_interpolate_mesh_space
%   zef_freesurfer_fa_to_conductivity
%   zef_freesurfer_load_fa
%   zef_freesurfer_read_register_dat
%   zef_sigma
%   zef_waitbar
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%   - waitbar progress UI
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dti_apply_to_sigma(zef, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
% Transforms mesh centroids to FA voxel space via the inverse of
% (T_register * T_nifti), then uses griddedInterpolant for O(M) lookup.
% The waitbar handle is passed through for live progress updates.

if ~isempty(h_waitbar) && isvalid(h_waitbar)
    try zef_waitbar(0.20, 1, h_waitbar, 'Interpolating conductivity to FEM mesh...'); drawnow; catch, end
end

try
    sigma_mesh = zef_dti_tensor_interpolate_mesh_space(...
        tetra_centroids, ...
        conductivity_tensor, ...
        zef.freesurfer_fa_info, ...
        zef.freesurfer_register_transform, ...
        scale_value, ...
        roi_radius, ...
        interp_mode, ...
        h_waitbar);
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
        % Build mapping from compartment tag index to domain label index
        % This follows the same logic as zef_find_active_compartment_ind
        aux_compartment_ind = zeros(length(zef.compartment_tags), 1);
        i = 0;
        for k = 1:length(zef.compartment_tags)
            % Check if compartment is active (on)
            tag_name = zef.compartment_tags{k};
            if isfield(zef, [tag_name '_on'])
                on_val = zef.([tag_name '_on']);
                if on_val
                    i = i + 1;
                    aux_compartment_ind(k) = i;  % Maps tag index k to domain label index i
                end
            end
        end
        
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
% STEP 7: UPDATE ZEF.SIGMA_ANISOTROPY
% ========================================================================
% WHY: Store anisotropic conductivity tensor in zef.sigma_anisotropy
% zef_sigma() will concatenate this with isotropic values to create
% the proper [M×8] format: [johtavuus(:) johtavuus_aux(:) sigma_anisotropy]
% Lead field functions then use columns 3-8 for anisotropic computation

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

% For isotropic points (zeros), set first 3 elements to compartment conductivity
% so sigma_anisotropy = [σ, σ, σ, 0, 0, 0] per tetrahedron
iso_mask = all(zef.sigma_anisotropy == 0, 2);
if any(iso_mask)
    sigma_per_tetra = scale_value * ones(M, 1);
    if isfield(zef, 'domain_labels') && numel(zef.domain_labels) >= M && ...
       isfield(zef, 'compartment_tags') && ~isempty(zef.compartment_tags)
        dl = zef.domain_labels(1:M);
        for k = 1:length(zef.compartment_tags)
            tag_name = zef.compartment_tags{k};
            sigma_var = [tag_name '_sigma'];
            if isfield(zef, sigma_var)
                I = (dl == k);
                sigma_per_tetra(I) = zef.(sigma_var);
            end
        end
    end
    zef.sigma_anisotropy(iso_mask, 1) = sigma_per_tetra(iso_mask);
    zef.sigma_anisotropy(iso_mask, 2) = sigma_per_tetra(iso_mask);
    zef.sigma_anisotropy(iso_mask, 3) = sigma_per_tetra(iso_mask);
end

% ========================================================================
% STEP 8: CLEANUP AND FLAGS
% ========================================================================
% WHY: Ensure system knows to recompute lead fields with new conductivity

% Mark as applied
zef.dti_applied = true;
zef.dti_applied_time = now;  % Timestamp

% Clear sigma_bypass to force recomputation
% This ensures zef_sigma() will process and use zef.sigma_anisotropy
% zef_sigma() will create [M×8] format: [iso(:) aux(:) anisotropy(:)]
% Lead field functions use columns 3-8 for anisotropic computation
zef.sigma_bypass = false;

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
