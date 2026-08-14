classdef InverseDispatchTest < matlab.unittest.TestCase
%INVERSEDISPATCHTEST  Registry ids mne and legacy_mne both produce reconstructions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Synthetic session via tests.createSyntheticInverseZef.
%   testDispatchClassPath: zef_inverse_extract_bundle(..., "mne") then
%   dispatch_inverse — class inverse.MNEInverter.
%   testDispatchLegacyPath: id "legacy_mne" — plugin zef_find_mne_reconstruction.
%   Asserts result.reconstruction (and information on the class path) exist
%   and are nonempty.
%

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
