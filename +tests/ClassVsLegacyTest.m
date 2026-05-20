classdef ClassVsLegacyTest < matlab.unittest.TestCase

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
