%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_GET_MESH2VOXEL
%
%Computes the 4×4 affine matrix that transforms Zeffiro mesh display
%coordinates to FreeSurfer FA voxel coordinates (0-based, same as mri_info).
%
%This matches the INVERSE of the transformation chain used by
%zef_visualize_dti_streamlines (which goes FA_voxel → mesh_display).
%
%FORWARD (FA_voxel → mesh_display, as in visualization):
%   1. FA_voxel → DWI_tkRAS:     T_dwi_vox2ras_tkr * voxel
%   2. DWI_tkRAS → T1_tkRAS:     inv(T_register) * DWI_tkRAS
%   3. T1_tkRAS → scanner_RAS:   T_ref_vox2ras * inv(T_ref_vox2ras_tkr) * T1_tkRAS
%   4. scanner_RAS → mesh_display: scanner - ref_center
%
%INVERSE (mesh_display → FA_voxel, for conductivity pipeline):
%   1. mesh_display → scanner_RAS:   mesh + ref_center
%   2. scanner_RAS → T1_tkRAS:       T_ref_vox2ras_tkr * inv(T_ref_vox2ras) * scanner
%   3. T1_tkRAS → DWI_tkRAS:         T_register * T1_tkRAS
%   4. DWI_tkRAS → FA_voxel:         inv(T_dwi_vox2ras_tkr) * DWI_tkRAS
%
%Combined:
%   T_mesh2voxel = inv(T_dwi_vox2ras_tkr) * T_register
%                  * T_ref_vox2ras_tkr * inv(T_ref_vox2ras) * T_translate(+ref_center)
%
%Matrix sources (in priority order):
%   1. Auto-extracted from files:
%      - zef.dti_dwi_vox2ras_tkr  ← extracted from fa.nii.gz on load
%      - zef.dti_ref_vox2ras      ← extracted from reference MRI on load
%      - zef.dti_ref_vox2ras_tkr  ← extracted from reference MRI on load
%      - zef.dti_ref_center       ← extracted from reference MRI on load
%   2. Auto-computed from file data:
%      - zef.freesurfer_fa_info   ← niftiinfo struct for FA
%      - zef.dti_ref_geometry     ← geometry struct from reference MRI
%   3. Legacy GUI handles (backward compatibility):
%      - zef.h_dti_dwi_vox2ras_tkr.Data, etc.
%
%Inputs:
%   zef - Zeffiro struct with transformation data (see above)
%
%Outputs:
%   T_mesh2voxel - [4×4] Affine matrix: mesh_display → FA_voxel (0-based voxel indices)
%   info         - Struct with source info for debugging
%
%See also: zef_visualize_dti_streamlines, zef_freesurfer_read_volume_geometry

