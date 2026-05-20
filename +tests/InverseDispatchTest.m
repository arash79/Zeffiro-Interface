classdef InverseDispatchTest < matlab.unittest.TestCase

    methods (Test)
        function testDispatchClassPath(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "mne");
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(isfield(result, "reconstruction_information"));
            testCase.verifyTrue(~isempty(result.reconstruction));
        end

        function testDispatchLegacyPath(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "legacy_mne");
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(~isempty(result.reconstruction));
        end
    end

end
