classdef Sn2zefRunAlignmentTest < matlab.unittest.TestCase
%SN2ZEFRUNALIGNMENTTEST  sn2zef.run alignment option and .zef affine contract.

    methods (TestClassSetup)
        function addProjectRoot(testCase)
            here = fileparts(mfilename('fullpath'));
            root = fileparts(fileparts(here));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'src'), 'IncludingSubfolders', true));
        end
    end

    methods (Test)
        function badAlignmentModeErrorsBeforeIo(testCase)
            zef = struct();
            testCase.verifyError(@() utilities.sn2zef.run( ...
                zef, 'x', tempname, 0, struct('alignment_mode', 'scanner')), ...
                'sn2zef:BadAlignmentMode');
        end

        function conflictingAlignmentOptionsError(testCase)
            zef = struct();
            opts = struct('alignment_mode', 'translation', 'force_coreg', true);
            testCase.verifyError(@() utilities.sn2zef.run( ...
                zef, 'x', tempname, 0, opts), 'sn2zef:AmbiguousAlignment');
        end

        function defaultRunWritesTranslationAffine(testCase)
            fs_home = '/Applications/freesurfer/8.0.0';
            testCase.assumeTrue(isfolder(fullfile(fs_home, 'matlab')), ...
                'FreeSurfer MATLAB toolbox is required to build the synthetic volumes.');

            root = tempname;
            mkdir(root);
            testCase.addTeardown(@() rmdir(root, 's'));

            subject_id = 'TinySN';
            m2m = fullfile(root, 'simnibs', ['m2m_' subject_id]);
            fs_subject = fullfile(root, 'subjects', subject_id, 'mri');
            out_folder = fullfile(root, 'out');
            mkdir(m2m);
            mkdir(fs_subject);

            addpath(fullfile(fs_home, 'matlab'));
            vol = zeros(12, 12, 12);
            vol(4:9, 4:9, 4:9) = 1;
            vol(6:8, 6:8, 6:8) = 2;
            sim = struct('vol', vol, 'vox2ras0', ...
                [1 0 0 -20; 0 1 0 -30; 0 0 1 -40; 0 0 0 1]);
            fs = struct('vol', vol, 'vox2ras0', ...
                [0 -1 0 5; 1 0 0 -8; 0 0 1 3; 0 0 0 1]);
            err_sim = MRIwrite(sim, fullfile(m2m, 'final_tissues.nii.gz'), 'uchar');
            err_fs = MRIwrite(fs, fullfile(fs_subject, 'orig.mgz'), 'uchar');
            testCase.verifyEqual(err_sim, 0);
            testCase.verifyEqual(err_fs, 0);

            fid = fopen(fullfile(m2m, 'final_tissues_LUT.txt'), 'w');
            testCase.assertGreaterThan(fid, 0);
            cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
            fprintf(fid, '1 White_Matter 230 230 230 255\n');
            fprintf(fid, '2 Gray_Matter 129 129 129 255\n');
            clear cleaner;

            env_names = {'SIMNIBS_HOME', 'SUBJECTS_DIR', 'FREESURFER_HOME'};
            env_saved = cellfun(@getenv, env_names, 'UniformOutput', false);
            testCase.addTeardown(@() restore_env(env_names, env_saved));
            setenv('SIMNIBS_HOME', fullfile(root, 'simnibs'));
            setenv('SUBJECTS_DIR', fullfile(root, 'subjects'));
            setenv('FREESURFER_HOME', fs_home);

            utilities.sn2zef.run(struct(), subject_id, out_folder, 0);

            zef_path = fullfile(out_folder, 'import_segmentations.zef');
            testCase.verifyTrue(isfile(zef_path));
            testCase.verifyTrue(isfile(fullfile(out_folder, 'White_Matter.stl')));
            testCase.verifyTrue(isfile(fullfile(out_folder, 'Gray_Matter.stl')));
            testCase.verifyTrue(isfile(fullfile(out_folder, 'sn_atlas_points.dat')));

            manifest = readcell(zef_path, 'FileType', 'text', 'Delimiter', ',');
            affine = affine_from_manifest(manifest);
            testCase.verifySize(affine, [4 4]);
            testCase.verifyTrue(all(isfinite(affine(:))));

            expected = utilities.sn2zef.transforms.compute_simnibs_to_freesurfer_translation( ...
                fullfile(m2m, 'final_tissues.nii.gz'), ...
                fullfile(fs_subject, 'orig.mgz'));
            testCase.verifyEqual(affine, expected, 'AbsTol', 1e-8);
            assert_shared_affine(testCase, manifest, expected);

            here = fileparts(mfilename('fullpath'));
            project_root = fileparts(fileparts(here));
            source_electrodes = fullfile(project_root, '+utilities', '+fs2zef', 'data', 'electrodes.dat');
            copied_electrodes = fullfile(out_folder, 'electrodes.dat');
            testCase.verifyTrue(isfile(copied_electrodes));
            testCase.verifyEqual(fileread(copied_electrodes), fileread(source_electrodes));

            electrodes = readmatrix(copied_electrodes);
            head = stlread(fullfile(out_folder, 'White_Matter.stl'));
            assert_same_affine_frame(testCase, electrodes, head.Points, expected);

            legacy_out = fullfile(root, 'out_legacy');
            utilities.sn2zef.run(struct(), subject_id, legacy_out, 0, ...
                struct('force_coreg', false, 'include_atlas', false));
            legacy_manifest = readcell(fullfile(legacy_out, 'import_segmentations.zef'), ...
                'FileType', 'text', 'Delimiter', ',');
            legacy_affine = affine_from_manifest(legacy_manifest);
            testCase.verifyEqual(legacy_affine, expected, 'AbsTol', 1e-8);
            assert_shared_affine(testCase, legacy_manifest, expected);
            assert_same_affine_frame(testCase, electrodes, head.Points, legacy_affine);
        end
    end
