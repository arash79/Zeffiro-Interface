function output_info = run(subject_id, segmentation_files, output_dir, options)
%RUN  FreeSurfer volume segmentations → Zeffiro meshes and import script.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   output_info = run(subject_id, segmentation_files, output_dir, options)
%
% Process ANY FreeSurfer segmentation files (.mgz) into Zeffiro-compatible
% formats. Completely file-driven - no assumptions about which compartments
% exist or predefined workflows.
%
% USAGE:
%   output = utilities.fs2zef.run(subject_id, segmentation_files, output_dir)
%
%   % Process standard brain compartments
%   utilities.fs2zef.run('subject01', "aseg.mgz", '/output')
%
%   % Process brain + thalamic nuclei
%   utilities.fs2zef.run('subject01', ["aseg.mgz", "ThalamicNuclei.mgz"], '/output')
%
%   % Process with wmparc instead
%   utilities.fs2zef.run('subject01', ["wmparc.mgz", "ThalamicNuclei.mgz"], '/output')
%
% INPUTS:
%   subject_id          - FreeSurfer subject ID (must exist in $SUBJECTS_DIR)
%   segmentation_files  - String array of .mgz files to process
%                        Examples: "aseg.mgz", ["aseg.mgz", "ThalamicNuclei.mgz"]
%   output_dir          - Output directory for meshes and import file
%
% OPTIONS (name-value pairs):
%   output_format       - 'ascii', 'stl', or 'both' (default: 'both')
%   compute_transforms  - Compute affine transforms for alignment (default: true)
%   reference_volume    - Reference .mgz for transforms (default: 'orig.mgz')
%   include_surfaces    - Include cortical surfaces (lh/rh pial, white) (default: true)
%   electrode_file      - Path to electrode file (default: built-in)
%   merge_left_right    - Merge L/R compartments in import file (default: true)
%                         true: name=base only, merge=0/1; false: name=L/R, merge=0 all
%   verbose             - Print progress (default: true)
%
% OUTPUTS:
%   output_info         - Struct with processing information:
%       .subject_id         - Subject ID processed
%       .segmentation_files - Files processed
%       .output_dir         - Output directory
%       .meshes_created     - List of mesh files created
%       .zef_import_file    - Path to generated import file
%       .warnings           - Any warnings encountered
%       .elapsed_time       - Processing time
%
% WORKFLOW:
%   For each segmentation file:
%     1. Run mri_segstats to discover all labels in the file
%     2. Extract each label as a mesh using mri_mc
%     3. Convert to requested format (ASCII, STL, or both)
%     4. Compute affine transforms if needed
%   
%   Then:
%     5. Generate unified ZEF import file from ALL meshes
%     6. Import with zeffiro_interface(..., 'import_to_new_project', zef_file)
%        or 'import_to_existing_project'
%
% REQUIREMENTS:
%   - FREESURFER_HOME environment variable set
%   - SUBJECTS_DIR environment variable set
%   - FreeSurfer binaries accessible
%
% EXAMPLE:
%   % Set up environment
%   setenv('FREESURFER_HOME', '/usr/local/freesurfer');
%   setenv('SUBJECTS_DIR', '/path/to/subjects');
%
%   % Process standard brain
%   output = utilities.fs2zef.run('subject01', "aseg.mgz", '/output/standard');
%
%   % Process brain with thalamic detail
%   output = utilities.fs2zef.run('subject01', ...
%       ["aseg.mgz", "ThalamicNuclei.v13.T1.FSvoxelSpace.mgz"], ...
%       '/output/detailed', ...
%       'output_format', 'stl', ...
%       'compute_transforms', true);
%
% See also: utilities.fs2zef.generators.generate_zef_import
%

    arguments
        subject_id (1,1) string
        segmentation_files (:,1) string
        output_dir (1,1) string
        options.output_format (1,1) string {mustBeMember(options.output_format, {'ascii', 'stl', 'both'})} = 'both'
        options.compute_transforms (1,1) logical = true
        options.reference_volume (1,1) string = 'orig.mgz'
        options.include_surfaces (1,1) logical = true
        options.electrode_file (1,1) string = ""
        options.merge_left_right (1,1) logical = true
        options.verbose (1,1) logical = true
    end
    
    % Initialize output info
    output_info = struct();
    output_info.subject_id = subject_id;
    output_info.segmentation_files = segmentation_files;
    output_info.output_dir = output_dir;
    output_info.warnings = {};
    start_time = tic;
    
    if options.verbose
        fprintf('\n');
        fprintf('===============================================================\n');
        fprintf('  FreeSurfer to Zeffiro Pipeline\n');
        fprintf('===============================================================\n\n');
    end
    
    %% Step 1: Setup and Validate Environment
    if options.verbose
        fprintf('STEP 1: Setting up environment...\n');
    end
    
    % Set up FreeSurfer environment FIRST (adds binaries to PATH)
    FREESURFER_HOME = getenv('FREESURFER_HOME');
    if isempty(FREESURFER_HOME)
        error('fs2zef:NoFreeSurferHome', 'FREESURFER_HOME environment variable not set');
    end
    
    utilities.fs2zef.environment.setup_freesurfer_env(FREESURFER_HOME, ...
        'verbose', false);
    
    % Now validate that everything is accessible
    report = utilities.fs2zef.environment.validate_environment('verbose', false);
    
    if ~report.valid
        error('fs2zef:InvalidEnvironment', ...
            'Environment validation failed. Errors:\n%s', ...
            strjoin(report.errors, '\n'));
    end
    
    if options.verbose
        fprintf('Environment ready\n\n');
    end
    
    %% Step 2: Validate Inputs
    if options.verbose
        fprintf('STEP 2: Validating inputs...\n');
    end
    
    SUBJECTS_DIR = getenv('SUBJECTS_DIR');
    if isempty(SUBJECTS_DIR)
        error('fs2zef:NoSubjectsDir', 'SUBJECTS_DIR environment variable not set');
    end
    
    subject_path = fullfile(SUBJECTS_DIR, subject_id);
    if ~isfolder(subject_path)
        error('fs2zef:SubjectNotFound', ...
            'Subject not found: %s\nExpected: %s', subject_id, subject_path);
    end
    
    mri_dir = fullfile(subject_path, 'mri');
    if ~isfolder(mri_dir)
        error('fs2zef:NoMRIDir', 'MRI directory not found: %s', mri_dir);
    end
    
    % Validate each segmentation file exists
    for seg_file = segmentation_files'
        seg_path = fullfile(mri_dir, seg_file);
        if ~isfile(seg_path)
            error('fs2zef:SegmentationNotFound', ...
                'Segmentation file not found: %s', seg_path);
        end
    end
    
    % Create output directory
    if ~isfolder(output_dir)
        mkdir(output_dir);
    end
    
    if options.verbose
        fprintf('Subject: %s\n', subject_id);
        fprintf('Segmentation files: %d\n', numel(segmentation_files));
        for i = 1:numel(segmentation_files)
            fprintf('   %d. %s\n', i, segmentation_files(i));
        end
        fprintf('Output: %s\n\n', output_dir);
    end
    
    %% Step 3: Process Each Segmentation File
    if options.verbose
        fprintf('STEP 3: Processing segmentation files...\n');
    end
    
    script_path = fullfile(fileparts(mfilename('fullpath')), '+scripts', 'makeParcellation.sh');
    
    for i = 1:numel(segmentation_files)
        seg_file = segmentation_files(i);
        
        if options.verbose
            fprintf('\n[%d/%d] Processing: %s\n', i, numel(segmentation_files), seg_file);
            fprintf('------------------------------------------------------------\n');
        end
        
        % Run parcellation script
        cmd = sprintf('bash -lc "source %s/SetUpFreeSurfer.sh && bash ''%s'' ''%s'' ''%s'' ''%s''"', ...
            FREESURFER_HOME, script_path, subject_id, seg_file, output_dir);
        
        if options.verbose
            fprintf('Running: %s\n', cmd);
        end
        
        [status, cmdout] = system(cmd);
        
        if status ~= 0
            warning('fs2zef:ScriptFailed', ...
                'Parcellation script failed for %s (exit code %d):\n%s', ...
                seg_file, status, cmdout);
            output_info.warnings{end+1} = sprintf('Failed: %s', seg_file);
        else
            if options.verbose
                fprintf('Completed: %s\n', seg_file);
            end
        end
    end
    
    if options.verbose
        fprintf('\n');
    end
    
    %% Step 4: Process Surfaces (if requested)
    if options.include_surfaces
        if options.verbose
            fprintf('STEP 4: Processing cortical surfaces...\n');
        end
        
        surf_dir = fullfile(subject_path, 'surf');
        if isfolder(surf_dir)
            surfaces = ["lh.pial", "rh.pial", "lh.white", "rh.white"];
            
            for surf = surfaces
                surf_path = fullfile(surf_dir, surf);
                if isfile(surf_path)
                    % Determine output name
                    if contains(surf, 'white')
                        out_name = strrep(surf, '.white', '.wm');
                    else
                        out_name = surf;
                    end
                    
                    % Convert to output format(s)
                    if strcmp(options.output_format, 'ascii') || strcmp(options.output_format, 'both')
                        out_file = fullfile(output_dir, 'ascii', out_name + ".asc");
                        convert_surface(surf_path, out_file);
                    end
                    
                    if strcmp(options.output_format, 'stl') || strcmp(options.output_format, 'both')
                        out_file = fullfile(output_dir, 'mesh', out_name + ".stl");
                        convert_surface(surf_path, out_file);
                    end
                    
                    if options.verbose
                        fprintf('Converted: %s\n', surf);
                    end
                end
            end
            
            if options.verbose
                fprintf('\n');
            end
        else
            output_info.warnings{end+1} = 'No surf/ directory found - skipping surfaces';
        end
    end
    
    %% Step 5: Generate ZEF Import File
    if options.verbose
        fprintf('STEP 5: Generating ZEF import file...\n');
    end
    
    % Determine reference volume for transforms
    if options.compute_transforms
        if strlength(options.reference_volume) == 0
            ref_vol = fullfile(mri_dir, 'orig.mgz');
        else
            ref_vol = fullfile(mri_dir, options.reference_volume);
        end
        
        if ~isfile(ref_vol)
            warning('fs2zef:NoReference', ...
                'Reference volume not found: %s\nSkipping transform computation', ref_vol);
            options.compute_transforms = false;
        end
    end
    
    % Get electrode file
    if strlength(options.electrode_file) == 0
        electrode_file = fullfile(fileparts(mfilename('fullpath')), 'data', 'electrodes.dat');
    else
        electrode_file = options.electrode_file;
    end
    
    % Copy electrode file to subdirectories only
    if isfile(electrode_file)
        ascii_dir = fullfile(output_dir, 'ascii');
        mesh_dir = fullfile(output_dir, 'mesh');
        
        if isfolder(ascii_dir)
            copyfile(electrode_file, fullfile(ascii_dir, 'electrodes.dat'));
        end
        if isfolder(mesh_dir)
            copyfile(electrode_file, fullfile(mesh_dir, 'electrodes.dat'));
        end
    end
    
    % Generate separate ZEF import files for each subdirectory
    output_info.zef_import_file = {};
    
    try
        % ASCII import file
        ascii_dir = fullfile(output_dir, 'ascii');
        if isfolder(ascii_dir)
            if options.verbose
                fprintf('Generating ASCII import file...\n');
            end
            % Construct path prefix for filenames (relative to project root)
            ascii_path_prefix = fullfile('.', output_dir, 'ascii');
            zef_file_ascii = utilities.fs2zef.generators.generate_zef_import(ascii_dir, ...
                'include_electrodes', true, ...
                'include_box', true, ...
                'compute_transforms', options.compute_transforms, ...
                'reference_volume', ref_vol, ...
                'segmentation_volume', fullfile(mri_dir, segmentation_files(end)), ...
                'path_prefix', ascii_path_prefix, ...
                'merge_left_right', options.merge_left_right, ...
                'verbose', false);
            output_info.zef_import_file{end+1} = zef_file_ascii;
            if options.verbose
                fprintf('Generated: %s\n', zef_file_ascii);
            end
        end
        
        % STL/Mesh import file
        mesh_dir = fullfile(output_dir, 'mesh');
        if isfolder(mesh_dir)
            if options.verbose
                fprintf('Generating mesh import file...\n');
            end
            % Construct path prefix for filenames (relative to project root)
            mesh_path_prefix = fullfile('.', output_dir, 'mesh');
            zef_file_mesh = utilities.fs2zef.generators.generate_zef_import(mesh_dir, ...
                'include_electrodes', true, ...
                'include_box', true, ...
                'compute_transforms', options.compute_transforms, ...
                'reference_volume', ref_vol, ...
                'segmentation_volume', fullfile(mri_dir, segmentation_files(end)), ...
                'path_prefix', mesh_path_prefix, ...
                'merge_left_right', options.merge_left_right, ...
                'verbose', false);
            output_info.zef_import_file{end+1} = zef_file_mesh;
            if options.verbose
                fprintf('Generated: %s\n', zef_file_mesh);
            end
        end
        
        if options.verbose
            fprintf('\n');
        end
        
        if isempty(output_info.zef_import_file)
            error('No import files generated');
        end
        
    catch ME
        error('fs2zef:ImportFailed', ...
            'Failed to generate ZEF import file: %s', ME.message);
    end
    
    %% Step 6: Collect Results
    output_info.meshes_created = collect_mesh_files(output_dir);
    output_info.elapsed_time = toc(start_time);
    
    if options.verbose
        fprintf('===============================================================\n');
        fprintf('  PIPELINE COMPLETE\n');
        fprintf('===============================================================\n\n');
        fprintf('SUMMARY:\n');
        fprintf('   Meshes created: %d\n', numel(output_info.meshes_created));
        fprintf('   Warnings: %d\n', numel(output_info.warnings));
        fprintf('   Elapsed time: %.1f seconds\n', output_info.elapsed_time);
        fprintf('\nOUTPUT:\n');
        fprintf('   Directory: %s\n', output_dir);
        if iscell(output_info.zef_import_file)
            fprintf('   Import files:\n');
            for i = 1:numel(output_info.zef_import_file)
                fprintf('      %d. %s\n', i, output_info.zef_import_file{i});
            end
        else
            fprintf('   Import file: %s\n', output_info.zef_import_file);
        end
        fprintf('\nNEXT STEP:\n');
        fprintf('   Import into Zeffiro Interface:\n');
        if iscell(output_info.zef_import_file) && ~isempty(output_info.zef_import_file)
            fprintf('   >> zef = zeffiro_interface(''import_to_new_project'', ''%s'');\n', output_info.zef_import_file{1});
        end
        fprintf('\n');
    end
    
