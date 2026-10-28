classdef ProjectMergeShellTest < matlab.unittest.TestCase
%PROJECTMERGESHELLTEST  Project switch keeps the session shell.

    methods (TestClassSetup)
        function addRuntime(testCase)
            root = i_root();
            addpath(root);
            if isempty(which('zef_merge_project_data'))
                addpath(genpath(fullfile(root, 'src')));
            end
            testCase.assertNotEmpty(which('zef_session_shell_names'));
        end
    end

    methods (Test)
        function mergeDropsPreviousProjectAndKeepsShell(testCase)
            root = i_root();
            zef = struct();
            zef.program_path = root;
            zef.font_size = 12;
            zef.imaging_method_cell = {'Scalar field', 'Vector field', 'Vector field gradient'};
            zef.parameter_profile = {'keep-me'};
            zef.init_profile = {'keep-init'};
            zef.sensors_canonical = false;
            zef.mesh_resolution = 9;
            zef.on_screen = 1;
            zef.L = magic(2);
            zef.only_old_project = 12345;
            zef.oldtag_sigma = 5;
            zef.compartment_tags = {'oldtag'};
            zef.file = 'import.dat';
            zef.file_path = '/tmp';

            incoming = struct( ...
                'L', eye(2), ...
                'project_b_marker', 22, ...
                'oldtag_sigma', 5, ...
                'on_screen', 4, ...
                'sensors_canonical', true);

            out = zef_merge_project_data(zef, incoming);

            testCase.verifyEqual(out.L, eye(2));
            testCase.verifyEqual(out.project_b_marker, 22);
            testCase.verifyFalse(isfield(out, 'only_old_project'));
            testCase.verifyFalse(isfield(out, 'oldtag_sigma'));
            testCase.verifyFalse(isfield(out, 'compartment_tags'));
            testCase.verifyEqual(out.imaging_method_cell, zef.imaging_method_cell);
            testCase.verifyEqual(out.parameter_profile, zef.parameter_profile);
            testCase.verifyEqual(out.init_profile, zef.init_profile);
            testCase.verifyEqual(out.mesh_resolution, 9);
            testCase.verifyEqual(out.on_screen, 1);
            testCase.verifyTrue(out.sensors_canonical);
            testCase.verifyFalse(out.sensors_table_synced);
            testCase.verifyEqual(out.file, 'import.dat');
            testCase.verifyEqual(out.file_path, '/tmp');
        end

        function omittedLeadFieldDoesNotSurvive(testCase)
            zef = struct('font_size', 11, 'program_path', i_root(), 'L', magic(3));
            out = zef_merge_project_data(zef, struct('project_b_marker', 1));
            testCase.verifyFalse(isfield(out, 'L'));
            testCase.verifyEqual(out.project_b_marker, 1);

            filled = zef_fill_missing_defaults(out);
            testCase.verifyTrue(isempty(filled.L));
            testCase.verifyEqual(filled.mesh_resolution, 3);
            testCase.verifyEqual(filled.solver_tolerance, 1e-6);
            testCase.verifyFalse(isfield(filled, 'compartment_tags'));
            testCase.verifyEqual(filled.project_b_marker, 1);
        end

        function fillDoesNotClobberExistingValues(testCase)
            zef = struct('font_size', 14, 'L', magic(4), 'mesh_resolution', 4.5, ...
                'file', 'a.dat', 'file_path', '/data');
            out = zef_fill_missing_defaults(zef);
            testCase.verifyEqual(out.L, magic(4));
            testCase.verifyEqual(out.mesh_resolution, 4.5);
            testCase.verifyEqual(out.file, 'a.dat');
            testCase.verifyEqual(out.file_path, '/data');
            testCase.verifyEqual(out.font_size, 14);
            testCase.verifyEqual(out.n_sources, 10000);
            testCase.verifyEqual(out.source_direction_mode, 2);
            testCase.verifyEqual(out.preconditioner, 2);
        end

        function missingFontSizeErrors(testCase)
            testCase.verifyError(@() zef_fill_missing_defaults(struct('L', 1)), ...
                'zef_fill_missing_defaults:MissingFontSize');
        end

        function listedCompartmentKeepsItsFields(testCase)
            zef = struct('program_path', i_root(), 'font_size', 12, ...
                'compartment_tags', {{'c1', 'oldtag'}}, ...
                'sensor_tags', {{'s'}}, ...
                'c1_sigma', 0.33, 'oldtag_sigma', 9, 's_points', [0 0 0]);
            incoming = struct( ...
                'compartment_tags', {{'c1'}}, ...
                'sensor_tags', {{'s'}}, ...
                'c1_sigma', 0.2, ...
                'oldtag_sigma', 5, ...
                's_points', [1 2 3]);
            out = zef_merge_project_data(zef, incoming);
            testCase.verifyEqual(out.compartment_tags, {'c1'});
            testCase.verifyEqual(out.c1_sigma, 0.2);
            testCase.verifyFalse(isfield(out, 'oldtag_sigma'));
            testCase.verifyEqual(out.s_points, [1 2 3]);
            testCase.verifyFalse(isfield(out, 'n_sources'));
        end

        function systemNamesMatchStrip(testCase)
            root = i_root();
            zef = struct('program_path', root);
            raw = struct( ...
                'L', randn(3, 4), ...
                'gpu_count', 2, ...
                'path_cell', {{'/tmp'}}, ...
                'start_mode', 'display', ...
                'github_updater_current_size', 12, ...
                'use_github', true, ...
                'ui_color_mode', 'dark', ...
                'sensors_table_synced', true, ...
                'save_file', 'keep_me.mat', ...
                'save_file_path', '/tmp');
            stripped = zef_remove_system_fields(zef, raw);
            names = zef_system_field_names(zef, fieldnames(raw));
            removed = setdiff(fieldnames(raw), fieldnames(stripped));
            testCase.verifyEmpty(setdiff(removed, names));
            testCase.verifyFalse(any(strcmp(names, 'save_file')));
            testCase.verifyFalse(any(strcmp(names, 'save_file_path')));
            testCase.verifyTrue(any(strcmp(names, 'font_size')));
            testCase.verifyTrue(any(strcmp(names, 'gpu_count')));
        end

        function liveAxesWinOverStaleFileHandle(testCase)
            fig = figure('Visible', 'off');
            testCase.addTeardown(@() close(fig));
            ax = axes('Parent', fig);
            zef = struct('program_path', i_root(), 'font_size', 12, 'h_axes1', ax);
            incoming = struct('h_axes1', 0, 'L', eye(2));
            out = zef_merge_project_data(zef, incoming);
            testCase.verifyEqual(out.h_axes1, ax);
            testCase.verifyTrue(isvalid(out.h_axes1));
            testCase.verifyEqual(out.L, eye(2));
        end
    end
end

function root = i_root()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
