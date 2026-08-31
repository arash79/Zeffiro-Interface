classdef WindowPlacementTest < matlab.unittest.TestCase
%WINDOWPLACEMENTTEST  Clamp and centre helpers keep windows on the work area.

    methods (Test)
        function clampPullsOffScreenOriginInside(testCase)
            work = [0 0 1920 1080];
            pos = zef_ui_clamp_position([-400 2000 1200 800], work);
            testCase.verifyGreaterThanOrEqual(pos(1), work(1));
            testCase.verifyGreaterThanOrEqual(pos(2), work(2));
            testCase.verifyLessThanOrEqual(pos(1) + pos(3), work(1) + work(3));
            testCase.verifyLessThanOrEqual(pos(2) + pos(4), work(2) + work(4));
        end

        function clampShrinksOversizedWindow(testCase)
            work = [0 0 1366 768];
            pos = zef_ui_clamp_position([100 100 675 1045], work);
            testCase.verifyLessThanOrEqual(pos(3), work(3));
            testCase.verifyLessThanOrEqual(pos(4), work(4));
            testCase.verifyGreaterThanOrEqual(pos(1), work(1));
            testCase.verifyGreaterThanOrEqual(pos(2), work(2));
        end

        function clampHandlesNegativeMonitorOrigin(testCase)
            work = [-1920 0 1920 1080];
            pos = zef_ui_clamp_position([-4000 100 800 600], work);
            testCase.verifyGreaterThanOrEqual(pos(1), work(1));
            testCase.verifyLessThanOrEqual(pos(1) + pos(3), work(1) + work(3));
        end

        function centerThenClampFitsParent(testCase)
            parent = [100 80 1200 700];
            work = [0 0 1920 1080];
            pos = zef_ui_center_position([0 0 480 520], parent);
            pos = zef_ui_clamp_position(pos, work);
            testCase.verifyGreaterThanOrEqual(pos(1), work(1));
            testCase.verifyLessThanOrEqual(pos(1) + pos(3), work(1) + work(3));
            testCase.verifyEqual(pos(1), parent(1) + (parent(3) - pos(3)) / 2, 'AbsTol', 1);
        end

        function disconnectedMonitorGeometryIsRecovered(testCase)
            work = [0 0 1440 900];
            saved = [2200 100 900 640];
            pos = zef_ui_clamp_position(saved, work);
            testCase.verifyGreaterThanOrEqual(pos(1), work(1));
            testCase.verifyLessThanOrEqual(pos(1) + pos(3), work(1) + work(3));
        end

        function placeWindowIsNoOpAfterFirstCall(testCase)
            f = figure('Visible', 'off', 'Tag', 'figure_tool', ...
                'Name', 'ZEFFIRO Interface: Figure tool', 'MenuBar', 'none', ...
                'Position', [80 80 900 600]);
            c = onCleanup(@() local_delete(f));
            zef_ui_place_window(f);
            first = f.Position;
            f.Position(1:2) = first(1:2) + [48, -36];
            moved = f.Position;
            zef_ui_place_window(f);
            testCase.verifyEqual(f.Position, moved, 'AbsTol', 0.6);
        end
    end
end

function local_delete(h)
if ~isempty(h) && isgraphics(h) && isvalid(h)
    delete(h);
end
end
