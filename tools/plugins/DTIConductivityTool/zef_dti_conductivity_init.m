function zef_dti_conductivity_init
%ZEF_DTI_CONDUCTIVITY_INIT  Default DTI fields on base zef if missing.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_dti_conductivity_init
%
%   No-op if base zef is missing or not a struct. Sets empty FA/v1/
%   register paths, dti_conductivity_model=1, volume_fraction=0.7,
%   apply_to_compartments {'g','w'}, interpolation radius 2 mm, identity
%   vox2ras, zef_dti_empty_geometry_struct. Clears FA volumes estimated
%   >1 GB. assignin('base','zef',zef).
%
%   See also zef_dti_conductivity_open, zef_dti_empty_geometry_struct.

if ~evalin('base','exist(''zef'', ''var'')')
    return;  % zef doesn't exist yet, skip initialization
end

try
    zef = evalin('base','zef');
catch
    return;  % Can't access zef, skip initialization
end

% Safety check: Ensure zef is a struct
if ~isstruct(zef)
    return;
end

% ========================================================================
% FREESURFER FILE PATHS
% ========================================================================
if not(isfield(zef,'freesurfer_fa_file'))
    zef.freesurfer_fa_file = '';
end
if not(isfield(zef,'freesurfer_v1_file'))
    zef.freesurfer_v1_file = '';
end
if not(isfield(zef,'freesurfer_register_file'))
    zef.freesurfer_register_file = '';
end

% ========================================================================
% FREESURFER DATA
% ========================================================================
% WHY: Store FreeSurfer FA data in zef for persistence across sessions
% NOTE: Large FA volumes are excluded from automatic project loading
%       to prevent memory issues. They should be loaded on demand.
if not(isfield(zef,'freesurfer_fa_data'))
    zef.freesurfer_fa_data = [];
end
if not(isfield(zef,'freesurfer_fa_info'))
    zef.freesurfer_fa_info = [];
end
if not(isfield(zef,'freesurfer_register_transform'))
    zef.freesurfer_register_transform = [];
end
if not(isfield(zef,'freesurfer_subject_name'))
    zef.freesurfer_subject_name = '';
end
if not(isfield(zef,'freesurfer_v1_data'))
    zef.freesurfer_v1_data = [];
end
if not(isfield(zef,'freesurfer_v1_info'))
    zef.freesurfer_v1_info = [];
end
% Safety: If FA data exists but is very large, clear it to prevent issues
if isfield(zef,'freesurfer_fa_data') && ~isempty(zef.freesurfer_fa_data)
    try
        % Estimate size: number of elements * bytes per element
        fa_dims = size(zef.freesurfer_fa_data);
        num_elements = prod(fa_dims);
        bytes_per_element = 4;  % single precision = 4 bytes
        estimated_bytes = num_elements * bytes_per_element;
        
        if estimated_bytes > 1e9  % > 1 GB
            warning('Large FA data detected (~%d MB). Clearing to prevent memory issues. Reload when needed.', round(estimated_bytes/1e6));
            zef.freesurfer_fa_data = [];
            zef.freesurfer_fa_info = [];
            zef.freesurfer_fa_loaded = false;
        end
    catch
        % Can't check size, assume it's okay
    end
end
if not(isfield(zef,'freesurfer_fa_loaded'))
    zef.freesurfer_fa_loaded = false;
end

% ========================================================================
% CONVERSION MODEL PARAMETERS
% ========================================================================
% WHY: Different biophysical models require different parameters
if not(isfield(zef,'dti_conductivity_model'))
    zef.dti_conductivity_model = 1;  % 1=Volume fraction, 2=Effective medium, 3=Direct scaling
end
if not(isfield(zef,'dti_volume_fraction'))
    zef.dti_volume_fraction = 0.7;  % Typical white matter volume fraction
end
if not(isfield(zef,'dti_extra_conductivity'))
    zef.dti_extra_conductivity = 1.0;  % S/m (extracellular space)
end
if not(isfield(zef,'dti_intra_conductivity'))
    zef.dti_intra_conductivity = 0.6;  % S/m (intracellular space)
