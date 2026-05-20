classdef ClassVsLegacyTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.ClassVsLegacyTest — Automated test: ClassVsLegacyTest.
%
% Purpose:
%   Automated test: ClassVsLegacyTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Calls (project):
%   utilities.cluster.dispatch_inverse
%   zef_inverse_extract_bundle
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.ClassVsLegacyTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testCsmClassAndLegacyBothRun(testCase)
            zef = tests.createSyntheticInverseZef();

            class_bundle = zef_inverse_extract_bundle(zef, "dspm");
            class_result = utilities.cluster.dispatch_inverse(class_bundle);

            legacy_bundle = zef_inverse_extract_bundle(zef, "legacy_csm");
            legacy_result = utilities.cluster.dispatch_inverse(legacy_bundle);

            testCase.verifyTrue(~isempty(class_result.reconstruction));
            testCase.verifyTrue(~isempty(legacy_result.reconstruction));
        end
    end

end
