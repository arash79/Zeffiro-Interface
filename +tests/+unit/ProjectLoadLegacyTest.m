classdef ProjectLoadLegacyTest < matlab.unittest.TestCase
%PROJECTLOADLEGACYTEST  Single-struct MAT files must not be overwritten.

    methods (Test)
        function testSingleStructMatIsNotRewritten(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            file_name = "legacy_zef.mat";
            payload = struct( ...
                "L", randn(4, 6), ...
                "measurements", randn(4, 3), ...
                "number_of_frames", 3, ...
                "source_direction_mode", 1);
            zef = payload; %#ok<NASGU>
            save(fullfile(folder, file_name), "zef");
            before = whos("-file", fullfile(folder, file_name));
            testCase.verifyEqual({before.name}, {'zef'});

            session = i_nodisplay_session();
            try
                session = zef_load(session, file_name, folder);
            catch ME
                % Init/profile after merge may still throw on a tiny fixture.
                % The contract under test is that the MAT file is intact.
                testCase.verifyNotEqual(ME.identifier, "zef_load:UnsupportedLegacyMat");
            end

            after = whos("-file", fullfile(folder, file_name));
            testCase.verifyEqual({after.name}, {'zef'});
            restored = load(fullfile(folder, file_name), "zef");
            testCase.verifyEqual(restored.zef.L, payload.L);
            testCase.verifyEqual(restored.zef.measurements, payload.measurements);
            if isfield(session, "L")
                testCase.verifyEqual(session.L, payload.L);
            end
        end

        function testSystemFieldsAreStrippedFromSavedStruct(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            zef = struct();
            zef.program_path = root;
            zef_data = struct( ...
                "L", randn(3, 4), ...
                "gpu_count", 2, ...
                "path_cell", {{"/tmp"}}, ...
                "start_mode", "display", ...
                "github_updater_current_size", 12, ...
                "use_github", true, ...
                "ui_color_mode", "dark", ...
                "save_file", "keep_me.mat", ...
                "save_file_path", "/tmp");
            stripped = zef_remove_system_fields(zef, zef_data);
            testCase.verifyFalse(isfield(stripped, "gpu_count"));
            testCase.verifyFalse(isfield(stripped, "path_cell"));
            testCase.verifyFalse(isfield(stripped, "start_mode"));
            testCase.verifyFalse(isfield(stripped, "github_updater_current_size"));
            testCase.verifyFalse(isfield(stripped, "use_github"));
            testCase.verifyFalse(isfield(stripped, "ui_color_mode"));
            testCase.verifyTrue(isfield(stripped, "L"));
            testCase.verifyEqual(stripped.save_file, "keep_me.mat");
            testCase.verifyEqual(stripped.save_file_path, "/tmp");
        end

        function testNonStructSingleVariableErrors(testCase)
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, "s"));
            file_name = "not_a_struct.mat";
            x = 1:10; %#ok<NASGU>
            save(fullfile(folder, file_name), "x");
            session = i_nodisplay_session();
            testCase.verifyError( ...
                @() zef_load(session, file_name, folder), ...
                "zef_load:UnsupportedLegacyMat");
            after = whos("-file", fullfile(folder, file_name));
            testCase.verifyEqual({after.name}, {'x'});
        end
    end
end

function zef = i_nodisplay_session()
zef = struct();
zef.use_display = 0;
zef.start_mode = "nodisplay";
zef.save_file_path = "";
zef.save_file = "";
zef.code_path = fileparts(which("zeffiro_interface"));
zef.program_path = zef.code_path;
zef.sensor_tags = {};
zef.compartment_tags = {};
end
