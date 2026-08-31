classdef AnisotropicConductivityGuardTest < matlab.unittest.TestCase
%ANISOTROPICCONDUCTIVITYGUARDTEST  Types 6–10 require sigma(:,3:8).

    methods (Test)
        function missingTensorColumnsError(testCase)
            zef = struct('sigma', rand(8, 2));
            testCase.verifyError(@() zef_require_anisotropic_conductivity(zef), ...
                'zef:MissingAnisotropicConductivity');
        end

        function emptySigmaErrors(testCase)
            zef = struct();
            testCase.verifyError(@() zef_require_anisotropic_conductivity(zef), ...
                'zef:MissingAnisotropicConductivity');
        end

        function eightColumnsPass(testCase)
            zef = struct('sigma', rand(12, 8));
            zef_require_anisotropic_conductivity(zef);
        end
    end
end
