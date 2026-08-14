classdef InverseFailureModesTest < matlab.unittest.TestCase
%INVERSEFAILUREMODESTEST  Unknown registry id and missing legacy zef error as documented.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   testUnknownMethodFails: zef_inverse_extract_bundle(...,
%   "nonexistent_method") throws utilities.cluster:UnknownInverseMethod.
%   testDispatchWithoutLegacyZefFails: dispatch_inverse on a legacy_csm
%   bundle with legacy_zef removed throws utilities.cluster:MissingLegacyZef.
%

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
