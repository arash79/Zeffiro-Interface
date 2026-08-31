classdef EITGradientProductTest < matlab.unittest.TestCase
%EITGRADIENTPRODUCTTEST  D_A is ∫∇ψi·∇ψj, not extra off-diagonal products.

    methods (Test)
        function testUnitTetMatchesAnalyticHats(testCase)
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            D_A = zef_p1_unweighted_gradient_products(nodes, tetra, 1);
            G = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];
            A_ref = (G * G') * (1/6);
            packed = i_pack_upper(A_ref);
            testCase.verifyLessThanOrEqual(max(abs(D_A - packed)), 1e-12);
        end

        function testOffDiagonalConductivityDoesNotEnterDA(testCase)
            nodes = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            tetra = [1 2 3 4];
            D_A = zef_p1_unweighted_gradient_products(nodes, tetra, 1);
            G = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];
            % The inherited k=4,5,6 junk added a_i^x a_j^y + a_i^x a_j^z +
            % a_i^y a_j^z without transpose. On this tet that is not the
            % isotropic inner product.
            A_iso = (G * G') * (1/6);
            extra = zeros(4);
            a = [1 0 0; 0 1 0; 0 0 1; -1 -1 -1];
            for i = 1:4
                for j = i:4
                    extra(i, j) = (a(i, 1)*a(j, 2) + a(i, 1)*a(j, 3) + a(i, 2)*a(j, 3)) / 6;
                    extra(j, i) = extra(i, j);
                end
            end
            A_wrong = A_iso + extra;
            packed_wrong = i_pack_upper(A_wrong);
            testCase.verifyGreaterThan(max(abs(D_A - packed_wrong)), 1e-6);
        end
    end
end

function packed = i_pack_upper(A)
packed = [A(1,1), A(1,2), A(1,3), A(1,4), ...
    A(2,2), A(2,3), A(2,4), A(3,3), A(3,4), A(4,4)];
end
