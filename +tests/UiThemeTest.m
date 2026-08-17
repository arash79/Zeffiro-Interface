classdef UiThemeTest < matlab.unittest.TestCase
%UITHEMETEST  Shared UI theme tokens, sizing, and layout resize behavior.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    properties
        Figures = gobjects(0)
    end

    methods (TestMethodTeardown)
        function cleanupFigures(testCase)
            for i = 1:numel(testCase.Figures)
                if isgraphics(testCase.Figures(i)) && isvalid(testCase.Figures(i))
                    delete(testCase.Figures(i));
                end
            end
            testCase.Figures = gobjects(0);
        end
    end

    methods (Test)

        function themeHasReadableFontAndTealAccent(testCase)
            theme = zef_ui_theme(struct('font_size', 8));
            testCase.verifyGreaterThanOrEqual(theme.font.size, 11);
            testCase.verifyEqual(theme.color.accent, [0.120 0.520 0.550], 'AbsTol', 1e-6);
            testCase.verifyEqual(theme.space.sidebarW, 292);
            testCase.verifyEqual(theme.space.sliderH, 16);
            testCase.verifyEqual(theme.space.rowGap, 4);
            testCase.verifyLessThanOrEqual(theme.space.bottomH, 180);
            testCase.verifyLessThanOrEqual(theme.space.minWinW, 800);
            testCase.verifyLessThanOrEqual(theme.space.minWinH, 580);
        end

        function applyThemePaintsFigureAndButton(testCase)
            theme = zef_ui_theme();
            f = figure('Visible', 'off', 'Color', [1 0 0], 'MenuBar', 'none');
            testCase.Figures(end+1) = f;
            b = uicontrol(f, 'Style', 'pushbutton', 'String', 'Reset', ...
                'Position', [10 10 80 28]);
            zef_ui_apply_theme(f, theme);
            testCase.verifyEqual(f.Color, theme.color.bg, 'AbsTol', 1e-6);
            testCase.verifyEqual(b.BackgroundColor, theme.color.button, 'AbsTol', 1e-6);
            testCase.verifyGreaterThanOrEqual(b.FontSize, 11);
        end

        function figureToolLayoutHidesSidebarWhenToggled(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [80 80 980 720], 'MenuBar', 'none', ...
                'Name', 'ZEFFIRO Interface: Figure tool', ...
                'AutoResizeChildren', 'off');
            testCase.Figures(end+1) = f;
            uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', ...
                'Position', [650 200 300 400]);
            uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', ...
                'Position', [20 12 500 168]);
            uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', ...
                'Position', [20 200 500 400]);
            tgb = uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
                'Tag', 'togglecontrolsbutton', 'UserData', 1, ...
                'Position', [650 600 120 28]);
            zef_figure_tool_layout(f);
            sidebar = findall(f, 'Tag', 'figure_sidebar');
            testCase.verifyEqual(char(sidebar.Visible), 'on');
            tgb.UserData = 2;
            zef_figure_tool_layout(f);
            testCase.verifyEqual(char(sidebar.Visible), 'off');
            ax = findall(f, 'Tag', 'axes1');
            testCase.verifyGreaterThan(ax.Position(3), 700);
        end

        function figureToolGivesExtraWidthToAxes(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 1400 900]);
            zef_figure_tool_layout(f);
            sidebar = findall(f, 'Tag', 'figure_sidebar');
            ax = findall(f, 'Tag', 'axes1');
            testCase.verifyLessThanOrEqual(sidebar.Position(3), 296);
            testCase.verifyGreaterThan(ax.Position(3), 1000);
        end

        function figureToolStaysCoherentWhenSmall(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 760 580]);
            zef_figure_tool_layout(f);
            sidebar = findall(f, 'Tag', 'figure_sidebar');
            lists = findall(f, 'Tag', 'figure_lists');
            play = findall(f, 'Tag', 'playbutton');
            sl = findall(f, 'Tag', 'slider');
            testCase.verifyGreaterThanOrEqual(sidebar.Position(2), 0);
            testCase.verifyGreaterThanOrEqual(lists.Position(2), 0);
            testCase.verifyGreaterThanOrEqual(play.Position(2), 0);
            testCase.verifyGreaterThan(sl.Position(2), play.Position(2) + play.Position(4) - 2);
            testCase.verifyLessThanOrEqual(sidebar.Position(2) + sidebar.Position(4), f.Position(4) + 1);
            scale = findall(f, 'Tag', 'colorscaleselection');
            testCase.verifyGreaterThan(scale.Position(2), play.Position(2) + play.Position(4) - 2);
            testCase.verifyGreaterThanOrEqual(lists.Position(4), 64);
            testCase.verifyGreaterThanOrEqual(sl.Position(4), 16);
        end

        function figureToolWideShortKeepsSidebarCap(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 1100 580]);
            zef_figure_tool_layout(f);
            play = findall(f, 'Tag', 'playbutton');
            sidebar = findall(f, 'Tag', 'figure_sidebar');
            sl = findall(f, 'Tag', 'slider');
            testCase.verifyGreaterThanOrEqual(play.Position(2), 0);
            testCase.verifyLessThanOrEqual(sidebar.Position(3), 296);
            testCase.verifyGreaterThanOrEqual(sidebar.Position(2), 0);
            testCase.verifyGreaterThanOrEqual(sl(1).Position(4), 16);
        end

        function figureToolAppearancePopupsStayInsideSidebar(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 900 680]);
            zef_figure_tool_layout(f);
            sidebar = findall(f, 'Tag', 'figure_sidebar');
            pop_tags = {'lightsselection', 'colormapselection', 'colorscaleselection'};
            inner_right = sidebar.Position(3) - 10;
            for i = 1:numel(pop_tags)
                pop = findall(f, 'Tag', pop_tags{i});
                testCase.verifyNotEmpty(pop, pop_tags{i});
                pop = pop(1);
                testCase.verifyGreaterThanOrEqual(pop.Position(1), 10 - 0.5);
                testCase.verifyLessThanOrEqual(pop.Position(1) + pop.Position(3), ...
                    inner_right + 1.5, pop_tags{i});
                testCase.verifyGreaterThanOrEqual(pop.Position(2), 0);
                testCase.verifyLessThanOrEqual(pop.Position(2) + pop.Position(4), ...
                    sidebar.Position(4) + 1, pop_tags{i});
            end
            play = findall(f, 'Tag', 'playbutton');
            scale = findall(f, 'Tag', 'colorscaleselection');
            testCase.verifyGreaterThan(scale.Position(2), play.Position(2) + play.Position(4) - 2);
            sl = findall(f, 'Tag', 'slider');
            testCase.verifyEqual(scale.Position(1), sl(1).Position(1), 'AbsTol', 1);
        end

        function figureToolSlidersKeepNativeHeightOnResize(testCase)
            theme = zef_ui_theme();
            sizes = {[40 40 900 720], [40 40 760 580], [40 40 1100 820], ...
                [40 40 880 900], [40 40 1200 520], [40 40 700 640]};
            slider_tags = {'slider', 'colorscale_min_slider', 'update_zoom_slider', ...
                'transparency_surface_slider', 'update_ambience_slider'};
            for s = 1:numel(sizes)
                f = local_figure_tool_fixture(testCase, sizes{s});
                zef_figure_tool_layout(f);
                for t = 1:numel(slider_tags)
                    sl = findall(f, 'Tag', slider_tags{t});
                    testCase.verifyNotEmpty(sl, slider_tags{t});
                    testCase.verifyGreaterThanOrEqual(sl(1).Position(4), theme.space.sliderH, ...
                        sprintf('%s at %s', slider_tags{t}, mat2str(sizes{s}(3:4))));
                    testCase.verifyEqual(sl(1).Position(2), round(sl(1).Position(2)));
                end
                sliders = findall(f, 'Style', 'slider');
                ys = sort(arrayfun(@(h) h.Position(2), sliders));
                for i = 1:numel(ys) - 1
                    testCase.verifyGreaterThanOrEqual(ys(i + 1) - ys(i), 16);
                end
            end
        end

        function figureToolPopupsHaveConsistentGap(testCase)
            theme = zef_ui_theme();
            sizes = {[40 40 900 720], [40 40 760 580], [40 40 1100 820]};
            for s = 1:numel(sizes)
                f = local_figure_tool_fixture(testCase, sizes{s});
                zef_figure_tool_layout(f);
                lights = findall(f, 'Tag', 'lightsselection');
                cmap = findall(f, 'Tag', 'colormapselection');
                scale = findall(f, 'Tag', 'colorscaleselection');
                gap1 = lights(1).Position(2) - (cmap(1).Position(2) + cmap(1).Position(4));
                gap2 = cmap(1).Position(2) - (scale(1).Position(2) + scale(1).Position(4));
                testCase.verifyGreaterThanOrEqual(gap1, 3, mat2str(sizes{s}(3:4)));
                testCase.verifyGreaterThanOrEqual(gap2, 3, mat2str(sizes{s}(3:4)));
                testCase.verifyEqual(gap1, gap2, 'AbsTol', 1);
                testCase.verifyLessThanOrEqual(gap1, theme.space.rowGap + 1);
                testCase.verifyGreaterThanOrEqual(lights(1).Position(4), 20);
                testCase.verifyGreaterThanOrEqual(cmap(1).Position(4), 20);
                testCase.verifyGreaterThanOrEqual(scale(1).Position(4), 20);
                play = findall(f, 'Tag', 'playbutton');
                testCase.verifyGreaterThan(scale(1).Position(2), ...
                    play(1).Position(2) + play(1).Position(4) - 2);
            end
        end

        function figureToolHeadersAndFooterStayInside(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 900 700]);
            sb = findall(f, 'Tag', 'figure_sidebar');
            ls = findall(f, 'Tag', 'figure_lists');
            uicontrol(sb, 'Style', 'text', 'Tag', 'section_color', 'String', 'Color');
            uicontrol(sb, 'Style', 'text', 'Tag', 'section_transparency', 'String', 'Transparency');
            uicontrol(sb, 'Style', 'text', 'Tag', 'section_lighting', 'String', 'Lighting');
            uicontrol(ls, 'Style', 'text', 'Tag', 'label_compartments', 'String', 'Compartments');
            uicontrol(ls, 'Style', 'text', 'Tag', 'copyright_text', 'String', 'Copyright');
            uicontrol(sb, 'Style', 'pushbutton', 'String', 'Reset', 'Tag', 'resetbutton');
            uicontrol(sb, 'Style', 'pushbutton', 'String', 'Stop', 'Tag', 'stopbutton');
            uicontrol(sb, 'Style', 'pushbutton', 'String', 'Logo', 'Tag', 'logobutton');
            zef_figure_tool_layout(f);
            zef_ui_apply_theme(f);
            zef_figure_tool_layout(f);
            hdr = findall(f, 'Tag', 'section_color');
            testCase.verifyGreaterThanOrEqual(hdr(1).Position(2), 0);
            testCase.verifyLessThanOrEqual(hdr(1).Position(2) + hdr(1).Position(4), ...
                sb(1).Position(4) + 0.5);
            testCase.verifyGreaterThanOrEqual(hdr(1).Position(4), 16);
            lab = findall(f, 'Tag', 'label_compartments');
            testCase.verifyGreaterThanOrEqual(lab(1).Position(2), 0);
            testCase.verifyLessThanOrEqual(lab(1).Position(2) + lab(1).Position(4), ...
                ls(1).Position(4) + 0.5);
            play = findall(f, 'Tag', 'playbutton');
            logo = findall(f, 'Tag', 'logobutton');
            testCase.verifyEqual(play(1).Position(4), logo(1).Position(4), 'AbsTol', 1);
            testCase.verifyEqual(play(1).Position(3), logo(1).Position(3), 'AbsTol', 6);
            scale = findall(f, 'Tag', 'colorscaleselection');
            testCase.verifyGreaterThan(scale(1).Position(2), play(1).Position(2) + play(1).Position(4) - 2);
        end

        function fitTableShortensSurfaceHeadersAndKeepsNameFlex(testCase)
            f = uifigure('Visible', 'off', 'Position', [40 40 1280 620]);
            testCase.Figures(end+1) = f;
            t = uitable(f, 'Data', num2cell(zeros(2, 10)), ...
                'ColumnName', {'Index', 'On', 'Name', 'Visible', 'Surface nodes', ...
                'Surface triangles', 'Merge', 'Invert normal', 'Activity', 'Electrical conductivity'}, ...
                'Position', [20 20 620 280]);
            zef_ui_fit_table(t);
            names = cellstr(string(t.ColumnName));
            testCase.verifyEqual(names{1}, 'ID');
            testCase.verifyEqual(names{4}, 'Vis');
            testCase.verifyEqual(names{5}, 'Nodes');
            testCase.verifyEqual(names{6}, 'Faces');
            testCase.verifyEqual(names{8}, 'Inv');
            testCase.verifyEqual(names{10}, 'Cond.');
            w = t.ColumnWidth;
            testCase.verifyTrue(contains(char(string(w{3})), 'x') || (isnumeric(w{3}) && w{3} >= 64));
            testCase.verifyTrue(isnumeric(w{9}) && w{9} >= 64 || contains(char(string(w{9})), 'x'));
            testCase.verifyGreaterThanOrEqual(w{2}, 42);
            if all(cellfun(@(c) isnumeric(c), w))
                testCase.verifyLessThanOrEqual(sum([w{:}]), t.Position(3) + 2);
            end
        end

        function fitTableValueColumnGetsMoreWeight(testCase)
            f = uifigure('Visible', 'off');
            testCase.Figures(end+1) = f;
            t = uitable(f, 'Data', {'Affine transform', '[1 0 0 0; 0 1 0 0]'}, ...
                'ColumnName', {'Parameter', 'Value'}, 'Position', [20 20 360 120]);
            zef_ui_fit_table(t);
            names = cellstr(string(t.ColumnName));
            testCase.verifyEqual(names{1}, 'Param');
            w = t.ColumnWidth;
            testCase.verifyTrue(contains(char(string(w{1})), 'x') || isnumeric(w{1}));
            if isnumeric(w{1}) && isnumeric(w{2})
                testCase.verifyGreaterThan(w{2}, w{1});
            else
                testCase.verifyTrue(contains(char(string(w{2})), '2x') || contains(char(string(w{2})), 'x'));
            end
        end

        function uifigureGridRespectsMinSize(testCase)
            f = uifigure('Visible', 'off', 'Position', [80 80 520 400], ...
                'AutoResizeChildren', 'on');
            testCase.Figures(end+1) = f;
            g = uigridlayout(f, [1 1]);
            g.Tag = 'zef_ui_root';
            uilabel(g, 'Text', 'Probe');
            zef_ui_apply_size(f, 520, 400, 400, 320);
            testCase.verifyEqual(char(f.AutoResizeChildren), 'off');
            f.Position(3:4) = [180 140];
            fcn = f.SizeChangedFcn;
            if isa(fcn, 'function_handle')
                fcn(f, struct());
            end
            drawnow;
            testCase.verifyGreaterThanOrEqual(f.Position(3), 400);
            testCase.verifyGreaterThanOrEqual(f.Position(4), 320);
        end

        function figureToolTallGivesHeightToAxes(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 880 900]);
            zef_figure_tool_layout(f);
            ax = findall(f, 'Tag', 'axes1');
            lists = findall(f, 'Tag', 'figure_lists');
            testCase.verifyGreaterThan(ax.Position(4), 500);
            testCase.verifyLessThanOrEqual(lists.Position(4), 168);
        end

        function applySizeSetsDefaultAndBindsFloor(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [80 80 200 160], 'MenuBar', 'none');
            testCase.Figures(end+1) = f;
            zef_ui_apply_size(f, 640, 480, 400, 300);
            testCase.verifyEqual(f.Position(3), 640);
            testCase.verifyEqual(f.Position(4), 480);
            f.Position(3:4) = [220 180];
            fcn = f.SizeChangedFcn;
            if isa(fcn, 'function_handle')
                fcn(f, struct());
            end
            drawnow;
            testCase.verifyGreaterThanOrEqual(f.Position(3), 400);
            testCase.verifyGreaterThanOrEqual(f.Position(4), 300);
        end

        function fitTableStretchesNameColumn(testCase)
            f = uifigure('Visible', 'off');
            testCase.Figures(end+1) = f;
            t = uitable(f, 'Data', {'alpha', 1; 'beta', 2}, ...
                'ColumnName', {'Name', 'On'});
            zef_ui_fit_table(t);
            w = t.ColumnWidth;
            testCase.verifyTrue(isnumeric(w{1}) || (ischar(w{1}) || isstring(w{1})) && contains(char(string(w{1})), 'x'));
            if isnumeric(w{1})
                testCase.verifyGreaterThanOrEqual(w{1}, 48);
            end
            testCase.verifyGreaterThanOrEqual(w{2}, 42);
        end

        function fitTableFlexColumnsFillWithWeights(testCase)
            f = uifigure('Visible', 'off', 'Position', [40 40 900 400]);
            testCase.Figures(end+1) = f;
            g = uigridlayout(f, [1 1]);
            g.Padding = [0 0 0 0];
            t = uitable(g, 'Data', {1, 'White matter', true, 0.14}, ...
                'ColumnName', {'ID', 'Name', 'On', 'Cond.'});
            zef_ui_fit_table(t);
            w = t.ColumnWidth;
            testCase.verifyTrue(isnumeric(w{1}));
            testCase.verifyTrue((ischar(w{2}) || isstring(w{2})) && contains(char(string(w{2})), 'x'));
            testCase.verifyTrue(isnumeric(w{3}));
            testCase.verifyTrue(isnumeric(w{4}));
            testCase.verifyGreaterThanOrEqual(w{1}, 28);
            testCase.verifyGreaterThanOrEqual(w{3}, 40);
        end

        function fitTableScalesCompactWhenGridIsNarrow(testCase)
            f = uifigure('Visible', 'off', 'Position', [40 40 320 260]);
            testCase.Figures(end+1) = f;
            g = uigridlayout(f, [1 1]);
            g.Padding = [0 0 0 0];
            t = uitable(g, 'Data', num2cell(zeros(1, 8)), ...
                'ColumnName', {'ID', 'Name', 'Mod.', 'On', 'Vis', 'Tags', 'Pts', 'Dir'});
            zef_ui_fit_table(t);
            w = t.ColumnWidth;
            testCase.verifyTrue((ischar(w{2}) || isstring(w{2})) && contains(char(string(w{2})), 'x'));
            testCase.verifyTrue(isnumeric(w{3}));
            testCase.verifyLessThan(w{3}, 56);
            testCase.verifyGreaterThanOrEqual(w{3}, 26);
        end

        function fitTableUsesFigureWhenPositionStale(testCase)
            f = uifigure('Visible', 'off', 'Position', [40 40 1152 560]);
            testCase.Figures(end+1) = f;
            g = uigridlayout(f, [1 1]);
            g.Padding = [0 0 0 0];
            t = uitable(g, 'Data', num2cell(zeros(2, 8)), ...
                'ColumnName', {'ID', 'Name', 'Mod.', 'On', 'Vis', 'Tags', 'Pts', 'Dir'});
            zef_ui_fit_table(t);
            w = t.ColumnWidth;
            testCase.verifyTrue(isnumeric(w{2}) || (ischar(w{2}) || isstring(w{2})) && contains(char(string(w{2})), 'x'));
            if isnumeric(w{2})
                testCase.verifyGreaterThanOrEqual(w{2}, 48);
            end
            testCase.verifyGreaterThanOrEqual(w{3}, 50);
            testCase.verifyGreaterThanOrEqual(w{4}, 40);
        end

        function tableDialogDoesNotInflate(testCase)
            f = uifigure('Visible', 'off', 'Position', [80 80 500 360], ...
                'Name', 'ZEFFIRO Interface: System settings');
            testCase.Figures(end+1) = f;
            uitable(f, 'Data', {1, 2; 3, 4}, 'ColumnName', {'A', 'B'});
            uibutton(f, 'Text', 'Save');
            zef_layout_table_dialog(f);
            testCase.verifyLessThanOrEqual(f.Position(3), 520);
            testCase.verifyLessThanOrEqual(f.Position(4), 400);
            testCase.verifyGreaterThanOrEqual(f.Position(3), 480);
        end

        function formDialogDoesNotInflate(testCase)
            f = uifigure('Visible', 'off', 'Position', [80 80 420 380], ...
                'Name', 'ZEFFIRO Interface: Graphics processing options');
            testCase.Figures(end+1) = f;
            uilabel(f, 'Text', 'Colormap size:', 'Position', [20 300 140 22]);
            uieditfield(f, 'Position', [180 300 80 22]);
            uilabel(f, 'Text', 'Streamline width:', 'Position', [20 270 140 22]);
            uieditfield(f, 'Position', [180 270 80 22]);
            uilabel(f, 'Text', 'Cone scale:', 'Position', [20 240 140 22]);
            uieditfield(f, 'Position', [180 240 80 22]);
            uibutton(f, 'Text', 'Apply');
            zef_layout_form_dialog(f);
            testCase.verifyEqual(f.Position(3), 360);
            testCase.verifyLessThanOrEqual(f.Position(4), 200);
            testCase.verifyGreaterThanOrEqual(f.Position(4), 150);
        end

        function coreAppWindowsKeepDefaultSizeAndResize(testCase)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'assets', 'fig'));
            cases = { ...
                @zef_segmentation_tool_app_exported, 'h_zeffiro_window_main', [1280 620], [1020 500], [1480 820]; ...
                @zef_mesh_tool_app_exported, 'h_mesh_tool', [780 500], [680 460], [1200 700]; ...
                @zef_mesh_visualization_tool_app_exported, 'h_mesh_visualization_tool', [700 620], [640 580], [840 740]};
            for i = 1:size(cases, 1)
                app = cases{i, 1}();
                f = app.(cases{i, 2});
                f.Visible = 'off';
                testCase.Figures(end+1) = f;
                zef = struct();
                props = properties(app);
                for k = 1:numel(props)
                    try
                        zef.(props{k}) = app.(props{k});
                    catch
                    end
                end
                zef = zef_ui_tag_handles(zef);
                assignin('base', 'zef', zef);
                def = cases{i, 3};
                zef_ui_apply_size(f, def(1), def(2), cases{i, 4}(1), cases{i, 4}(2));
                zef_ui_ready(f);
                scr = get(groot, 'ScreenSize');
                expect_w = min(def(1), max(cases{i, 4}(1), round(0.82 * scr(3))));
                expect_h = min(def(2), max(cases{i, 4}(2), round(0.82 * scr(4))));
                testCase.verifyEqual(f.Position(3), expect_w, ...
                    sprintf('%s default width', f.Name));
                testCase.verifyEqual(f.Position(4), expect_h, ...
                    sprintf('%s default height', f.Name));
                testCase.verifyNotEmpty(findall(f, 'Tag', 'zef_ui_root'));
                f.Position(3:4) = cases{i, 4};
                drawnow;
                testCase.verifyNotEmpty(findall(f, 'Tag', 'zef_ui_root'));
                f.Position(3:4) = cases{i, 5};
                drawnow;
                testCase.verifyNotEmpty(findall(f, 'Tag', 'zef_ui_root'));
                testCase.verifyGreaterThan(f.Position(3), def(1) - 1);
            end
        end

        function meshVisUsesTwoColumnsWithoutScroll(testCase)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'assets', 'fig'));
            app = zef_mesh_visualization_tool_app_exported;
            f = app.h_mesh_visualization_tool;
            f.Visible = 'off';
            testCase.Figures(end+1) = f;
            zef = struct();
            props = properties(app);
            for k = 1:numel(props)
                try
                    zef.(props{k}) = app.(props{k});
                catch
                end
            end
            zef = zef_ui_tag_handles(zef);
            assignin('base', 'zef', zef);
            zef_ui_apply_size(f, 700, 620, 640, 580);
            zef_ui_ready(f);
            testCase.verifyEqual(char(f.Scrollable), 'off');
            root = findall(f, 'Tag', 'zef_ui_root');
            testCase.verifyNotEmpty(root);
            testCase.verifyEqual(numel(root(1).ColumnWidth), 2);
            testCase.verifyEqual(numel(root(1).RowHeight), 2);
            plot_btn = findall(f, 'Type', 'uibutton');
            testCase.verifyGreaterThan(numel(plot_btn), 3);
        end

        function uiAxesSurvivesClaResetAndSliderLookup(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 900 680]);
            ax = findall(f, 'Tag', 'axes1');
            cla(ax, 'reset');
            testCase.verifyNotEqual(char(ax.Tag), 'axes1');
            found = zef_ui_axes(f);
            testCase.verifyTrue(isvalid(found));
            testCase.verifyEqual(found, ax);
            testCase.verifyEqual(char(found.Tag), 'axes1');
            clim_vec = found.CLim;
            testCase.verifyEqual(numel(clim_vec), 2);
            kids = found.Children;
            testCase.verifyTrue(isgraphics(found));
            sl = zef_ui_control(f, 'slider');
            testCase.verifyTrue(isvalid(sl));
            pop = zef_ui_control(f, 'colormapselection');
            testCase.verifyTrue(isvalid(pop));
        end

        function figureToolUpdateCallbacksUseLiveAxes(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 900 680]);
            sb = findall(f, 'Tag', 'figure_sidebar');
            uicontrol(sb, 'Style', 'slider', 'Tag', 'colorscale_min_slider', ...
                'Min', -1, 'Max', 1, 'Value', 0);
            uicontrol(sb, 'Style', 'slider', 'Tag', 'update_ambience_slider', ...
                'Min', 0, 'Max', 1, 'Value', 0.5);
            uicontrol(sb, 'Style', 'slider', 'Tag', 'update_contrast_slider', ...
                'Min', -1, 'Max', 1, 'Value', 0);
            uicontrol(sb, 'Style', 'slider', 'Tag', 'update_brightness_slider', ...
                'Min', 0, 'Max', 5, 'Value', 0);
            ax = findall(f, 'Tag', 'axes1');
            cla(ax, 'reset');
            zef = struct('h_zeffiro', f, 'h_axes1', ax, 'show_contour', false, ...
                'colormap_items', {{'Monterosso'}}, 'update_colormap', 1);
            assignin('base', 'zef', zef);
            h = zef_ui_axes(f);
            testCase.verifyEqual(char(h.Tag), 'axes1');
            h.CLim = [0 1];
            h.Colormap = parula(8);
            kids = h.Children;
            testCase.verifyClass(h, 'matlab.ui.control.UIAxes');
        end

        function figureToolHidesEmptyTimeTextOverlay(testCase)
            f = local_figure_tool_fixture(testCase, [40 40 900 680]);
            tt = findall(f, 'Tag', 'time_text');
            testCase.verifyNotEmpty(tt);
            tt.String = '';
            tt.Visible = 'on';
            tt.Position = [20 600 240 20];
            zef_figure_tool_layout(f);
            testCase.verifyEqual(char(tt.Visible), 'off');
            tt.String = 'Time: 0.010000 s, Frame: 1 / 10.';
            zef_figure_tool_layout(f);
            testCase.verifyEqual(char(tt.Visible), 'on');
            ax = findall(f, 'Tag', 'axes1');
            testCase.verifyGreaterThanOrEqual(tt.Position(2), ax.Position(2));
            testCase.verifyLessThanOrEqual(tt.Position(2) + tt.Position(4), ...
                ax.Position(2) + ax.Position(4) + 1);
        end

        function guideWindowKeepsOriginalSize(testCase)
            f = figure('Visible', 'off', 'MenuBar', 'none', ...
                'Name', 'ZEFFIRO Interface: Test plugin', ...
                'Position', [80 80 320 240]);
            testCase.Figures(end+1) = f;
            b = uicontrol(f, 'Style', 'text', 'String', 'Prior:', ...
                'Units', 'normalized', 'FontUnits', 'normalized', ...
                'FontSize', 0.4, 'Position', [0.05 0.8 0.4 0.1]);
            zef_layout_guide_window(f);
            testCase.verifyEqual(char(b.FontUnits), 'pixels');
            testCase.verifyGreaterThanOrEqual(b.FontSize, 11);
            testCase.verifyLessThanOrEqual(f.Position(3), 360);
            testCase.verifyLessThanOrEqual(f.Position(4), 280);
        end

    end