end % function

%% Helper Functions

function convert_surface(input_file, output_file)
    % Convert surface file using mris_convert
    
    % Ensure output directory exists
    [out_dir, ~, ~] = fileparts(output_file);
    if ~isfolder(out_dir)
        mkdir(out_dir);
    end
    
    cmd = sprintf('mris_convert "%s" "%s"', input_file, output_file);
    [status, ~] = system(cmd);
    
    if status ~= 0
        warning('fs2zef:ConvertFailed', 'Failed to convert: %s', input_file);
    end
end

function mesh_files = collect_mesh_files(output_dir)
    % Collect all mesh files created
    
    mesh_files = [];
    
    % Check ASCII directory
    ascii_dir = fullfile(output_dir, 'ascii');
    if isfolder(ascii_dir)
        asc_files = dir(fullfile(ascii_dir, '*.asc'));
        mesh_files = [mesh_files; string({asc_files.name})'];
    end
    
    % Check mesh directory
    mesh_dir = fullfile(output_dir, 'mesh');
    if isfolder(mesh_dir)
        stl_files = dir(fullfile(mesh_dir, '*.stl'));
        mesh_files = [mesh_files; string({stl_files.name})'];
    end
    
    % Check root directory
    root_asc = dir(fullfile(output_dir, '*.asc'));
    root_stl = dir(fullfile(output_dir, '*.stl'));
    mesh_files = [mesh_files; string({root_asc.name})'; string({root_stl.name})'];
    
end
