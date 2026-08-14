function run(zef, subject_id, outFolder, inflation_parameter, options)
%RUN  SimNIBS volume segmentation → STL meshes and import_segmentations.zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   run(zef, subject_id, outFolder, inflation_parameter, options)
%
% Extracts closed compartment surfaces from the SimNIBS segmentation volume
% (final_tissues.nii.gz) via voxel tetrahedral decomposition and
% zef_surface_mesh — not from the Gmsh .msh file. The Gmsh mesh stores each
% surface triangle on exactly one tissue interface (label + 1000), which
% yields open, single-sided sheets rather than watertight shells.
%
% Inputs:
%
% - zef (1,1) struct
%
%   ZEF context (required for surface inflation in zef_inflate_surface).
%
% - subject_id (1,1) string
%
%   Subject identifier. The SimNIBS folder is expected at
%   SIMNIBS_HOME/m2m_<subject_id>/ with final_tissues.nii.gz and
%   final_tissues_LUT.txt.
%
% - outFolder (1,1) string
%
%   Output directory for STL files, atlas point files, electrodes.dat, and
%   import_segmentations.zef.
%
% - inflation_parameter (1,1) double
%
%   Taubin inflation iterations per tissue (0 to skip).
%
% - options (1,1) struct (optional)
%
%   .verbose                   - Print progress (default: false).
%   .include_atlas             - Write sn_atlas_points.dat (default: true).
%   .atlas_voxel_stride        - Subsample atlas voxels (default: 4).
%   .force_coreg               - Collected here and forwarded to
%                                export_segmentation_meshes (that worker
%                                does not declare this name; see README).
%   .freesurfer_subject_folder - FreeSurfer subject dir (mri/orig.mgz).
%                                Defaults to SUBJECTS_DIR/<subject_id>.
%
% Alignment is delegated to export_segmentation_meshes. This wrapper does
% not pass alignment_mode, so the worker default is 'translation' (native
% NIfTI vox2ras on vertices). The affine_matrix the worker returns is
% discarded here ([~, vertex_info] = ...) and import_segmentations.zef is
% written without affine_transform. options.force_coreg is forwarded as a
% name-value; the worker currently accepts alignment_mode, not force_coreg.
% For mri_coreg, call export_segmentation_meshes(..., 'alignment_mode',
% 'coregistration') directly.
%
% Outputs:
%
%   None. Writes to outFolder:
%     • <Tissue_Name>.stl         - one STL per tissue label
%     • electrodes.dat            - copied from +fs2zef/data if available
%     • sn_atlas_points.dat       - parcellation points (when include_atlas)
%     • import_segmentations.zef  - ZEF import script
%
% See also: utilities.sn2zef.export_segmentation_meshes,
%           utilities.sn2zef.readSNLUT
%

    if nargin < 5
        options = struct();
    end
    if ~isfield(options, 'verbose')
        options.verbose = false;
    end
    if ~isfield(options, 'include_atlas')
        options.include_atlas = true;
    end
    if ~isfield(options, 'atlas_voxel_stride')
        options.atlas_voxel_stride = 4;
    end
    if ~isfield(options, 'force_coreg')
        options.force_coreg = false;
    end
    if ~isfield(options, 'freesurfer_subject_folder')
        subjects_dir = getenv("SUBJECTS_DIR");
        if strlength(subjects_dir) == 0
            options.freesurfer_subject_folder = "";
        else
            options.freesurfer_subject_folder = fullfile(subjects_dir, char(subject_id));
        end
    end

    %% Locate SimNIBS m2m folder

    simnibs_home = getenv("SIMNIBS_HOME");
    if strlength(simnibs_home) == 0
        error('sn2zef:NoSimnibsHome', 'SIMNIBS_HOME is not set.');
    end

    inFolder = fullfile(simnibs_home, "m2m_" + subject_id);
    if ~isfolder(inFolder)
        error('sn2zef:NoInput', ...
            'SimNIBS m2m folder not found: "%s". Check SIMNIBS_HOME and subject_id.', ...
            inFolder);
    end

    nii_path = fullfile(inFolder, 'final_tissues.nii.gz');
    if ~isfile(nii_path)
        error('sn2zef:NoVolume', ...
            'SimNIBS segmentation volume not found: "%s".', nii_path);
    end

    fs_folder = char(options.freesurfer_subject_folder);
    if strlength(fs_folder) == 0
        error('sn2zef:NoFsSubjectFolder', ...
            ['FreeSurfer subject folder is required (mri/orig.mgz). ' ...
             'Set SUBJECTS_DIR or options.freesurfer_subject_folder.']);
    end
    if ~isfolder(fs_folder)
        error('sn2zef:NoFsSubjectFolder', ...
            'FreeSurfer subject folder not found: "%s".', fs_folder);
    end

    %% Create output folder

    if ~isfolder(outFolder)
        mkdir(outFolder);
    end

    %% Extract closed surfaces from final_tissues.nii.gz

    zef = ensure_inflation_fields(zef, inflation_parameter);

    if options.verbose
        fprintf('sn2zef: extracting surfaces from "%s"\n', nii_path);
    end

    [~, vertex_info] = utilities.sn2zef.export_segmentation_meshes( ...
        zef, inFolder, outFolder, inflation_parameter, fs_folder, ...
        'verbose', logical(options.verbose), ...
        'include_atlas', logical(options.include_atlas), ...
        'atlas_voxel_stride', double(options.atlas_voxel_stride), ...
        'force_coreg', logical(options.force_coreg));

    lut = vertex_info.lut;

    %% Collect STL outputs (skip auxiliary domain-fill mesh)

    stl_rows = struct('basename', {}, 'name', {}, 'rgb', {});

    for ii = 1 : numel(lut.No)
        name = strtrim(char(lut.Name{ii}));
        if contains(lower(name), 'domain fill')
            continue;
        end

        basename = [name '.stl'];
        stl_path = fullfile(outFolder, basename);
        if ~isfile(stl_path)
            continue;
        end

        rgb = [double(lut.R(ii)), double(lut.G(ii)), double(lut.B(ii))] / 255;
        rgb = round(rgb, 3);

        stl_rows(end+1) = struct('basename', basename, 'name', name, 'rgb', rgb); %#ok<AGROW>
    end

    if isempty(stl_rows)
        warning('sn2zef:NoSTL', ...
            'No STL files were generated from "%s". Aborting.', nii_path);
        return;
    end

    %% Copy electrode positions from +fs2zef helpers (best effort)

    thisDir = fileparts(mfilename('fullpath'));
    electrodesSource = fullfile(thisDir, '..', '+fs2zef', 'data', 'electrodes.dat');
    if isfile(electrodesSource)
        copyfile(electrodesSource, fullfile(outFolder, 'electrodes.dat'));
    else
        warning('sn2zef:NoElectrodes', ...
            'Electrodes file not found at "%s". Skipping electrode file copy.', ...
            electrodesSource);
    end

    %% Atlas points (written by the worker when include_atlas). Vertices use
    % the worker's T (SimNIBS vox2ras in the default translation mode), not
    % automatically FreeSurfer tkr-RAS. run discards affine_matrix above.

    have_atlas_points = false;
    atlas_pts_path = '';
    if options.include_atlas && isfield(vertex_info, 'atlas_points_filename') ...
            && strlength(string(vertex_info.atlas_points_filename)) > 0
        atlas_pts_path = char(fullfile(outFolder, vertex_info.atlas_points_filename));
        have_atlas_points = isfile(atlas_pts_path);
    end

    %% Build header and segmentation lines for the .zef script

    hdrLines = { ...
        sprintf('type,sensors,name,Electrodes,filename,%s,filetype,points,modality,EEG', ...
                fullfile(outFolder, 'electrodes.dat')); ...
        'type,box,name,Box' ...
    };

    nSeg = numel(stl_rows);
    segLines = cell(nSeg, 1);

    for k = 1 : nSeg
        row     = stl_rows(k);
        absPath = fullfile(outFolder, row.basename);
        merge_val = right_hemisphere_merge_flag(row.name);

        % sigma=1.79 is the CSF-like default this converter writes for every
        % SimNIBS tissue (not the fs2zef compartment_mappings table). Edit
        % the .zef or the Segmentation-tool table after import if you need
        % tissue-specific conductivity.

        segLines{k} = sprintf( ...
            ['type,segmentation,name,%s,filename,%s,merge,%d,' ...
             'parameter_name,sigma,parameter_value,1.79,activity,0,' ...
             'color,%s,inflate,0'], ...
            row.name, absPath, merge_val, mat2str(row.rgb));

        if have_atlas_points
            segLines{k} = sprintf('%s,atlas_points_filename,%s', ...
                segLines{k}, atlas_pts_path);
        end
    end

    %% Sort segments by name and merge value for deterministic output

    names     = cell(nSeg, 1);
    mergeNums = zeros(nSeg, 1);
    for i = 1 : nSeg
        parts    = strsplit(segLines{i}, ',');
        nameIdx  = find(strcmp(parts, 'name'),  1, 'first') + 1;
        mergeIdx = find(strcmp(parts, 'merge'), 1, 'first') + 1;
        names{i}     = parts{nameIdx};
        mergeNums(i) = str2double(parts{mergeIdx});
    end
    Tbl = table(names, mergeNums, (1:nSeg)', 'VariableNames', {'Name', 'Merge', 'OrigIdx'});
    Tbl = sortrows(Tbl, {'Name', 'Merge'});
    sortedIdx = Tbl.OrigIdx;

    %% Write import_segmentations.zef

    zefPath = fullfile(outFolder, 'import_segmentations.zef');
    fid = fopen(zefPath, 'wt');
    if fid < 0
        error('sn2zef:WriteFailed', 'Could not open "%s" for writing.', zefPath);
    end
    cleanup = onCleanup(@() fclose(fid));

    for i = 1 : numel(hdrLines)
        fprintf(fid, '%s\n', hdrLines{i});
    end
    for ii = 1 : numel(sortedIdx)
        fprintf(fid, '%s\n', segLines{sortedIdx(ii)});
    end

    if options.verbose
        fprintf('sn2zef: wrote %s (%d segmentation rows)\n', zefPath, nSeg);
    end

end % function

%% Local helpers

function merge_val = right_hemisphere_merge_flag(name)
    lname = lower(name);
    if contains(lname, 'rh') || contains(lname, 'right')
        merge_val = 1;
    else
        merge_val = 0;
    end
end % function

function zef = ensure_inflation_fields(zef, inflation_parameter)
    % zef_inflate_surface reads zef.inflate_strength from the caller workspace.
    if ~isfield(zef, 'inflate_strength')
        zef.inflate_strength = 0.8;
    end
    if ~isfield(zef, 'inflate_n_iterations')
        zef.inflate_n_iterations = max(0, round(inflation_parameter));
    end
    if ~isfield(zef, 'gpu_count')
        zef.gpu_count = 0;
    end
    if ~isfield(zef, 'use_gpu')
        zef.use_gpu = false;
    end
    if ~isfield(zef, 'use_gpu_graphic')
        zef.use_gpu_graphic = false;
    end
end % function