end

function f = local_figure_tool_fixture(testCase, pos)

f = figure('Visible', 'off', 'Units', 'pixels', ...
    'Position', pos, 'MenuBar', 'none', ...
    'Name', 'ZEFFIRO Interface: Figure tool', ...
    'AutoResizeChildren', 'off');
testCase.Figures(end+1) = f;
sb = uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', ...
    'Position', [650 200 300 400]);
uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', ...
    'Position', [20 12 500 168]);
uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', ...
    'Position', [20 200 500 400]);
uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
    'Tag', 'togglecontrolsbutton', 'UserData', 1, ...
    'Position', [650 600 120 28]);
uicontrol(f, 'Style', 'text', 'String', '', 'Tag', 'time_text', ...
    'Visible', 'on', 'Position', [20 600 240 20]);
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Toggle edges', ...
    'Tag', 'toggleedgesbutton', 'Position', [10 360 120 28]);
uicontrol(sb, 'Style', 'text', 'String', 'Time', 'Tag', 'label_time', ...
    'Position', [10 300 80 20]);
uicontrol(sb, 'Style', 'slider', 'Tag', 'slider', ...
    'Position', [90 300 180 18]);
uicontrol(sb, 'Style', 'slider', 'Tag', 'colorscale_min_slider', ...
    'Position', [90 280 180 18]);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_zoom_slider', ...
    'Position', [90 260 180 18]);
