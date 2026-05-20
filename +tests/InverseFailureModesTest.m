classdef InverseFailureModesTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.InverseFailureModesTest — Automated test: InverseFailureModesTest.
%
% Purpose:
%   Automated test: InverseFailureModesTest.
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
%   Programmatic: `tests.InverseFailureModesTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testUnknownMethodFails(testCase)
            zef = tests.createSyntheticInverseZef();
            testCase.verifyError( ...
                @() zef_inverse_extract_bundle(zef, "nonexistent_method"), ...
                "utilities.cluster:UnknownInverseMethod" ...
            );
        end

        function testDispatchWithoutLegacyZefFails(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "legacy_csm");
            bundle = rmfield(bundle, "legacy_zef");
            testCase.verifyError( ...
                @() utilities.cluster.dispatch_inverse(bundle), ...
                "utilities.cluster:MissingLegacyZef" ...
            );
        end
    end

end
