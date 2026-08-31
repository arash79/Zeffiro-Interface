classdef ClassVsLegacyTest < matlab.unittest.TestCase
%CLASSVSLEGACYTEST  dSPM class inverter and legacy CSM plugin both return a reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Synthetic zef from tests.support.createSyntheticInverseZef (tiny random L).
%   Dispatches registry id "dspm" (inverse.CSMInverter) and "legacy_csm"
%   (plugins CSM iteration) via utilities.cluster.dispatch_inverse.
%   Asserts both result.reconstruction are nonempty. Does not compare
%   numerical equality of the two tracks.
%

    methods (Test)
        function testCsmClassAndLegacyBothRun(testCase)
            zef = tests.support.createSyntheticInverseZef();

            class_bundle = zef_inverse_extract_bundle(zef, "dspm");
            class_result = utilities.cluster.dispatch_inverse(class_bundle);

            legacy_bundle = zef_inverse_extract_bundle(zef, "legacy_csm");
            legacy_result = utilities.cluster.dispatch_inverse(legacy_bundle);

            testCase.verifyTrue(~isempty(class_result.reconstruction));
            testCase.verifyTrue(~isempty(legacy_result.reconstruction));
        end
    end

end