function [T_mesh2voxel, info] = zef_dti_get_mesh2voxel(zef)
% --- Zeffiro documentation header ---
% zef_dti_get_mesh2voxel — Zef dti get mesh2voxel.
%
% Purpose:
%   Zef dti get mesh2voxel.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   zef
%
% Outputs:
%   T_mesh2voxel
%   info
%
% Zef fields (observed):
%   zef.dti_ref_geometry (read)
%   zef.freesurfer_fa_file (read)
%   zef.freesurfer_fa_info (read)
%   zef.freesurfer_register_transform (read)
%
% Calls (project):
%   zef_dti_get_mesh2voxel
%   zef_freesurfer_read_volume_geometry
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[T_mesh2voxel, info]] = zef_dti_get_mesh2voxel(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


arguments
    zef (1,1) struct
end

info = struct('T_dwi_vox2ras_tkr', [], 'T_ref_vox2ras', [], ...
              'T_ref_vox2ras_tkr', [], 'ref_center', [], ...
              'T_register', [], 'source', '');

% ========================================================================
% EXTRACT EACH REQUIRED MATRIX
% ========================================================================
% Priority: direct fields → auto-computed from file data → GUI handles

% ---- FA vox2ras-tkr (DWI volume) ----
T_dwi_vox2ras_tkr = get_matrix(zef, 'dti_dwi_vox2ras_tkr', 'h_dti_dwi_vox2ras_tkr', [4 4]);
if isempty(T_dwi_vox2ras_tkr) && isfield(zef, 'freesurfer_fa_info') && ~isempty(zef.freesurfer_fa_info)
    % Auto-compute from loaded FA file
    % Try file path first (more reliable), then fall back to niftiinfo struct
    try
        if isfield(zef, 'freesurfer_fa_file') && ~isempty(zef.freesurfer_fa_file) && isfile(zef.freesurfer_fa_file)
            fa_geom = zef_freesurfer_read_volume_geometry(zef.freesurfer_fa_file);
        else
            fa_geom = zef_freesurfer_read_volume_geometry(zef.freesurfer_fa_info);
        end
        T_dwi_vox2ras_tkr = fa_geom.vox2ras_tkr;
        info.source = [info.source 'FA_vox2ras_tkr:auto-computed '];
    catch
    end
end

% ---- Reference vox2ras ----
T_ref_vox2ras = get_matrix(zef, 'dti_ref_vox2ras', 'h_dti_ref_vox2ras', [4 4]);
if isempty(T_ref_vox2ras) && isfield(zef, 'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry)
    T_ref_vox2ras = zef.dti_ref_geometry.vox2ras;
    info.source = [info.source 'ref_vox2ras:from_geometry '];
end

% ---- Reference vox2ras-tkr ----
T_ref_vox2ras_tkr = get_matrix(zef, 'dti_ref_vox2ras_tkr', 'h_dti_ref_vox2ras_tkr', [4 4]);
if isempty(T_ref_vox2ras_tkr) && isfield(zef, 'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry)
    T_ref_vox2ras_tkr = zef.dti_ref_geometry.vox2ras_tkr;
    info.source = [info.source 'ref_vox2ras_tkr:from_geometry '];
end

% ---- Reference center ----
ref_center = get_vector(zef, 'dti_ref_center', 'h_dti_ref_center', 3);
if isempty(ref_center) && isfield(zef, 'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry)
    ref_center = zef.dti_ref_geometry.center_ras;
    info.source = [info.source 'ref_center:from_geometry '];
end

% ---- Register.dat ----
T_register = [];
if isfield(zef, 'freesurfer_register_transform') && ~isempty(zef.freesurfer_register_transform)
    T_register = double(zef.freesurfer_register_transform);
end

% ========================================================================
% VALIDATE
% ========================================================================
missing = {};
if isempty(T_dwi_vox2ras_tkr)
    missing{end+1} = 'FA vox2ras-tkr: Load fa.nii.gz (auto-extracted on load)';
end
if isempty(T_ref_vox2ras)
    missing{end+1} = 'Reference vox2ras: Select a Reference MRI file (e.g. orig.mgz)';
end
if isempty(T_ref_vox2ras_tkr)
    missing{end+1} = 'Reference vox2ras-tkr: Select a Reference MRI file (e.g. orig.mgz)';
end
if isempty(ref_center)
    missing{end+1} = 'Reference center: Select a Reference MRI file (e.g. orig.mgz)';
end
if isempty(T_register)
    missing{end+1} = 'register.dat: Load the register.dat file from dt_recon output';
end

if ~isempty(missing)
    error('zef_dti_get_mesh2voxel:missingData', ...
        ['Cannot compute mesh→voxel transform. Missing:\n' ...
         '  - %s\n' ...
         '\nThese are normally auto-extracted when loading files in the DTI Conductivity Tool.'], ...
        strjoin(missing, '\n  - '));
end

% ========================================================================
% COMPUTE T_MESH2VOXEL
% ========================================================================
% Step 1: translation that undoes the ref_center offset
T_translate = eye(4);
T_translate(1:3, 4) = ref_center(:);

% Step 2: combined matrix
%   mesh_display --(+ref_center)--> scanner_RAS
%   scanner_RAS  --(vox2ras_tkr * inv(vox2ras))--> T1_tkRAS
%   T1_tkRAS     --(T_register)--> DWI_tkRAS
%   DWI_tkRAS    --(inv(dwi_vox2ras_tkr))--> FA_voxel
T_mesh2voxel = (T_dwi_vox2ras_tkr \ eye(4)) ...    % inv(T_dwi_vox2ras_tkr)
             * T_register ...
             * T_ref_vox2ras_tkr ...
             * (T_ref_vox2ras \ eye(4)) ...          % inv(T_ref_vox2ras)
             * T_translate;

% Store info for debugging
info.T_dwi_vox2ras_tkr = T_dwi_vox2ras_tkr;
info.T_ref_vox2ras     = T_ref_vox2ras;
info.T_ref_vox2ras_tkr = T_ref_vox2ras_tkr;
info.ref_center        = ref_center;
info.T_register        = T_register;
if isempty(info.source)
    info.source = 'zef_dti_get_mesh2voxel';
end

end

%% -----------------------------------------------------------------------
%  Local helpers for robust matrix/vector extraction
%  -----------------------------------------------------------------------

function T = get_matrix(zef, direct_field, handle_field, expected_size)
%GET_MATRIX Extracts a matrix, checking direct field first, then GUI handle.
%Returns empty if only default identity values are found (indicating the
%matrix was never set by auto-extraction or manual entry).
    T = [];

    % Priority 1: Direct numeric field (set by auto-extraction)
    if isfield(zef, direct_field) && ~isempty(zef.(direct_field))
        d = zef.(direct_field);
        if isnumeric(d) && isequal(size(d), expected_size)
            if ~isequal(d, eye(expected_size(1)))
                T = double(d);
                return;
            end
        end
    end

    % Priority 2: GUI handle with .Data property (legacy manual entry)
    if isfield(zef, handle_field) && ~isempty(zef.(handle_field))
        try
            d = zef.(handle_field).Data;
            if isnumeric(d) && isequal(size(d), expected_size)
                if ~isequal(d, eye(expected_size(1)))
                    T = double(d);
                    return;
                end
            end
        catch
        end
    end

    % Both are default identity → return empty to trigger validation error
end

function v = get_vector(zef, direct_field, handle_field, expected_length)
%GET_VECTOR Extracts a vector, checking direct field first, then GUI handle.
%Returns empty if only default zero values are found.
    v = [];

    % Priority 1: Direct numeric field (set by auto-extraction)
    if isfield(zef, direct_field) && ~isempty(zef.(direct_field))
        d = zef.(direct_field);
        if isnumeric(d) && numel(d) == expected_length
            if any(d(:) ~= 0)
                v = double(d(:));
                return;
            end
        end
    end

    % Priority 2: GUI handle with .Data property (legacy manual entry)
    if isfield(zef, handle_field) && ~isempty(zef.(handle_field))
        try
            d = zef.(handle_field).Data;
            if isnumeric(d) && numel(d) == expected_length
                if any(d(:) ~= 0)
                    v = double(d(:));
                    return;
                end
            end
        catch
        end
    end

    % Both are default zero → return empty to trigger validation error
end
