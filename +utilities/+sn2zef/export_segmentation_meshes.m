function [affine_matrix, vertex_transform] = export_segmentation_meshes(zef, inFolder, outFolder, inflation_parameter, freesurfer_subject_folder, options)
%EXPORT_SEGMENTATION_MESHES  Volume-based SimNIBS tissues → STL in FreeSurfer tkr-RAS.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [affine_matrix, vertex_transform] = export_segmentation_meshes(...)
%
%   Segments final_tissues.nii.gz per label (not Gmsh .msh sheets). Aligns via
%   mri_coreg/LTA or header translation; writes STLs and optional atlas points.
%   affine_matrix is [] when vertices are already in FS tkr-RAS.

%
% export_segmentation_meshes
%
% Exports each tissue label from a SimNIBS final_tissues.nii.gz volume as
% individual STL surface files. Supports two alignment modes:
%
%   'translation' (default) - Extract from native SimNIBS volume and compute
%     a header-based affine (rotation + translation from vox2ras + CRAS) to
%     FreeSurfer space, stored in ZEF affine_transform. No intensity-based
%     coregistration.
%
%   'coregistration' - Align volume to FreeSurfer using mri_coreg/mri_vol2vol,
%     then extract surfaces. Vertices are already in FreeSurfer space;
%     returns empty affine (identity applied at import).
%
% Inputs:
%
% - zef (1,1) struct
%
%   The ZEF context struct required for Brainstorm surface extraction.
%
% - inFolder (1,1) string { mustBeFolder }
%
%   Input folder with final_tissues_LUT.txt and final_tissues.nii.gz.
%
% - outFolder (1,1) string
%
%   Output directory for STL files. Created if needed.
%
% - inflation_parameter (1,1) double
%
%   Taubin inflation iterations per tissue (0 to skip). Large values on a
%   full SimNIBS grid are very slow; see utilities.sn2zef.run help.
%
% - freesurfer_subject_folder (1,1) string { mustBeFolder }
%
%   FreeSurfer subject directory containing mri/orig.mgz.
%
% - options (1,1) struct (optional)
%
%   .alignment_mode - 'translation' (default) or 'coregistration'
%   .verbose       - Print diagnostic output (default: false)
%
% Outputs:
%
%   affine_matrix - 4x4 SimNIBS→FS matrix for ZEF affine_transform (header-based
%     linear map in translation mode), or [] in coregistration mode (vertices
%     already in FreeSurfer space).
%
%   vertex_transform (optional second output) - struct with fields:
%     .T (4x4 double) - Same voxel-to-RAS matrix applied to STL vertices in this
%       run (vox2ras in translation mode; Ttrans*vox2ras*coordSwap in coreg mode).
%     .volume_path (char) - Absolute path to the NIfTI whose voxels were meshed
%       (native final_tissues.nii.gz or aligned final_tissues_aligned.nii.gz).
%     .lut - SimNIBS LUT struct (same as readSNLUT) for building import_segmentations.zef
%       without re-reading final_tissues_LUT.txt.
%     .atlas_points_filename - basename written when options.include_atlas is
%       true; empty char vector otherwise.
%
% See also: run, export_from_gmsh_mesh
%

    arguments
        zef (1,1) struct
        inFolder (1,1) string { mustBeFolder }
        outFolder (1,1) string
        inflation_parameter (1,1) double
        freesurfer_subject_folder (1,1) string { mustBeFolder }
        options.alignment_mode (1,1) string { mustBeMember(options.alignment_mode, {'translation','coregistration'}) } = 'translation'
        options.verbose (1,1) logical = false
        options.include_atlas (1,1) logical = true
        options.atlas_voxel_stride (1,1) double { mustBePositive, mustBeInteger } = 4
    end

    % Ensure output directory exists
    if ~exist(outFolder, 'dir')
        mkdir(outFolder);
    end

    % Read SimNIBS label lookup table
    lut = utilities.sn2zef.readSNLUT(inFolder);

    % Validate FreeSurfer environment
    fs_home = getenv("FREESURFER_HOME");
    if strlength(fs_home) == 0
        error("sn2zef:EnvNotSet", ...
            "FREESURFER_HOME must be set.");
    end
    if ~isfolder(fs_home)
        error("sn2zef:EnvInvalid", ...
            "FREESURFER_HOME does not point to an existing directory.");
    end

    % Add FreeSurfer MATLAB toolbox for MRIread (in matlab/ or fsfast/toolbox)
    fs_matlab = fullfile(fs_home, 'matlab');
    fsf_tb = fullfile(fs_home, 'fsfast', 'toolbox');
    for p = {fs_matlab, fsf_tb}
        pth = p{1};
        if isfolder(pth) && ~contains(path, pth)
            addpath(pth);
        end
    end

    simnibs_nii = fullfile(inFolder, 'final_tissues.nii.gz');
    fs_ref_mgz  = fullfile(freesurfer_subject_folder, 'mri', 'orig.mgz');

    if ~isfile(simnibs_nii)
        error('sn2zef:NoInput', 'SimNIBS volume not found: "%s".', simnibs_nii);
    end
    if ~isfile(fs_ref_mgz)
        error('sn2zef:NoRef', 'FreeSurfer reference not found: "%s".', fs_ref_mgz);
    end

    use_translation = strcmpi(options.alignment_mode, 'translation');

    % Suppress legacy rand warning from FreeSurfer's load_mgh (used by MRIread)
    warn_id = 'MATLAB:RandStream:ActivatingLegacyGenerators';
    warn_state = warning('off', warn_id);

    if use_translation
        % Translation mode: read native SimNIBS volume, no coregistration
        try
            mri = MRIread(char(simnibs_nii));
        catch ME
            warning(warn_state);
            rethrow(ME);
        end
        volume_path_for_export = simnibs_nii;
        if options.verbose
            fprintf('Using header-based SimNIBS→FreeSurfer affine (no intensity coregistration).\n');
        end
    else
        % Coregistration mode: align volume to FreeSurfer
        fs_bin = fullfile(fs_home, 'bin');
        mri_coreg_path = fullfile(fs_bin, 'mri_coreg');
        mri_vol2vol_path = fullfile(fs_bin, 'mri_vol2vol');
        lta_file = fullfile(outFolder, 'simnibs_to_subject.lta');
        aligned_nii = fullfile(outFolder, 'final_tissues_aligned.nii.gz');

        cmd1 = mri_coreg_path + " --mov " + simnibs_nii + " --ref " + fs_ref_mgz + " --reg " + lta_file;
        cmd2 = mri_vol2vol_path + " --mov " + simnibs_nii + " --targ " + fs_ref_mgz + " --lta " + lta_file + " --o " + aligned_nii;

        utilities.sn2zef.run_and_print_command(cmd1);
        utilities.sn2zef.run_and_print_command(cmd2);

        if ~isfile(aligned_nii)
            warning(warn_state);
            error('sn2zef:AlignFailed', 'Volume alignment failed. No file: "%s".', aligned_nii);
        end

        try
            mri = MRIread(char(aligned_nii));
        catch ME
            warning(warn_state);
            rethrow(ME);
        end
        volume_path_for_export = aligned_nii;
        if options.verbose
            fprintf('Using coregistration alignment. Surfaces in FreeSurfer space.\n');
        end
    end
    warning(warn_state);

    V = mri.vol;
    vox2ras = mri.vox2ras;
    center_offset = [mri.c_r, mri.c_a, mri.c_s];

    % Transformation from voxel to RAS
    % Coregistration mode: FreeSurfer-style with center and coord swap
    % Translation mode: SimNIBS NIfTI vox2ras (standard)
    if use_translation
        T = vox2ras;
    else
        Ttrans = eye(4);
        Ttrans(1:3, 4) = -center_offset;
        coordSwap = [0 1 0 0; 1 0 0 0; 0 0 1 0; 0 0 0 1];
        T = Ttrans * vox2ras * coordSwap;
    end

    % Find labels present in volume
    labelsUsed = unique(V(:));
    labelsUsed(labelsUsed == 0) = [];

    % Build atlas structure
    Labels = cell(numel(lut.Name), 3);
    Labels(:, 1) = num2cell(lut.No);
    Labels(:, 2) = cellstr(lut.Name);
    for i = 1:numel(lut.Name)
        Labels{i, 3} = [lut.R(i), lut.G(i), lut.B(i)];
    end

    % Wrap Labels in cell to prevent struct() from expanding (struct expands cell-array field values)
    atlas_struct = struct(...
        'Comment', 'SimNIBS atlas', ...
        'Cube', V, ...
        'Labels', {Labels}, ...
        'InitTransf', {{[], mri.vox2ras}});

    allIDs = cell2mat(atlas_struct.Labels(:, 1));
    keep = ismember(allIDs, labelsUsed);
    atlas_struct.Labels = atlas_struct.Labels(keep, :);

    % Avoid zef_waitbar here: it touches the Zeffiro figure tree and drawnow,
    % which can feel like a hang during long full-volume meshing. Use
    % command-line progress inside zef_bst_get_atlas_surfaces instead.
    atlas_struct.SkipZefWaitbar = true;

    szv = size(V);
    nVox = prod(szv);
    fprintf(1, ['sn2zef: extracting STL surfaces from %d x %d x %d volume ' ...
        '(%d labels, %d inflation steps each; this may take many minutes).\n'], ...
        szv(1), szv(2), szv(3), size(atlas_struct.Labels, 1), inflation_parameter);
    if inflation_parameter > 40 && nVox > 1e6
        warning('sn2zef:SlowInflation', ...
            ['High inflation (%d steps) on a large volume is very slow. ' ...
            'Try 0-20 for a first test, then raise if needed.'], inflation_parameter);
    end

    % Extract surfaces (Brainstorm tetrahedral + marching-cubes style)
    b = utilities.brainstorm2zef.zef_bst_get_atlas_surfaces(...
        zef, atlas_struct, inflation_parameter, ...
        cell(0), '', ones(size(atlas_struct.Labels, 1), 1));

    fprintf(1, 'sn2zef: surface extraction finished (%d meshes).\n', numel(b));

    % Export each surface as STL
    for i = 1:numel(b)
        try
            if ~isfield(b(i), 'Triangles') || ~isfield(b(i), 'Points')
                warning('Surface %d missing Triangles or Points. Skipping.', i);
                continue;
            end

            tris = b(i).Triangles;
            pts  = b(i).Points;

            if isempty(tris) || isempty(pts) || size(pts, 2) ~= 3 || size(tris, 2) ~= 3
                warning('Surface %d has invalid mesh data. Skipping.', i);
                continue;
            end

            % Voxel grid -> RAS (FreeSurfer / MRIread convention)
            %
            % Brainstorm meshgrid stores each row of pts as
            %   [dim1, dim2, dim3] continuous voxel-grid coordinates (+0.5 shift).
            % MRIread's vox2ras expects homogeneous vectors in (col, row, slice)
            % order, i.e. (MATLAB dim2, dim1, dim3). Reorder before multiply.
            pts_hom = [pts(:, 2), pts(:, 1), pts(:, 3), ones(size(pts, 1), 1)];
            pts_ras = (T * pts_hom')';
            pts_ras = pts_ras(:, 1:3);

            % STL winding: swap 2nd/3rd triangle indices so outward normals
            % match the Brainstorm extraction (same flip as fs2zef writers).
            tris_flipped = tris(:, [1 3 2]);

            if i <= size(atlas_struct.Labels, 1) && size(atlas_struct.Labels, 2) >= 2
                label_name = atlas_struct.Labels{i, 2};
            else
                if isfield(b(i), 'Name') && ~isempty(b(i).Name)
                    label_name = b(i).Name;
                else
                    label_name = sprintf('Surface_%d', i);
                end
            end
            if isempty(label_name)
                label_name = sprintf('Label_%d', i);
            end

            stl_path = fullfile(outFolder, sprintf('%s.stl', label_name));
            stlwrite(triangulation(tris_flipped, pts_ras), stl_path);
            fprintf('Wrote %s\n', stl_path);

        catch ME
            warning('Failed to write STL for surface %d: %s', i, ME.message);
        end
    end

    % Compute affine for ZEF when using translation mode
    if use_translation
        affine_matrix = utilities.sn2zef.transforms.compute_simnibs_to_freesurfer_translation(...
            simnibs_nii, fs_ref_mgz, 'verbose', options.verbose);
    else
        affine_matrix = [];
    end

    atlas_pts = "";
    if options.include_atlas
        try
            atlas_pts = utilities.sn2zef.save_volume_atlas_points( ...
                double(V), T, affine_matrix, outFolder, options.atlas_voxel_stride);
        catch ME
            warning('sn2zef:AtlasWriteFailed', ...
                'Could not write SimNIBS atlas points: %s', ME.message);
        end
    end

    vertex_transform = struct( ...
        'T', T, ...
        'volume_path', char(volume_path_for_export), ...
        'lut', lut, ...
        'atlas_points_filename', char(atlas_pts));

end % function