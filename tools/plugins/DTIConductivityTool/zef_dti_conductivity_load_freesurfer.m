function zef = zef_dti_conductivity_load_freesurfer(zef)
%ZEF_DTI_CONDUCTIVITY_LOAD_FREESURFER  Load FA, v1, register.dat, reference MRI.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Load button on the DTI Conductivity Tool. Requires zef.freesurfer_fa_file
%   (or the path edit). Does not write zef.sigma.
%
%   Side effects on zef
%     freesurfer_fa_data / _info / _loaded — niftiread + niftiinfo; Transform.T
%       is forced to a 4×4 so zef_freesurfer_transform_coordinates can voxel→tkRAS
%     optional freesurfer_v1_data(:,:,:,1:3) if the NIfTI is 4-D with ≥3 vols
%     freesurfer_register_transform from zef_freesurfer_read_register_dat
%     dti_ref_vox2ras / _tkr / _center / dti_ref_geometry if the reference MRI exists
%     dti_fa_geometry from zef_freesurfer_read_volume_geometry
%     status/info labels on the tool
%
%   Missing FA path or file → warning and return. nargout==0 → assignin base.
%
%   See also zef_dti_apply_to_sigma, zef_dti_conductivity_browse_fa.

if nargin == 0
    zef = evalin('base','zef');
end

% Require FA file
if ~isfield(zef,'freesurfer_fa_file') || isempty(zef.freesurfer_fa_file)
    if isfield(zef,'h_freesurfer_fa_file') && isvalid(zef.h_freesurfer_fa_file)
        zef.freesurfer_fa_file = zef.h_freesurfer_fa_file.Value;
    end
end
if isempty(zef.freesurfer_fa_file)
    warning('No FA file specified. Set FA file path and try again.');
    if nargout == 0
        assignin('base','zef',zef);
    end
    return;
end

% Load reference MRI geometry (if specified)
if isfield(zef,'dti_ref_mri_file') && ~isempty(zef.dti_ref_mri_file)
    ref_file = zef.dti_ref_mri_file;
    if isfield(zef,'h_dti_ref_mri_file') && isvalid(zef.h_dti_ref_mri_file)
        ref_file = zef.h_dti_ref_mri_file.Value;
    end
    if isfile(ref_file)
        try
            ref_geom = zef_freesurfer_read_volume_geometry(ref_file);

            zef.dti_ref_vox2ras     = ref_geom.vox2ras;
            zef.dti_ref_vox2ras_tkr = ref_geom.vox2ras_tkr;
            zef.dti_ref_center      = ref_geom.center_ras;
            zef.dti_ref_geometry    = ref_geom;

            if isfield(zef,'h_dti_ref_status') && isvalid(zef.h_dti_ref_status)
                zef.h_dti_ref_status.Text = sprintf('Geometry extracted: %dx%dx%d, voxel %.1f×%.1f×%.1f mm', ...
                    ref_geom.dimensions(1), ref_geom.dimensions(2), ref_geom.dimensions(3), ...
                    ref_geom.voxel_sizes(1), ref_geom.voxel_sizes(2), ref_geom.voxel_sizes(3));
                zef.h_dti_ref_status.FontColor = [0 0.7 0];
            end
        catch ME
            if isfield(zef,'h_dti_ref_status') && isvalid(zef.h_dti_ref_status)
                zef.h_dti_ref_status.Text = sprintf('Error: %s', ME.message);
                zef.h_dti_ref_status.FontColor = [1 0 0];
            end
            warning('Failed to extract geometry from %s: %s', ref_file, ME.message);
        end
    else
        warning('Reference MRI file not found: %s', ref_file);
    end
end

fa_file = zef.freesurfer_fa_file;
if ~isfile(fa_file)
    warning('FA file not found: %s', fa_file);
    if nargout == 0
        assignin('base','zef',zef);
    end
    return;
end