end
if not(isfield(zef,'dti_conductivity_scale'))
    zef.dti_conductivity_scale = 1.0;  % Scaling factor for direct scaling model
end
if not(isfield(zef,'dti_anisotropy_threshold'))
    zef.dti_anisotropy_threshold = 0.2;  % Minimum FA to apply anisotropy
end
if not(isfield(zef,'dti_mean_diffusivity'))
    zef.dti_mean_diffusivity = 0.7;  % μm²/ms, for Effective Medium (model 2); Tuch et al. WM
end

% ========================================================================
% INTERPOLATION PARAMETERS
% ========================================================================
% WHY: Control how DTI data is mapped to mesh
if not(isfield(zef,'dti_interpolation_mode'))
    zef.dti_interpolation_mode = 'radius_average';  % 'nearest' or 'radius_average'
end
if not(isfield(zef,'dti_interpolation_radius'))
    zef.dti_interpolation_radius = 2.0;  % mm - radius for averaging
end

% ========================================================================
% COMPARTMENT SELECTION
% ========================================================================
% WHY: Allow user to apply DTI only to specific compartments
if not(isfield(zef,'dti_apply_to_compartments'))
    % Default: apply to gray and white matter
    zef.dti_apply_to_compartments = {'g', 'w'};
end

% ========================================================================
% TRANSFORMATION MATRICES
% ========================================================================
% WHY: Coordinate transformation for mesh↔FA voxel space mapping.
% These are now AUTO-EXTRACTED from input files (no manual entry needed):
%   - dti_dwi_vox2ras_tkr  ← extracted from fa.nii.gz
%   - dti_ref_vox2ras      ← extracted from reference MRI (e.g. orig.mgz)
%   - dti_ref_vox2ras_tkr  ← extracted from reference MRI
%   - dti_ref_center       ← extracted from reference MRI

if not(isfield(zef,'dti_dwi_vox2ras_tkr'))
    zef.dti_dwi_vox2ras_tkr = eye(4);  % Identity = not yet extracted
end
if not(isfield(zef,'dti_ref_vox2ras'))
    zef.dti_ref_vox2ras = eye(4);  % Identity = not yet extracted
end
if not(isfield(zef,'dti_ref_vox2ras_tkr'))
    zef.dti_ref_vox2ras_tkr = eye(4);  % Identity = not yet extracted
end
if not(isfield(zef,'dti_ref_center'))
    zef.dti_ref_center = [0; 0; 0];  % Zero = not yet extracted
end
if not(isfield(zef,'dti_matrices_approved'))
    zef.dti_matrices_approved = false;
end

% Reference MRI file path (e.g. orig.mgz from recon-all)
if not(isfield(zef,'dti_ref_mri_file'))
    zef.dti_ref_mri_file = '';
end

% Auto-extracted geometry structs (empty struct allows dot indexing)
if not(isfield(zef,'dti_fa_geometry'))
    zef.dti_fa_geometry = zef_dti_empty_geometry_struct();
end
if not(isfield(zef,'dti_ref_geometry'))
    zef.dti_ref_geometry = zef_dti_empty_geometry_struct();
end

% ========================================================================
% GUI RESIZE TRACKING
% ========================================================================
% WHY: Track window size for responsive resizing
if not(isfield(zef,'dti_conductivity_tool_current_size'))
    zef.dti_conductivity_tool_current_size = [];
end
if not(isfield(zef,'dti_conductivity_tool_relative_size'))
    zef.dti_conductivity_tool_relative_size = [];
end

% ========================================================================
% STATUS FLAGS
% ========================================================================
% WHY: Track state for GUI updates and validation
if not(isfield(zef,'dti_applied'))
    zef.dti_applied = false;
end
if not(isfield(zef,'dti_applied_time'))
    zef.dti_applied_time = [];
end

% Safety: Don't try to assign if zef is invalid or in wrong workspace
try
    assignin('base','zef',zef);
catch ME
    warning('Could not update zef in base workspace: %s', ME.message);
end

end
