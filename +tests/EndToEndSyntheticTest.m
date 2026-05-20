classdef EndToEndSyntheticTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.EndToEndSyntheticTest — Automated test: EndToEndSyntheticTest.
%
% Purpose:
%   Automated test: EndToEndSyntheticTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Calls (project):
%   zef_inverse_run
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.EndToEndSyntheticTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testLocalInverseRunPopulatesZef(testCase)
            zef = tests.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "dspm", "execution", "local");

            testCase.verifyTrue(isfield(zef_out, "reconstruction"));
            testCase.verifyTrue(isfield(zef_out, "reconstruction_information"));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(run_result.success || ~isempty(run_result.reconstruction));
        end
    end

end
