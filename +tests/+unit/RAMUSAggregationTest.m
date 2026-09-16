classdef RAMUSAggregationTest < matlab.unittest.TestCase
%RAMUSAGGREGATIONTEST  RAMUS invert requires a decomposition; method_type split.
%
%   invert.m errors with NoMultiresDec when the lattice is empty.
%   method_type "sLORETA each step" exists on RAMUSInverter and not on
%   IASInverter. Scatter/average arithmetic is covered by RAMUSInverterOptTest.
%
%   See also inverse.RAMUSInverter/invert, zef_make_multires_dec.

    methods (Test)
        function emptyDecompositionThrowsIdentifiedError(testCase)
            inv = inverse.RAMUSInverter();
            L = randn(6, 12);
            f = randn(6, 1);
            testCase.verifyError( ...
                @() inv.invert(f, L, struct(), 1, [], "use_gpu", false), ...
                "inverse:RAMUSInverter:NoMultiresDec");
        end

        function methodTypeIncludesSLoretaEachStep(testCase)
            % IASInverter does not offer sLORETA-each-step; RAMUS does.
            % Pin that split so the two classes cannot be "aligned" by
            % deleting the RAMUS option.
            inv = inverse.RAMUSInverter("method_type", "sLORETA each step");
            testCase.verifyEqual(inv.method_type, "sLORETA each step");
            ias = inverse.IASInverter();
            testCase.verifyError(@() setIasSLoretaEach(ias), ...
                "MATLAB:validators:mustBeMember");

            function setIasSLoretaEach(obj)
                obj.method_type = "sLORETA each step";
            end
        end
    end
end
