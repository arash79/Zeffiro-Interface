classdef Fs2zefHeadSurfaceAffineTest < matlab.unittest.TestCase
%FS2ZEFHEADSURFACEAFFINETEST  Scanner-RAS skull/skin rows get t = -CRAS.

    methods (TestClassSetup)
        function addProjectRoot(testCase)
            here = fileparts(mfilename('fullpath'));
            root = fileparts(fileparts(here));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
        end
    end

    methods (Test)
        function translationMatchesNegativeCras(testCase)
            [fs_home, mgz_path] = synthetic_orig(testCase);

            addpath(fullfile(fs_home, 'matlab'));
            mri = MRIread(char(mgz_path));
            expected = eye(4);
            expected(1:3, 4) = -[mri.c_r; mri.c_a; mri.c_s];

            affine = utilities.fs2zef.transforms.compute_ras_center_translation(mgz_path);
            testCase.verifyEqual(affine, expected, 'AbsTol', 1e-8);
            testCase.verifyNotEqual(affine(2, 4), -mri.c_s);
            testCase.verifyEqual(affine(2, 4), -mri.c_a, 'AbsTol', 1e-8);

            sn_affine = utilities.sn2zef.transforms.compute_simnibs_to_freesurfer_translation( ...
                "", mgz_path);
            testCase.verifyEqual(affine, sn_affine, 'AbsTol', 1e-8);
        end

        function importScriptTranslatesOnlyHeadSurfaces(testCase)
            [~, mgz_path, out_dir] = synthetic_orig(testCase);
            write_mesh(fullfile(out_dir, 'inner_skull.asc'));
            write_mesh(fullfile(out_dir, 'outer_skull.stl'));
            write_mesh(fullfile(out_dir, 'outer_skin.asc'));
            write_mesh(fullfile(out_dir, 'lh.pial.asc'));
            write_mesh(fullfile(out_dir, 'CSF.asc'));

            zef_file = utilities.fs2zef.generators.generate_zef_import(out_dir, ...
                'include_electrodes', false, ...
                'include_box', false, ...
                'compute_transforms', false, ...
                'reference_volume', mgz_path, ...
                'verbose', false);

            expected = utilities.fs2zef.transforms.compute_ras_center_translation(mgz_path);
            lines = splitlines(string(fileread(zef_file)));
            lines = lines(strlength(lines) > 0);

            for name = ["inner_skull.asc", "outer_skull.stl", "outer_skin.asc"]
                line = lines(contains(lines, name));
                testCase.verifyEqual(numel(line), 1);
                testCase.verifyEqual(affine_from_line(line), expected, 'AbsTol', 1e-8);
            end

            for name = ["lh.pial.asc", "CSF.asc"]
                line = lines(contains(lines, name));
                testCase.verifyEqual(numel(line), 1);
                testCase.verifyFalse(contains(line, "affine_transform"));
            end
        end
    end
end

function [fs_home, mgz_path, out_dir] = synthetic_orig(testCase)
    fs_home = '/Applications/freesurfer/8.0.0';
    testCase.assumeTrue(isfolder(fullfile(fs_home, 'matlab')), ...
        'FreeSurfer MATLAB toolbox is required to build the synthetic volume.');

    root = tempname;
    mkdir(root);
    testCase.addTeardown(@() rmdir(root, 's'));
    out_dir = root;
    mgz_path = fullfile(root, 'orig.mgz');

    addpath(fullfile(fs_home, 'matlab'));
    env_saved = getenv('FREESURFER_HOME');
    testCase.addTeardown(@() setenv('FREESURFER_HOME', env_saved));
    setenv('FREESURFER_HOME', fs_home);

    vol = zeros(8, 10, 12);
    mri = struct('vol', vol, 'vox2ras0', ...
        [1 0 0 -20; 0 1 0 -30; 0 0 1 -40; 0 0 0 1]);
    err = MRIwrite(mri, mgz_path, 'uchar');
    testCase.verifyEqual(err, 0);
    mgz_path = string(mgz_path);
end

function write_mesh(filename)
    fid = fopen(filename, 'w');
    assert(fid > 0);
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, '#!ascii version of %s\n', filename);
    fprintf(fid, '4 2\n');
    fprintf(fid, '0.0 0.0 0.0 0\n');
    fprintf(fid, '1.0 0.0 0.0 0\n');
    fprintf(fid, '0.0 1.0 0.0 0\n');
    fprintf(fid, '0.0 0.0 1.0 0\n');
    fprintf(fid, '0 1 2 0\n');
    fprintf(fid, '0 1 3 0\n');
end

function affine = affine_from_line(line)
    parts = strsplit(char(line), ',');
    idx = find(strcmp(parts, 'affine_transform'), 1);
    assert(~isempty(idx), 'Row has no affine_transform field.');
    affine = str2num(parts{idx + 1}); %#ok<ST2NM>
end