end

function restore_env(names, saved)
    for k = 1:numel(names)
        setenv(names{k}, saved{k});
    end
end

function affine = affine_from_manifest(manifest)
    affines = affines_from_manifest(manifest);
    if isempty(affines)
        error('Sn2zefRunAlignmentTest:NoAffine', ...
            'import_segmentations.zef has no affine_transform field.');
    end
    affine = affines{1};
end

function assert_shared_affine(testCase, manifest, expected)
    affines = affines_from_manifest(manifest);
    testCase.verifyGreaterThanOrEqual(numel(affines), 2);
    for k = 1:numel(affines)
        testCase.verifyEqual(affines{k}, expected, 'AbsTol', 1e-8);
    end
    testCase.verifyTrue(row_has_token(manifest, 1, 'sensors'));
    testCase.verifyTrue(row_has_token(manifest, 1, 'affine_transform'));
end

function assert_same_affine_frame(testCase, electrodes, vertices, affine)
    % zef_process_meshes applies one homogeneous product to compartment
    % vertices and to electrode rows. A point that starts on the head must
    % still lie on the transformed head, and the copied electrode file must
    % still be the untransformed coordinates.
    electrodes_t = apply_mesh_affine(electrodes, affine);
    vertices_t = apply_mesh_affine(vertices, affine);
    shift = affine(1:3, 4).';

    testCase.verifyEqual(electrodes_t - electrodes, repmat(shift, size(electrodes, 1), 1), ...
        'AbsTol', 1e-8);
    testCase.verifyEqual(vertices_t - vertices, repmat(shift, size(vertices, 1), 1), ...
        'AbsTol', 1e-6);

    parked = vertices(1, :);
    testCase.verifyEqual(apply_mesh_affine(parked, affine), vertices_t(1, :), ...
        'AbsTol', 1e-6);

    baked = apply_mesh_affine(electrodes, affine);
    if norm(affine - eye(4), 'fro') > 1e-8
        testCase.verifyGreaterThan(max(abs(electrodes(:) - baked(:))), 1e-6);
    end
end

function points_t = apply_mesh_affine(points, affine)
    % Same product as zef_process_meshes: homogeneous rows times A'.
    homogeneous = [points, ones(size(points, 1), 1)];
    points_t = homogeneous * affine.';
    points_t = points_t(:, 1:3);
end

function affines = affines_from_manifest(manifest)
    affines = {};
    for row = 1:size(manifest, 1)
        for col = 1:size(manifest, 2) - 1
            token = manifest{row, col};
            if isstring(token)
                token = char(token);
            end
            if ischar(token) && strcmp(token, 'affine_transform')
                affines{end + 1} = parse_affine_value(manifest{row, col + 1}); %#ok<AGROW>
            end
        end
    end
end

function found = row_has_token(manifest, row, name)
    found = false;
    for col = 1:size(manifest, 2)
        token = manifest{row, col};
        if isstring(token)
            token = char(token);
        end
        if ischar(token) && strcmp(token, name)
            found = true;
            return;
        end
    end
end

function affine = parse_affine_value(value)
    if isstring(value)
        value = char(value);
    end
    if isnumeric(value)
        affine = value;
    else
        affine = str2num(value); %#ok<ST2NM>
    end
end
