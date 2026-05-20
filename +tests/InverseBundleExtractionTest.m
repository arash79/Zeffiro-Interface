classdef InverseBundleExtractionTest < matlab.unittest.TestCase

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
