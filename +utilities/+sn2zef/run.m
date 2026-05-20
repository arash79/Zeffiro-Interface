function run(zef, subject_id, outFolder, inflation_parameter, options) %#ok<INUSL>
% --- Zeffiro documentation header ---
% utilities.sn2zef.run — Run.
%
% Purpose:
%   Run.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef
%   subject_id
%   outFolder
%   inflation_parameter
%   options
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.simnibsToZef.main
%   utilities.sn2zef.meshLoadGmsh4
%   utilities.sn2zef.readSNLUT
%   utilities.sn2zef.run
%   utilities.sn2zef.save_atlas_points
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.sn2zef.run(zef, subject_id, outFolder, inflation_parameter, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%
% run - Mesh-based SimNIBS-to-ZEF pipeline
%
% Loads the SimNIBS Gmsh mesh (m2m_<subject_id>/<subject_id>.msh) and the
% tissue lookup table (final_tissues_LUT.txt), splits the surface triangles
% per tissue label into one STL each, builds parcellation points from the
% tetrahedral mesh, and writes the
% Zeffiro Interface import script.
%
% Orientation and scale are already correct: SimNIBS produces the mesh in
% scanner RAS at 1 mm. The only thing that differs from the FreeSurfer surface
% frame used by fs2zef is a translation. fs2zef calls mris_convert without
% --to-scanner, so its surfaces stay in FreeSurfer **surface (tkr) RAS**, which
% is related to scanner RAS by:
%
%   surface_RAS = scanner_RAS - cras_fs
%
% where cras_fs = [c_r; c_a; c_s] is the CRAS of the FreeSurfer T1 MGZ
% (mri/T1.mgz or mri/orig.mgz of the same subject).  We read that CRAS once
% and translate mesh.nodes by -cras_fs before writing STLs and computing
% atlas tetra centers.  Both outputs end up in the surface RAS frame, so the
% generated import_segmentations.zef can still omit affine_transform from
% every row (m/zef_import_segmentation.m:124 defaults to identity).
%
% This is the smallest pipeline that follows the logic of the reference
% example utilities.simnibsToZef.main (zeffiro_may_2026/+utilities/+simnibsToZef/main.m).
%
% Inputs:
%
% - zef (1,1) struct
%
%   Accepted for API back-compat. Not used by the mesh-based pipeline.
%
% - subject_id (1,1) string
%
%   Subject identifier. The SimNIBS folder is expected at
%   SIMNIBS_HOME/m2m_<subject_id>/ and must contain a Gmsh .msh file
%   (preferably <subject_id>.msh) and final_tissues_LUT.txt.
%
% - outFolder (1,1) string
%
%   Output directory for STL files, atlas point files, electrodes.dat, and
%   import_segmentations.zef. Created if it does not exist.
%
% - inflation_parameter (1,1) double
%
%   Accepted for API back-compat. Not used by the mesh-based pipeline (the
%   SimNIBS mesh is already smoothed at production time).
%
% - options (1,1) struct (optional)
%
%   .verbose                  - Print progress (default: false).
%   .include_atlas            - Write atlas_points_filename onto every
%                               segmentation row (default: true).
%   .stl_output_format        - 'binary' (default) or 'text' for stlwrite.
%   .freesurfer_subject_folder - Path to the FreeSurfer subject folder used
%                                to look up the surface-RAS translation
%                                (mri/T1.mgz or mri/orig.mgz).  Defaults to
%                                SUBJECTS_DIR/<subject_id>.  Pass "" to skip
%                                the translation entirely (mesh stays in
%                                scanner RAS).
%
% Outputs:
%
%   None. Writes to outFolder:
%     • <Tissue_Name>.stl         - one STL per tissue label
%     • electrodes.dat            - copied from +fs2zef/data if available
%     • sn_atlas_points.dat       - parcellation points    (when include_atlas)
%     • import_segmentations.zef  - ZEF import script
%
% See also: utilities.sn2zef.meshLoadGmsh4, utilities.sn2zef.readSNLUT,
%           utilities.sn2zef.save_atlas_points, utilities.sn2zef.export_from_gmsh_mesh
%

    % Parse optional arguments (keep loose to preserve old callers)
    if nargin < 5
        options = struct();
    end
    if ~isfield(options, 'verbose')
        options.verbose = false;
    end
    if ~isfield(options, 'include_atlas')
        options.include_atlas = true;
    end
    if ~isfield(options, 'stl_output_format')
        options.stl_output_format = 'binary';
    end
    if ~isfield(options, 'freesurfer_subject_folder')
        subjects_dir = getenv("SUBJECTS_DIR");
        if strlength(subjects_dir) == 0
            options.freesurfer_subject_folder = "";
        else
            options.freesurfer_subject_folder = fullfile(subjects_dir, char(subject_id));
        end
    end

    %% Locate inputs

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

    mesh_file = locate_mesh_file(inFolder, subject_id);

    %% Create output folder

    if ~isfolder(outFolder)
        mkdir(outFolder);
    end

    %% Load mesh and tissue LUT

    if options.verbose
        fprintf('sn2zef: loading mesh "%s"\n', mesh_file);
    end
    mesh = utilities.sn2zef.meshLoadGmsh4(mesh_file);
    lut  = utilities.sn2zef.readSNLUT(inFolder);

    %% Translate mesh nodes: scanner RAS -> FreeSurfer surface (tkr) RAS
    %  Single header lookup; the SimNIBS mesh already has the correct
    %  orientation and scale, only the surface-RAS shift is missing.

    cras_fs = lookup_freesurfer_cras(options.freesurfer_subject_folder, options.verbose);
    nodes   = double(mesh.nodes);
    if ~isempty(cras_fs)
        nodes = nodes - cras_fs(:).';
        mesh.nodes = nodes;  % propagate to save_atlas_points via the same struct
        if options.verbose
            fprintf('sn2zef: applied surface-RAS translation t = [%.3f %.3f %.3f]\n', ...
                -cras_fs(1), -cras_fs(2), -cras_fs(3));
        end
    end

    %% Export one STL per tissue label (translated nodes; no further transform)
    %  SimNIBS encodes surface region IDs as tissue_label + 1000 (see e.g.
    %  utilities.sn2zef.export_from_gmsh_mesh:145).

    tris   = double(mesh.triangles);
    triLab = double(mesh.triangle_regions);

    nLut = numel(lut.No);
    stl_rows = struct('basename', {}, 'name', {}, 'rgb', {});

    for ii = 1 : nLut
        tissue_id     = double(lut.No(ii));
        surface_region = tissue_id + 1000;
        mask           = (triLab == surface_region);
        if ~any(mask)
            continue;
        end

        name     = strtrim(char(lut.Name{ii}));
        safeName = make_safe_filename(name);
        basename = [safeName '.stl'];
        stl_path = fullfile(outFolder, basename);

        try
            T = triangulation(tris(mask, :), nodes);
            stlwrite(T, stl_path, options.stl_output_format);
            if options.verbose
                fprintf('  wrote %s\n', stl_path);
            end
        catch ME
            warning('sn2zef:StlFailed', ...
                'Could not write STL for tissue "%s": %s', name, ME.message);
            continue;
        end

        rgb = [double(lut.R(ii)), double(lut.G(ii)), double(lut.B(ii))] / 255;
        rgb = round(rgb, 3);

        stl_rows(end+1) = struct('basename', basename, 'name', name, 'rgb', rgb); %#ok<AGROW>
    end

    if isempty(stl_rows)
        warning('sn2zef:NoSTL', ...
            'No STL files were generated from "%s". Aborting.', mesh_file);
        return;
    end

    %% Copy electrode positions from +fs2zef helpers (best effort)

    thisDir = fileparts(mfilename('fullpath'));
    electrodesSource = fullfile(thisDir, '..', '+fs2zef', 'data', 'electrodes.dat');
    if exist(electrodesSource, 'file')
        copyfile(electrodesSource, fullfile(outFolder, 'electrodes.dat'));
    else
        warning('sn2zef:NoElectrodes', ...
            'Electrodes file not found at "%s". Skipping electrode file copy.', ...
            electrodesSource);
    end

    %% Build atlas point file
    %  Atlas points are tetra centers in the same coordinate frame as the
    %  STLs, so no transformation is required at any stage.

    have_atlas_points = false;
    atlas_pts_path = '';

    if options.include_atlas
        try
            pts_fname = utilities.sn2zef.save_atlas_points(mesh, outFolder);
            atlas_pts_path = char(fullfile(outFolder, pts_fname));
            have_atlas_points = true;
            if options.verbose
                fprintf('sn2zef: atlas point file written (%s)\n', pts_fname);
            end
        catch ME
            warning('sn2zef:AtlasFailed', ...
                'Atlas point generation failed: %s\nContinuing without atlas data.', ...
                ME.message);
        end
    end

    %% Build header and segmentation lines for the .zef script
    %  No affine_transform is written; the importer treats absence as identity
    %  (m/zef_import_segmentation.m:124).

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

        segLines{k} = sprintf( ...
            ['type,segmentation,name,%s,filename,%s,merge,%d,' ...
             'parameter_name,sigma,parameter_value,1.79,activity,0,color,%s,inflate,0'], ...
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

function mesh_file = locate_mesh_file(m2m_dir, subject_id)
    % Prefer <subject_id>.msh; fall back to any single .msh in m2m folder.
    preferred = fullfile(char(m2m_dir), [char(subject_id) '.msh']);
    if isfile(preferred)
        mesh_file = preferred;
        return;
    end
    candidates = dir(fullfile(m2m_dir, '*.msh'));
    if isempty(candidates)
        error('sn2zef:NoMesh', ...
            'No Gmsh .msh file found in "%s".', m2m_dir);
    end
    if numel(candidates) > 1
        names = strjoin({candidates.name}, ', ');
        error('sn2zef:AmbiguousMesh', ...
            'Multiple .msh files in "%s" (%s). Rename one to %s.msh.', ...
            char(m2m_dir), names, char(subject_id));
    end
    mesh_file = fullfile(candidates(1).folder, candidates(1).name);
end % function

function safe = make_safe_filename(name)
    % Replace filesystem-hostile characters with underscores.
    safe = strrep(strrep(strrep(strrep(strrep(name, ' ', '_'), '/', '_'), '\', '_'), ':', '_'), '*', '_');
end % function

function merge_val = right_hemisphere_merge_flag(name)
    % Right-hemisphere labels usually contain 'rh' or 'right' in their name.
    lname = lower(name);
    if contains(lname, 'rh') || contains(lname, 'right')
        merge_val = 1;
    else
        merge_val = 0;
    end
end % function

function cras = lookup_freesurfer_cras(fs_subject_folder, verbose)
% Return [c_r; c_a; c_s] from the FreeSurfer T1 MGZ of the subject, or [] if
% the lookup is skipped or fails.  The CRAS is the offset between scanner RAS
% (SimNIBS mesh frame) and FreeSurfer surface (tkr) RAS:
%
%   surface_RAS = scanner_RAS - cras
%
% Prefers mri/T1.mgz; falls back to mri/orig.mgz.

    cras = [];

    if isempty(fs_subject_folder) || strlength(fs_subject_folder) == 0
        if verbose
            fprintf('sn2zef: no FreeSurfer subject folder provided; skipping surface-RAS translation.\n');
        end
        return;
    end
    if ~isfolder(fs_subject_folder)
        warning('sn2zef:NoFsSubjectFolder', ...
            'FreeSurfer subject folder "%s" not found; skipping surface-RAS translation.', ...
            char(fs_subject_folder));
        return;
    end

    candidates = { ...
        fullfile(char(fs_subject_folder), 'mri', 'T1.mgz'); ...
        fullfile(char(fs_subject_folder), 'mri', 'orig.mgz') ...
    };
    mgz_path = '';
    for k = 1 : numel(candidates)
        if isfile(candidates{k})
            mgz_path = candidates{k};
            break;
        end
    end
    if isempty(mgz_path)
        warning('sn2zef:NoFsT1', ...
            'Neither mri/T1.mgz nor mri/orig.mgz found in "%s"; skipping surface-RAS translation.', ...
            char(fs_subject_folder));
        return;
    end

    % Ensure MRIread is on path
    fs_home = getenv('FREESURFER_HOME');
    if strlength(fs_home) > 0
        fs_matlab = fullfile(fs_home, 'matlab');
        if isfolder(fs_matlab) && ~contains(path, fs_matlab)
            addpath(fs_matlab);
        end
    end

    if exist('MRIread', 'file') ~= 2
        warning('sn2zef:NoMRIread', ...
            'MRIread is not on the MATLAB path; cannot read "%s". Skipping surface-RAS translation.', mgz_path);
        return;
    end

    try
        mri = MRIread(mgz_path);
    catch ME
        warning('sn2zef:ReadMgzFailed', ...
            'Failed to read "%s": %s. Skipping surface-RAS translation.', mgz_path, ME.message);
        return;
    end

    if isfield(mri, 'c_r') && isfield(mri, 'c_a') && isfield(mri, 'c_s')
        cras = [double(mri.c_r); double(mri.c_a); double(mri.c_s)];
    elseif isfield(mri, 'vox2ras') && isfield(mri, 'tkrvox2ras')
        % Fallback: derive cras from the two vox2ras matrices.
        cras = mri.vox2ras(1:3, 4) - mri.tkrvox2ras(1:3, 4);
    else
        warning('sn2zef:NoCras', ...
            'CRAS fields not present in MRIread output for "%s"; skipping surface-RAS translation.', mgz_path);
        return;
    end

    if verbose
        fprintf('sn2zef: read CRAS from %s -> [%.4f %.4f %.4f]\n', ...
            mgz_path, cras(1), cras(2), cras(3));
    end
end % function
