classdef ProjectSaveExportTest < matlab.unittest.TestCase
%PROJECTSAVEEXPORTTEST  Headless lead-field export writes L and leaves it intact.

    methods (Test)
        function exportLeadFieldWritesLWithoutDialog(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            zef = struct();
            zef.use_display = false;
            zef.L = [1 2 3; 4 5 6];
            zef_save(zef, 'lead.mat', folder, 2);
            restored = load(fullfile(folder, "lead.mat"));
            testCase.verifyEqual(restored.L, zef.L);
        end

        function objectHandlesAreStrippedFromSavedCopy(testCase)
            zef = struct();
            zef.L = magic(3);
            fig = figure("Visible", "off");
            testCase.addTeardown(@() delete(fig));
            zef.h_fig = fig;
            stripped = zef_remove_object_handles(zef);
            testCase.verifyTrue(isfield(stripped, "L"));
            testCase.verifyEqual(stripped.L, zef.L);
            testCase.verifyFalse(isfield(stripped, "h_fig"));
        end

        function projectSaveLoadRoundTripKeepsLeadField(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            session = zeffiro_interface( ...
                "start_mode", "nodisplay", ...
                "use_gpu", false, ...
                "skip_submodules", true, ...
                "zeffiro_restart", true);
            testCase.addTeardown(@() i_close_session(session));
            session.L = [1 2 3; 4 5 6; 7 8 9];
            session.measurements = (1:3)';
            zef_data = zef_remove_object_handles(session);
            zef_data = zef_remove_system_fields(session, zef_data);
            save(fullfile(folder, "roundtrip.mat"), "-struct", "zef_data", "-v7.3");
            loaded = zef_load(session, "roundtrip.mat", folder);
            testCase.verifyEqual(loaded.L, session.L);
            testCase.verifyEqual(loaded.measurements, session.measurements);
        end
    end
end

function i_close_session(zef)
try
    zef.zeffiro_restart = 1;
    zef_close_all(zef);
catch
end
end
