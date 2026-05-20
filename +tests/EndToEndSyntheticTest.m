classdef EndToEndSyntheticTest < matlab.unittest.TestCase

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
