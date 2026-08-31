classdef ArchitectureLayoutTest < matlab.unittest.TestCase
%ARCHITECTURELAYOUTTEST  Guard public entry points against folder drift.
%
%   Checks that which('zef_start') and related names still resolve under
%   src/app, src/gui/chrome, src/forward/lead_field, src/mesh, src/inverse,
%   src/sensors, src/visualization/colormaps, src/io, src/forward/solvers;
%   that inverse.gmm / inverse.kf exist and plugins.ClassGMM / ClassKF do
%   not; and that retired folders tools/plugins, src/core, src/gui/helpers,
%   src/auxiliary, +plugins, and plugins/GithubPusher are absent.

    methods (Test)
        function publicEntryPointsResolveToOwnedFolders(testCase)
            root = fileparts(which('zeffiro_interface'));
            testCase.assumeNotEmpty(root, 'zeffiro_interface is not on the MATLAB path');

            cases = { ...
                'zef_start', fullfile('src', 'app'); ...
                'zef_window_manager', fullfile('src', 'gui', 'chrome'); ...
                'zef_ui_theme', fullfile('src', 'gui', 'chrome'); ...
                'zef_transfer_matrix', fullfile('src', 'forward', 'lead_field'); ...
                'zef_whitney_interpolation', fullfile('src', 'forward', 'lead_field'); ...
                'zef_create_finite_element_mesh', fullfile('src', 'mesh'); ...
                'zef_find_gaussian_prior', fullfile('src', 'inverse'); ...
                'zef_blocked_source_index', fullfile('src', 'inverse'); ...
                'zef_leadfield_column_energy', fullfile('src', 'inverse'); ...
                'zef_cem_electrode', fullfile('src', 'sensors'); ...
                'zef_colormap', fullfile('src', 'visualization', 'colormaps'); ...
                'zef_inv_import', fullfile('src', 'io'); ...
                'pcg_iteration', fullfile('src', 'forward', 'solvers'); ...
                'zef_ui_clamp_position', fullfile('src', 'gui', 'chrome'); ...
                'zef_ui_screen_workarea', fullfile('src', 'gui', 'chrome'); ...
                'zef_sensor_list_items', fullfile('src', 'gui', 'update'); ...
                'zef_require_anisotropic_conductivity', fullfile('src', 'forward', 'lead_field'); ...
                'zef_open_class_inverse', fullfile('src', 'gui', 'open')};

            for i = 1:size(cases, 1)
                name = cases{i, 1};
                expected = cases{i, 2};
                w = which(name);
                testCase.verifyNotEmpty(w, name + " is not on the path");
                testCase.verifyTrue(contains(string(w), expected), ...
                    name + " should live under " + expected + " (found " + string(w) + ")");
            end
        end

        function inverseKernelsArePackagesNotPlugins(testCase)
            testCase.verifyNotEmpty(which('inverse.gmm.FitAdvGMM'));
            testCase.verifyNotEmpty(which('inverse.kf.kf_update'));
            testCase.verifyEmpty(which('plugins.ClassGMM.FitAdvGMM'));
            testCase.verifyEmpty(which('plugins.ClassKF.kf_update'));
        end

        function retiredDirectoriesAreGone(testCase)
            root = fileparts(which('zeffiro_interface'));
            testCase.assumeNotEmpty(root);
            testCase.verifyTrue(isfile(fullfile(root, 'plugins', 'Kalman', 'm', 'zef_KF.m')));
            testCase.verifyFalse(isfolder(fullfile(root, 'plugins', 'GithubPusher')));
            testCase.verifyFalse(isfolder(fullfile(root, 'tools', 'plugins')));
            testCase.verifyFalse(isfolder(fullfile(root, 'src', 'core')));
            testCase.verifyFalse(isfolder(fullfile(root, 'src', 'gui', 'helpers')));
            testCase.verifyFalse(isfolder(fullfile(root, 'src', 'auxiliary')));
            testCase.verifyFalse(isfolder(fullfile(root, '+plugins')));
            testCase.verifyTrue(isfolder(fullfile(root, 'src', 'app')));
            testCase.verifyTrue(isfolder(fullfile(root, 'src', 'gui', 'chrome')));
        end
    end
end
