classdef DropNanSourceColumnsTest < matlab.unittest.TestCase
%DROPNANSOURCECOLUMNSTEST  Interleaved NaN columns drop whole xyz triplets.

    methods (Test)
        function yNanDropsWholeTripletAndKeepsAlignment(testCase)
            L = randn(6, 9);
            L(1, 5) = NaN;
            pos = (1:3).' + [0, 10, 20];
            dir = pos;
            [L2, pos2, dir2] = zef_drop_nan_source_columns(L, pos, dir);
            testCase.verifyEqual(size(L2, 2), 6);
            testCase.verifyEqual(size(pos2, 1), 2);
            testCase.verifyEqual(pos2, pos([1, 3], :));
            testCase.verifyEqual(dir2, dir([1, 3], :));
            testCase.verifyTrue(all(isfinite(L2(:))));
        end

        function scalarColumnsDropIndependently(testCase)
            L = [1 2 NaN 4; 0 1 0 1];
            pos = (1:4).';
            [L2, pos2] = zef_drop_nan_source_columns(L, pos, []);
            testCase.verifyEqual(size(L2, 2), 3);
            testCase.verifyEqual(pos2(:), [1; 2; 4]);
        end

        function finiteLeadFieldUnchanged(testCase)
            L = randn(4, 6);
            pos = randn(2, 3);
            dir = randn(2, 3);
            [L2, pos2, dir2] = zef_drop_nan_source_columns(L, pos, dir);
            testCase.verifyEqual(L2, L);
            testCase.verifyEqual(pos2, pos);
            testCase.verifyEqual(dir2, dir);
        end
    end
end
