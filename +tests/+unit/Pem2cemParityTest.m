classdef Pem2cemParityTest < matlab.unittest.TestCase
%PEM2CEMPARITYTEST  Triangle CEM rows are a no-op; point rows expand.

    methods (Test)
        function testTriangleRowsCopiedUnchanged(testCase)
            tetra = [1 2 3 4; 1 2 3 5];
            ele_ind = [1, 1, 2, 3; 2, 1, 2, 5];
            out = zef_pem2cem(ele_ind, tetra);
            testCase.verifyEqual(out, ele_ind);
        end

        function testPointRowExpandsToSurfaceTriangles(testCase)
            % Two tets sharing face 1-2-3; node 4 is unique to tet 1.
            tetra = [1 2 3 4; 1 2 3 5];
            ele_ind = [1, 4, 1, 0];
            out = zef_pem2cem(ele_ind, tetra);
            testCase.verifyEqual(size(out, 2), 4);
            testCase.verifyTrue(all(out(:,1) == 1));
            testCase.verifyGreaterThanOrEqual(size(out, 1), 1);
            testCase.verifyTrue(all(out(:,4) > 0));
        end

        function testBuriedBarycentricRowsError(testCase)
            tetra = [1 2 3 4; 1 2 3 5];
            ele_ind = [ ...
                1, 1, 0.25, 0; ...
                1, 2, 0.25, 0; ...
                1, 3, 0.25, 0; ...
                1, 4, 0.25, 0];
            testCase.verifyError(@() zef_pem2cem(ele_ind, tetra), "zef_pem2cem:BuriedNotSupported");
        end
    end
end
