classdef PemReferenceLoadTest < matlab.unittest.TestCase
%PEMREFERENCELOADTEST  Infinite-Z PEM zeros electrode 1 only, not the block.

    methods (Test)
        function testOnlyElectrodeOneInFirstBlockIsZeroed(testCase)
            b = ones(5, 4);
            block_ind = 1:4;
            out = zef_pem_zero_reference_loads(b, block_ind, "PEM", 1);
            testCase.verifyEqual(out(:, 1), zeros(5, 1));
            testCase.verifyEqual(out(:, 2:4), ones(5, 3));
        end

        function testLaterBlocksUnchanged(testCase)
            b = randn(6, 3);
            out = zef_pem_zero_reference_loads(b, 51:53, "PEM", 1);
            testCase.verifyEqual(out, b);
        end

        function testCemAndFiniteZAreNoops(testCase)
            b = randn(4, 2);
            testCase.verifyEqual( ...
                zef_pem_zero_reference_loads(b, 1:2, "CEM", 1), b);
            testCase.verifyEqual( ...
                zef_pem_zero_reference_loads(b, 1:2, "PEM", 0), b);
        end

        function testScalarGpuStyleIndex(testCase)
            b = (1:8)';
            out = zef_pem_zero_reference_loads(b, 1, "PEM", 1);
            testCase.verifyEqual(out, zeros(8, 1));
            out2 = zef_pem_zero_reference_loads(b, 2, "PEM", 1);
            testCase.verifyEqual(out2, b);
        end
    end
end