% Load FA volume and info
try
    zef.freesurfer_fa_data = single(niftiread(fa_file));
    info = niftiinfo(fa_file);
    % Ensure Transform.T exists for zef_freesurfer_transform_coordinates (voxel → tkRAS, 4×4 column-premultiply)
    if isfield(info, 'Transform') && ~isempty(info.Transform)
        tform = info.Transform;
        if isstruct(tform) && isfield(tform, 'T')
            info.Transform = tform;
        elseif isstruct(tform) && isfield(tform, 'A')
            info.Transform = struct('T', double(tform.A));
        elseif isobject(tform)
            if isprop(tform, 'A')
                info.Transform = struct('T', double(tform.A));
            else
                info.Transform = struct('T', double(tform.T'));
            end
        else
            info.Transform = struct('T', double(tform.T'));
        end
    end
    zef.freesurfer_fa_info = info;
    zef.freesurfer_fa_loaded = true;
catch ME
    warning('Failed to load FA file: %s', ME.message);
    zef.freesurfer_fa_data = [];
    zef.freesurfer_fa_info = [];
    zef.freesurfer_fa_loaded = false;
    if nargout == 0
        assignin('base','zef',zef);
    end
    return;
end

% Optional v1
zef.freesurfer_v1_data = [];
zef.freesurfer_v1_info = [];
if isfield(zef,'freesurfer_v1_file') && ~isempty(zef.freesurfer_v1_file)
    v1_file = zef.freesurfer_v1_file;
    if isfield(zef,'h_freesurfer_v1_file') && isvalid(zef.h_freesurfer_v1_file)
        v1_file = zef.h_freesurfer_v1_file.Value;
    end
    if isfile(v1_file)
        try
            v1_vol = niftiread(v1_file);
            % v1 can be [nx,ny,nz,3] or 4D
            if ndims(v1_vol) == 4 && size(v1_vol,4) >= 3
                zef.freesurfer_v1_data = single(v1_vol(:,:,:,1:3));
            elseif ndims(v1_vol) == 3
                zef.freesurfer_v1_data = [];
            else
                zef.freesurfer_v1_data = single(v1_vol);
            end
            zef.freesurfer_v1_info = niftiinfo(v1_file);
        catch
            zef.freesurfer_v1_data = [];
        end
    end
end

% register.dat (required for mesh ↔ FA transform)
zef.freesurfer_register_transform = [];
if isfield(zef,'freesurfer_register_file') && ~isempty(zef.freesurfer_register_file)
    reg_file = zef.freesurfer_register_file;
    if isfield(zef,'h_freesurfer_register_file') && isvalid(zef.h_freesurfer_register_file)
        reg_file = zef.h_freesurfer_register_file.Value;
    end
    if isfile(reg_file)
        try
            zef.freesurfer_register_transform = zef_freesurfer_read_register_dat(reg_file);
        catch ME
            warning('Failed to load register.dat: %s', ME.message);
        end
    end
end

% Optional: store FA geometry for GUI
try
    % Prefer file path over niftiinfo struct for mri_info-based extraction
    if isfield(zef, 'freesurfer_fa_file') && ~isempty(zef.freesurfer_fa_file) && isfile(zef.freesurfer_fa_file)
        zef.dti_fa_geometry = zef_freesurfer_read_volume_geometry(zef.freesurfer_fa_file);
    else
        zef.dti_fa_geometry = zef_freesurfer_read_volume_geometry(zef.freesurfer_fa_info);
    end
catch
    zef.dti_fa_geometry = [];
end

% Update GUI status
if isfield(zef,'h_dti_status_text') && isvalid(zef.h_dti_status_text)
    [nx, ny, nz] = size(zef.freesurfer_fa_data);
    zef.h_dti_status_text.Text = sprintf('FreeSurfer FA loaded: %dx%dx%d', nx, ny, nz);
    zef.h_dti_status_text.FontColor = [0 0.7 0];
end
if isfield(zef,'h_dti_info_text') && isvalid(zef.h_dti_info_text)
    zef_dti_conductivity_update(zef);
end

if nargout == 0
    assignin('base','zef',zef);
end

end
