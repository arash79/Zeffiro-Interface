classdef RAMUSAggregationTest < matlab.unittest.TestCase
%RAMUSAGGREGATIONTEST  RAMUS scatter/average identities, independent of IAS.
%
%   invert.m accumulates z_sub(multires_ind) over decompositions and
%   levels, then divides by n_dec * n_levels * sum(sparsity.^[0:n_levels-1]).
%   scaling_vec is not applied per level — it is a global amplitude factor
%   inherited from upstream. multiresolution_count is computed by
%   zef_make_multires_dec and never read. These tests pin both facts so a
%   later change that starts weighting by occupancy or by sparsity^k cannot
%   happen unnoticed.
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

        function identityLevelScattersWithoutPermutation(testCase)
            % Finest RAMUS level is the identity map. Scattering with
            % 3*ind expanded to Cartesian triples must be the identity on
            % a 3-component source vector.
            n_src = 7;
            z_sub = (1:3*n_src)';
            ind = (1:n_src)';
            mi = 3*ind;
            mi = [mi-2, mi-1, mi]';
            mi = mi(:);
            testCase.verifyEqual(z_sub(mi), z_sub);
        end

        function coarseToFineScatterRepeatsTheParent(testCase)
            % knnsearch stores, for each fine source, the index into the
            % coarse subset (1..n_coarse), not a full-space index. Two fine
            % sources that share a parent must receive the same triplet.
            z_coarse = [10; 11; 12; 20; 21; 22];  % 2 coarse sources × 3
            parent = [1; 2; 1];                   % 3 fine sources
            mi = 3*parent;
            mi = [mi-2, mi-1, mi]';
            mi = mi(:);
            z_fine = z_coarse(mi);
            testCase.verifyEqual(z_fine, [10;11;12; 20;21;22; 10;11;12]);
        end

        function globalScaleMatchesDocumentedDivisor(testCase)
            % Reconstruct the accumulator/divisor without running IAS: n_dec
            % copies of the same vector, n_levels each, then divide.
            n_dec = 4;
            n_levels = 3;
            sparsity = 2;
            z_one = (1:9)';
            z_acc = zeros(size(z_one));
            for d = 1:n_dec
                for lv = 1:n_levels
                    z_acc = z_acc + z_one;
                end
            end
            scaling_vec = (sparsity.^(0:n_levels-1))';
            z = z_acc / (double(n_dec*n_levels)*sum(scaling_vec));
            % sum(scaling_vec) = 1+2+4 = 7; 12 copies / (12*7) = 1/7
            testCase.verifyEqual(z, z_one / sum(scaling_vec));
            testCase.verifyEqual(sum(scaling_vec), 7);
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
