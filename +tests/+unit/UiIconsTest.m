classdef UiIconsTest < matlab.unittest.TestCase
%UIICONSTEST  SVG-only themed CData from zef_ui_icons.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    methods (Test)

        function folderHasSvgIconsAndNoPngs(testCase)
            folder = zef_ui_icons('folder');
            testCase.verifyTrue(isfolder(folder));
            svgs = dir(fullfile(folder, '*.svg'));
            pngs = dir(fullfile(folder, '*.png'));
            testCase.verifyGreaterThan(numel(svgs), 10);
            testCase.verifyEmpty(pngs);
        end

        function everySvgRastersToThemedCData(testCase)
            folder = zef_ui_icons('folder');
            svgs = dir(fullfile(folder, '*.svg'));
            fg = [0.15 0.18 0.21];
            bg = [0.94 0.95 0.96];
            for i = 1:numel(svgs)
                name = svgs(i).name(1:end-4);
                cdata = zef_ui_icons(name, 24, fg, bg);
                testCase.verifyEqual(size(cdata), [24 24 3], name);
                testCase.verifyGreaterThan(max(cdata(:)) - min(cdata(:)), 0.02, name);
            end
        end

        function missingNameReturnsEmpty(testCase)
            testCase.verifyEmpty(zef_ui_icons('not_an_icon_name_xyz', 16));
        end

        function loaderDoesNotLookUpPng(testCase)
            src = fileread(which('zef_ui_icons'));
            testCase.verifyFalse(contains(src, '.png'));
            testCase.verifyTrue(contains(src, '.svg'));
        end

        function gizmoKeepsAxisColors(testCase)
            bg = [0.94 0.95 0.96];
            cdata = zef_ui_icons('gizmo', 48, [0.15 0.18 0.21], bg);
            testCase.verifyEqual(size(cdata), [48 48 3]);
            ink = abs(cdata(:, :, 1) - bg(1)) + abs(cdata(:, :, 2) - bg(2)) + ...
                abs(cdata(:, :, 3) - bg(3)) > 0.08;
            teal = cdata(:, :, 2) > cdata(:, :, 1) + 0.08 & ...
                cdata(:, :, 3) > cdata(:, :, 1) + 0.08 & ink;
            blue = cdata(:, :, 3) > cdata(:, :, 1) + 0.12 & ...
                cdata(:, :, 3) > cdata(:, :, 2) + 0.04 & ink;
            testCase.verifyGreaterThan(nnz(teal), 10);
            testCase.verifyGreaterThan(nnz(blue), 10);
        end

        function foregroundTintChangesOutline(testCase)
            bg = [1 1 1];
            light = zef_ui_icons('help', 32, [0.1 0.1 0.1], bg);
            dark = zef_ui_icons('help', 32, [0.85 0.85 0.85], bg);
            testCase.verifyGreaterThan(mean(abs(light(:) - dark(:))), 0.05);
        end

        function svgRootFillNoneKeepsStrokeRingsOpen(testCase)
            bg = [1 1 1];
            names = {'help', 'zoom'};
            for i = 1:numel(names)
                cdata = zef_ui_icons(names{i}, 48, [0.12 0.12 0.12], bg);
                d = abs(cdata(:, :, 1) - bg(1)) + abs(cdata(:, :, 2) - bg(2)) + ...
                    abs(cdata(:, :, 3) - bg(3));
                ink = d > 0.12;
                testCase.verifyGreaterThan(nnz(ink), 80, names{i});
                testCase.verifyLessThan(nnz(ink) / numel(ink), 0.42, names{i});
            end
        end

        function groupTransformRotatesEditPencil(testCase)
            bg = [1 1 1];
            cdata = zef_ui_icons('edit', 48, [0.12 0.12 0.12], bg);
            d = abs(cdata(:, :, 1) - bg(1)) + abs(cdata(:, :, 2) - bg(2)) + ...
                abs(cdata(:, :, 3) - bg(3));
            [rr, cc] = find(d > 0.15);
            testCase.verifyGreaterThan(numel(rr), 40);
            testCase.verifyGreaterThan(max(cc) - min(cc), 16);
            testCase.verifyGreaterThan(max(rr) - min(rr), 16);
            testCase.verifyGreaterThan(abs(corr(double(rr), double(cc))), 0.25);
        end

    end
end
