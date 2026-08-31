classdef ELORETADispatchTest < matlab.unittest.TestCase
%ELORETADISPATCHTEST  Registry id eloreta is class ELORETAInverter; local zef_inverse_run fills reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Synthetic zef. Asserts inverse_method_registry("eloreta") has
%   execution_kind "class" and class_name inverse.ELORETAInverter;
%   dispatch_inverse and zef_inverse_run(..., "eloreta", "execution",
%   "local") write reconstruction; dspm dispatch still works afterward.
%

    methods (Test)
        function testRegistryResolvesEloreta(testCase)
            method_info = utilities.cluster.inverse_method_registry("eloreta");
            testCase.verifyEqual(method_info.execution_kind, "class");
            testCase.verifyEqual(method_info.class_name, "inverse.ELORETAInverter");
        end

        function testDispatchInverseEloreta(testCase)
            zef = tests.support.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "eloreta");
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(isfield(result, "reconstruction_information"));
            testCase.verifyTrue(~isempty(result.reconstruction));
        end

        function testZefInverseRunLocal(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "eloreta", "execution", "local");

            testCase.verifyTrue(isfield(zef_out, "reconstruction"));
            testCase.verifyTrue(isfield(zef_out, "reconstruction_information"));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(~isempty(run_result.reconstruction));
        end

        function testDoesNotBreakDspmDispatch(testCase)
            zef = tests.support.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(~isempty(result.reconstruction));
        end
    end

end
