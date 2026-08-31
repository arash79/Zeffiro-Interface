classdef EndToEndSyntheticTest < matlab.unittest.TestCase
%ENDTOENDSYNTHETICTEST  zef_inverse_run(..., "dspm", "execution", "local") writes zef.reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Full class-track entry (not Inverse-tools). Synthetic L from
%   tests.support.createSyntheticInverseZef. Asserts zef_out.reconstruction and
%   reconstruction_information are nonempty, and run_result.reconstruction
%   is nonempty (local dispatch does not set a .success flag).
%

    methods (Test)
        function testLocalInverseRunPopulatesZef(testCase)
            zef = tests.support.createSyntheticInverseZef();
            [zef_out, run_result] = zef_inverse_run(zef, "dspm", "execution", "local");

            testCase.verifyTrue(isfield(zef_out, "reconstruction"));
            testCase.verifyTrue(isfield(zef_out, "reconstruction_information"));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(~isempty(run_result.reconstruction));
        end
    end

end
