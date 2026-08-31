classdef ImportConfinedScriptTest < matlab.unittest.TestCase
%IMPORTCONFINEDSCRIPTTEST  .zef script rows cannot escape the import folder.

    methods (Test)
        function runsScriptUnderAllowedRoot(testCase)
            root = tempname;
            mkdir(root);
            testCase.addTeardown(@() rmdir(root, "s"));
            script_path = fullfile(root, "ok_script.m");
            fid = fopen(script_path, "w");
            fprintf(fid, "confined_script_token = 17;\n");
            fclose(fid);
            zef_run_confined_script(script_path, root);
            testCase.verifyEqual(confined_script_token, 17);
        end

        function refusesScriptOutsideAllowedRoot(testCase)
            root = tempname;
            mkdir(root);
            other = tempname;
            mkdir(other);
            testCase.addTeardown(@() rmdir(root, "s"));
            testCase.addTeardown(@() rmdir(other, "s"));
            script_path = fullfile(other, "evil.m");
            fid = fopen(script_path, "w");
            fprintf(fid, "x = 1;\n");
            fclose(fid);
            testCase.verifyError( ...
                @() zef_run_confined_script(script_path, root), ...
                "Zeffiro:Import:ScriptOutsideImportRoot");
        end
    end
end
