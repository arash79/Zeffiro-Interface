classdef InverseBundleExtractionTest < matlab.unittest.TestCase
%INVERSEBUNDLEEXTRACTIONTEST  zef_inverse_extract_bundle(..., "dspm") has L, F, procFile.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Synthetic session. The bundle is what utilities.cluster.dispatch_inverse
%   consumes. Asserts fields L, F, procFile, source_positions, and
%   size(F,2) == zef.number_of_frames.
%

    methods (Test)
        function testBundleContainsCoreFields(testCase)
            zef = tests.support.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");

            testCase.verifyTrue(isfield(bundle, "L"));
            testCase.verifyTrue(isfield(bundle, "F"));
            testCase.verifyTrue(isfield(bundle, "procFile"));
            testCase.verifyTrue(isfield(bundle, "source_positions"));
            testCase.verifyEqual(size(bundle.F,2), zef.number_of_frames);
        end
    end

end
