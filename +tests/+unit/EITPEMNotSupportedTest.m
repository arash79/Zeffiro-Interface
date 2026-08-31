classdef EITPEMNotSupportedTest < matlab.unittest.TestCase
%EITPEMNOTSUPPORTEDTEST  PEM EIT must fail clearly, not on an undefined b.

    methods (Test)
        function testThreeColumnElectrodesError(testCase)
            zef = struct("use_gpu", 0, "gpu_count", 0);
            nodes = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            tetra = [1 2 3 4];
            sigma = {0.33 * ones(1, 1)};
            electrodes = [0.1 0.1 0; 0.9 0.1 0];
            testCase.verifyError( ...
                @() zef_lead_field_eit_fem(zef, nodes, tetra, sigma, electrodes, []), ...
                "zef_lead_field_eit_fem:PEMNotSupported");
        end
    end
end
