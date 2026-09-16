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
    end
end
