classdef ELORETADispatchTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.ELORETADispatchTest — Automated test: ELORETADispatchTest.
%
% Purpose:
%   Automated test: ELORETADispatchTest.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Calls (project):
%   utilities.cluster.dispatch_inverse
%   utilities.cluster.inverse_method_registry
%   zef_inverse_extract_bundle
%   zef_inverse_run
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.ELORETADispatchTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testRegistryResolvesEloreta(testCase)
            method_info = utilities.cluster.inverse_method_registry("eloreta");
            testCase.verifyEqual(method_info.execution_kind, "class");
            testCase.verifyEqual(method_info.class_name, "inverse.ELORETAInverter");
        end

        function testDispatchInverseEloreta(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "eloreta");
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(isfield(result, "reconstruction_information"));
            testCase.verifyTrue(~isempty(result.reconstruction));
        end

        function testZefInverseRunLocal(testCase)
            zef = tests.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "eloreta", "execution", "local");

            testCase.verifyTrue(isfield(zef_out, "reconstruction"));
            testCase.verifyTrue(isfield(zef_out, "reconstruction_information"));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(run_result.success || ~isempty(run_result.reconstruction));
        end

        function testDoesNotBreakDspmDispatch(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(~isempty(result.reconstruction));
        end
    end

end
