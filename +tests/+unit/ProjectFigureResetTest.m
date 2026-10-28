classdef ProjectFigureResetTest < matlab.unittest.TestCase
%PROJECTFIGURERESETTEST  Opening a project drops the previous project.

    methods (Test)
        function switchClearsPayloadAndLogoCamera(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            first = struct("L", magic(4), "project_a_marker", 11, ...
                "oldtag_sigma", 5, "update_zoom", 2.5, "number_of_frames", 1);
            second = struct("L", eye(3), "project_b_marker", 22, ...
                "update_zoom", 3.5, "number_of_frames", 2);
            save(fullfile(folder, "project_a.mat"), "-struct", "first", "-v7.3");
            save(fullfile(folder, "project_b.mat"), "-struct", "second", "-v7.3");

            session = zeffiro_interface( ...
                "start_mode", "nodisplay", ...
                "use_gpu", false, ...
                "skip_submodules", true, ...
                "zeffiro_restart", true);
            testCase.addTeardown(@() i_close_session(session));
            testCase.assertTrue(isgraphics(session.h_axes1) && isvalid(session.h_axes1));
            testCase.assertTrue(isgraphics(session.h_zeffiro) && isvalid(session.h_zeffiro));
            shell = session.h_zeffiro;

            session.only_old_project = 12345;
            session.compartment_tags = {'oldtag'};
            session.oldtag_sigma = 9;
            patch(session.h_axes1, [0 1 0], [0 0 1], [0 0 0], [1 0 0], ...
                'Tag', 'stale_mesh');
            session.h_axes1.CameraViewAngle = 2;

            session = zef_load(session, "project_a.mat", folder);
            i_assert_logo(testCase, session, shell);
            testCase.verifyEqual(session.project_a_marker, 11);
            testCase.verifyEqual(session.L, first.L);
            testCase.verifyFalse(isfield(session, "only_old_project"));
            testCase.verifyFalse(isfield(session, "oldtag_sigma"));
            testCase.verifyEqual(session.on_screen, 0);
            testCase.verifyNotEqual(session.h_axes1.CameraViewAngleMode, 'manual');

            patch(session.h_axes1, [0 1 0], [0 0 1], [1 1 0], [0 0 1], ...
                'Tag', 'stale_mesh');
            session.h_axes1.CameraViewAngle = 1.5;
            session = zef_load(session, "project_b.mat", folder);
            i_assert_logo(testCase, session, shell);
            testCase.verifyEqual(session.project_b_marker, 22);
            testCase.verifyEqual(session.L, second.L);
            testCase.verifyFalse(isfield(session, "project_a_marker"));
            testCase.verifyFalse(isfield(session, "only_old_project"));
            testCase.verifyGreaterThan(session.h_axes1.CameraViewAngle, 4);
            testCase.verifyEmpty(findall(session.h_axes1, 'Tag', 'stale_mesh'));

            session = zef_load(session, "project_a.mat", folder);
            i_assert_logo(testCase, session, shell);
            testCase.verifyEqual(session.project_a_marker, 11);
            testCase.verifyFalse(isfield(session, "project_b_marker"));
            testCase.verifyEqual(session.L, first.L);
        end
    end
end

function i_assert_logo(testCase, session, shell)

testCase.verifyTrue(isgraphics(session.h_zeffiro) && isvalid(session.h_zeffiro));
testCase.verifyEqual(session.h_zeffiro, shell);
testCase.verifyEqual(session.h_axes1.CameraViewAngleMode, 'auto');
logo = findall(session.h_axes1, 'Tag', 'zef_logo_img');
testCase.verifyNotEmpty(logo);
testCase.verifyEmpty(findall(session.h_axes1, 'Type', 'patch'));
testCase.verifyEmpty(findall(session.h_axes1, 'Type', 'light'));

end

function i_close_session(zef)
try
    zef.zeffiro_restart = 1;
    zef_close_all(zef);
catch
end
end