uicontrol(sb, 'Style', 'slider', 'Tag', 'transparency_surface_slider', ...
    'Position', [90 240 180 18]);
uicontrol(sb, 'Style', 'slider', 'Tag', 'update_ambience_slider', ...
    'Position', [90 220 180 18]);
uicontrol(sb, 'Style', 'text', 'String', 'Appearance', 'Tag', 'section_appearance');
uicontrol(sb, 'Style', 'text', 'String', 'Lights', 'Tag', 'label_lights');
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'lightsselection', ...
    'String', {'Default', 'Lights off', 'Add X', 'Add Y', 'Add Z', 'Headlight'}, ...
    'Position', [90 80 220 22]);
uicontrol(sb, 'Style', 'text', 'String', 'Colormap', 'Tag', 'label_colormap');
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'colormapselection', ...
    'String', {'Monterosso', 'Blue brain III', 'Parcellation'}, ...
    'Position', [90 56 220 22]);
uicontrol(sb, 'Style', 'text', 'String', 'Scale', 'Tag', 'label_scale');
uicontrol(sb, 'Style', 'popupmenu', 'Tag', 'colorscaleselection', ...
    'String', {'Linear', 'Logarithmic'}, ...
    'Position', [90 32 220 22]);
uicontrol(sb, 'Style', 'pushbutton', 'String', 'Play', ...
    'Tag', 'playbutton', 'Position', [80 10 60 28]);

end
