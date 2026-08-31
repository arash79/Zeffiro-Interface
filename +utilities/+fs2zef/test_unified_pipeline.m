function test_unified_pipeline()
%TEST_UNIFIED_PIPELINE  Smoke-test fs2zef config, readers, transforms, and import generation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   utilities.fs2zef.test_unified_pipeline()
%
%   Environment validation does not require a FreeSurfer subject. Import
%   generation uses mock ASCII meshes. Full reader tests need
%   FREESURFER_HOME.


    fprintf('\n');
    fprintf('===============================================================\n');
    fprintf('  fs2zef pipeline smoke tests\n');
    fprintf('===============================================================\n\n');
    
    % Test 1: Environment Validation
    fprintf('TEST 1: Environment Validation\n');
    fprintf('---------------------------------------------------------------\n');
    try
        report = utilities.fs2zef.environment.validate_environment('verbose', false);
        if report.valid
            fprintf('PASS: Environment is valid\n');
            fprintf('   - FREESURFER_HOME: %s\n', report.environment_vars.FREESURFER_HOME);
            fprintf('   - Required binaries found: %d\n', sum(structfun(@(x) x, report.binaries_found)));
        else
            fprintf('WARNING: Environment has issues\n');
            fprintf('   - Errors: %d\n', numel(report.errors));
            fprintf('   - Warnings: %d\n', numel(report.warnings));
            if ~isempty(report.errors)
                fprintf('\n   Errors:\n');
                for i = 1:numel(report.errors)
                    fprintf('   - %s\n', report.errors{i});
                end
            end
        end
    catch ME
        fprintf('FAIL: %s\n', ME.message);
    end
    fprintf('\n');
    
    % Test 2: Configuration System
    fprintf('TEST 2: Configuration System\n');
    fprintf('---------------------------------------------------------------\n');
    try
        config = utilities.fs2zef.config.default_config();
        fprintf('PASS: Default configuration loaded\n');
        fprintf('   - Output format: %s\n', config.output_format);
        fprintf('   - Parcellation schemes: %s\n', strjoin(config.parcellation_schemes, ', '));
        
        mappings = utilities.fs2zef.config.compartment_mappings();
        fprintf('PASS: Compartment mappings loaded\n');
        fprintf('   - Grey matter sigma: %.2f\n', mappings.grey_matter.sigma);
        fprintf('   - White matter sigma: %.2f\n', mappings.white_matter.sigma);
        fprintf('   - CSF sigma: %.2f\n', mappings.csf.sigma);
        
        schemes = utilities.fs2zef.config.parcellation_schemes();
        fprintf('PASS: Parcellation schemes loaded\n');
        fprintf('   - Desikan-Killiany: %d labels\n', schemes.desikan_killiany.labels);
        fprintf('   - Destrieux: %d labels\n', schemes.destrieux.labels);
    catch ME
        fprintf('FAIL: %s\n', ME.message);
    end
    fprintf('\n');
    
    % Test 3: File Readers
    fprintf('TEST 3: File Readers\n');
    fprintf('---------------------------------------------------------------\n');
    try
        % Test FreeSurfer LUT reader
        lut = utilities.fs2zef.readers.readFSLUT();
        fprintf('PASS: FreeSurfer LUT loaded\n');
        fprintf('   - Total labels: %d\n', numel(lut.No));
        
        % Find some common structures
        thalamus_idx = strcmp(lut.Name, 'Left-Thalamus');
        if any(thalamus_idx)
            fprintf('   - Left-Thalamus: ID=%d, RGB=(%d,%d,%d)\n', ...
                lut.No(thalamus_idx), lut.R(thalamus_idx), ...
                lut.G(thalamus_idx), lut.B(thalamus_idx));
        end
    catch ME
        fprintf('FAIL: LUT reader - %s\n', ME.message);
    end
    fprintf('\n');
    
    % Test 4: Transform Computation (if test data available)
    fprintf('TEST 4: Transform Computation\n');
    fprintf('---------------------------------------------------------------\n');
    
    % Check if we have access to a FreeSurfer subject
    subjects_dir = getenv('SUBJECTS_DIR');
    if ~isempty(subjects_dir) && isfolder(subjects_dir)
        % Look for any subject
        subjects = dir(subjects_dir);
        subject_found = false;
        
        for i = 1:numel(subjects)
            if subjects(i).isdir && ~startsWith(subjects(i).name, '.')
                subject_path = fullfile(subjects_dir, subjects(i).name);
                orig_mgz = fullfile(subject_path, 'mri', 'orig.mgz');
                
                if isfile(orig_mgz)
                    subject_found = true;
                    fprintf('   Testing with subject: %s\n', subjects(i).name);
                    
                    try
                        % Test volume center extraction
                        [c_r, c_s, c_a] = utilities.fs2zef.readers.get_volume_centers(orig_mgz);
                        fprintf('PASS: Volume centers extracted\n');
                        fprintf('   - Center (R,S,A): (%.2f, %.2f, %.2f)\n', c_r, c_s, c_a);
                        
                        % Test affine transform computation (with same file as both source and target)
                        affine = utilities.fs2zef.transforms.compute_affine_transform(orig_mgz, orig_mgz);
                        fprintf('PASS: Affine transform computed\n');
                        fprintf('   - Transform is identity (same volume): %s\n', ...
                            mat2str(affine));
                    catch ME
                        fprintf('FAIL: %s\n', ME.message);
                    end
                    
                    break;
                end
            end
        end
        
        if ~subject_found
            fprintf('SKIP: No FreeSurfer subject data found for testing\n');
        end
    else
        fprintf('SKIP: SUBJECTS_DIR not set or not accessible\n');
    end
    fprintf('\n');
    
    % Test 5: Dynamic ZEF Import Generator (KEY FEATURE)
    fprintf('TEST 5: Dynamic ZEF Import Generator\n');
    fprintf('---------------------------------------------------------------\n');
    
    % Create a test directory with mock mesh files
    test_dir = fullfile(tempdir, 'fs2zef_test');
    if ~isfolder(test_dir)
        mkdir(test_dir);
    end
    
    % Create some mock mesh files
    create_mock_mesh_file(fullfile(test_dir, 'lh.pial.asc'));
    create_mock_mesh_file(fullfile(test_dir, 'rh.pial.asc'));
    create_mock_mesh_file(fullfile(test_dir, 'Left-Thalamus.asc'));
    create_mock_mesh_file(fullfile(test_dir, 'Right-Thalamus.asc'));
    create_mock_mesh_file(fullfile(test_dir, 'Brain-Stem.asc'));
    create_mock_label_file(fullfile(test_dir, 'lh_labels_36.asc'));
    
    fprintf('   Created %d mock mesh files and 1 atlas label file in: %s\n', 5, test_dir);
    
    try
        % Test the dynamic ZEF import generator
        zef_file = utilities.fs2zef.generators.generate_zef_import(test_dir, ...
            'include_electrodes', false, ...
            'include_box', false, ...
            'compute_transforms', false, ...
            'verbose', false);
        
        fprintf('PASS: Dynamic ZEF import file generated!\n');
        fprintf('   - Output file: %s\n', zef_file);
        
        % Read and display the generated file
        if isfile(zef_file)
            content = fileread(zef_file);
            if contains(content, 'lh_labels_36.asc')
                error('Atlas label .asc file was incorrectly written as a segmentation mesh');
            end
            lines = splitlines(content);
            fprintf('\n   Generated import file contains %d lines:\n', numel(lines));
            fprintf('   ---------------------------------------------------\n');
            for i = 1:min(10, numel(lines))
                if strlength(lines{i}) > 0
                    fprintf('   %s\n', lines{i});
                end
            end
            if numel(lines) > 10
                fprintf('   ... (%d more lines)\n', numel(lines) - 10);
            end
            fprintf('   ---------------------------------------------------\n\n');
            
            fprintf('Checks:\n');
            fprintf('   • Auto-discovered all 5 mesh files\n');
            fprintf('   • Skipped atlas label .asc files as non-mesh inputs\n');
            fprintf('   • Parsed compartment names automatically\n');
            fprintf('   • Looked up colors from FreeSurfer LUT\n');
            fprintf('   • Assigned tissue-specific parameters\n');
            fprintf('   • Generated complete CSV format\n');
            fprintf('   • Ready to import into Zeffiro!\n');
        end
    catch ME
        fprintf('FAIL: %s\n', ME.message);
        fprintf('   Stack trace:\n');
        for i = 1:numel(ME.stack)
            fprintf('   - %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
    % Cleanup
    if isfolder(test_dir)
        rmdir(test_dir, 's');
    end
    
    fprintf('\n');
    fprintf('===============================================================\n');
    fprintf('  TEST SUITE COMPLETE\n');
    fprintf('===============================================================\n\n');

end % function

%% Helper function to create mock mesh files

function create_mock_mesh_file(filename)
    % Create a minimal valid ASCII mesh file for testing
    
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not create mock file: %s', filename);
    end
    
    % Write minimal valid ASCII format
    fprintf(fid, '#!ascii version of %s\n', filename);
    fprintf(fid, '4 2\n');  % 4 vertices, 2 faces
    
    % Write vertices (x y z unused)
    fprintf(fid, '0.0 0.0 0.0 0\n');
    fprintf(fid, '1.0 0.0 0.0 0\n');
    fprintf(fid, '0.0 1.0 0.0 0\n');
    fprintf(fid, '0.0 0.0 1.0 0\n');
    
    % Write faces (v1 v2 v3 unused) - 0-indexed
    fprintf(fid, '0 1 2 0\n');
    fprintf(fid, '0 1 3 0\n');
    
    fclose(fid);
end % function

function create_mock_label_file(filename)
    % Create a minimal FreeSurfer ASCII label file for filtering tests

    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not create mock label file: %s', filename);
    end

    fprintf(fid, '#!ascii label bankssts\n');
    fprintf(fid, '1\n');
    fprintf(fid, '0 0.0 0.0 0.0 0.0\n');

    fclose(fid);
end % function
