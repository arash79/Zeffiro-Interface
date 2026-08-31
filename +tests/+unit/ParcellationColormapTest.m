classdef ParcellationColormapTest < matlab.unittest.TestCase
%PARCELLATIONCOLORMAPTEST  zef_parcellation_colormap missing-field guard.

    methods (Test)
        function testMissingFieldReturnsEmpty(testCase)
            [restore, had_zef] = i_snapshot_base_zef();
            testCase.addTeardown(@() i_restore_base_zef(restore, had_zef));
            assignin("base", "zef", struct("foo", 1));
            cmap = zef_parcellation_colormap();
            testCase.verifyEmpty(cmap);
        end

        function testPresentFieldIsReturned(testCase)
            [restore, had_zef] = i_snapshot_base_zef();
            testCase.addTeardown(@() i_restore_base_zef(restore, had_zef));
            expected = [0.1 0.2 0.3; 0.4 0.5 0.6];
            assignin("base", "zef", struct("parcellation_colormap", expected));
            cmap = zef_parcellation_colormap();
            testCase.verifyEqual(cmap, expected);
        end
    end
end

function [restore, had_zef] = i_snapshot_base_zef()
had_zef = evalin("base", "exist('zef','var')") == 1;
restore = [];
if had_zef
    restore = evalin("base", "zef");
end
end

function i_restore_base_zef(restore, had_zef)
if had_zef
    assignin("base", "zef", restore);
else
    evalin("base", "clear zef");
end
end
