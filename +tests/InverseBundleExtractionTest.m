classdef InverseBundleExtractionTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.InverseBundleExtractionTest — Automated test: InverseBundleExtractionTest.
%
% Purpose:
%   Automated test: InverseBundleExtractionTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Zef fields (observed):
%   zef.number_of_frames (read)
%
% Calls (project):
%   zef_inverse_extract_bundle
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.InverseBundleExtractionTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testBundleContainsCoreFields(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");

            testCase.verifyTrue(isfield(bundle, "L"));
            testCase.verifyTrue(isfield(bundle, "F"));
            testCase.verifyTrue(isfield(bundle, "procFile"));
            testCase.verifyTrue(isfield(bundle, "source_positions"));
            testCase.verifyEqual(size(bundle.F,2), zef.number_of_frames);
        end
    end

end
