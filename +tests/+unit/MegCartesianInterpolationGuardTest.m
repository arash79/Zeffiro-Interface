classdef MegCartesianInterpolationGuardTest < matlab.unittest.TestCase
%MEGCARTESIANINTERPOLATIONGUARDTEST  St. Venant cartesian MEG must not silently zero L.

    methods (Test)
        function testWhitneyAndHdivAllowed(testCase)
            zef_require_meg_cartesian_interpolation(core.types.ZefSourceModel.Whitney);
            zef_require_meg_cartesian_interpolation(core.types.ZefSourceModel.Hdiv);
            zef_require_meg_cartesian_interpolation(1);
            zef_require_meg_cartesian_interpolation(2);
        end

        function testStVenantErrors(testCase)
            testCase.verifyError( ...
                @() zef_require_meg_cartesian_interpolation(core.types.ZefSourceModel.StVenant), ...
                "zef_lead_field_meg_fem:UnsupportedCartesianSourceModel");
            testCase.verifyError( ...
                @() zef_require_meg_cartesian_interpolation(core.types.ZefSourceModel.ContinuousStVenant), ...
                "zef_lead_field_meg_fem:UnsupportedCartesianSourceModel");
        end

        function testMegFemCallSitesGuardCartesian(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            mag = fileread(fullfile(root, "src", "forward", "lead_field", "zef_lead_field_meg_fem.m"));
            grad = fileread(fullfile(root, "src", "forward", "lead_field", "zef_lead_field_meg_grad_fem.m"));
            testCase.verifyTrue(contains(mag, "zef_require_meg_cartesian_interpolation"));
            testCase.verifyTrue(contains(grad, "zef_require_meg_cartesian_interpolation"));
        end
    end
end
