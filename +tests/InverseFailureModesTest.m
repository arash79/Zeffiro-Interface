classdef InverseFailureModesTest < matlab.unittest.TestCase

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
