classdef GuiResponsivenessTest < matlab.unittest.TestCase
%GUIRESPONSIVENESSTEST  Resize must not install listener storms or recenter.

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
        function bindMinSizeDoesNotInstallPositionListener(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [80 80 640 480], 'MenuBar', 'none', ...
                'AutoResizeChildren', 'off');
            testCase.Figures(end+1) = f;
            f.SizeChangedFcn = @(src, evt) []; %#ok<NASGU>
            zef_ui_bind_min_size(f, 400, 300);
            testCase.verifyFalse(isappdata(f, 'ZefMinSizePosListener') ...
                && local_listener_valid(f, 'ZefMinSizePosListener'));
            testCase.verifyFalse(isappdata(f, 'ZefMinSizeListener') ...
                && local_listener_valid(f, 'ZefMinSizeListener'));
        end

        function originOnlyMoveDoesNotRunSizeChangedInner(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [80 80 640 480], 'MenuBar', 'none', ...
                'AutoResizeChildren', 'off');
            testCase.Figures(end+1) = f;
            setappdata(f, 'ZefLayoutCount', 0);
            f.SizeChangedFcn = @(src, evt) setappdata(src, 'ZefLayoutCount', ...
                getappdata(src, 'ZefLayoutCount') + 1);
            zef_ui_bind_min_size(f, 400, 300);
            setappdata(f, 'ZefLayoutCount', 0);
            f.Position(1) = f.Position(1) + 40;
            drawnow;
            testCase.verifyEqual(getappdata(f, 'ZefLayoutCount'), 0);
        end

        function sizeChangeRunsInnerLayoutAtMostTwice(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [80 80 640 480], 'MenuBar', 'none', ...
                'AutoResizeChildren', 'off');
            testCase.Figures(end+1) = f;
            setappdata(f, 'ZefLayoutCount', 0);
            f.SizeChangedFcn = @(src, evt) setappdata(src, 'ZefLayoutCount', ...
                getappdata(src, 'ZefLayoutCount') + 1);
            zef_ui_bind_min_size(f, 400, 300);
            setappdata(f, 'ZefLayoutCount', 0);
            f.Position(3) = f.Position(3) + 24;
            drawnow;
            n = getappdata(f, 'ZefLayoutCount');
            if n == 0
                fcn = f.SizeChangedFcn;
                if isa(fcn, 'function_handle')
                    fcn(f, struct());
                    n = getappdata(f, 'ZefLayoutCount');
                end
            end
            testCase.verifyGreaterThan(n, 0);
            testCase.verifyLessThanOrEqual(n, 2);
        end

        function repeatedFigureToolLayoutDoesNotRestackChrome(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [40 40 1200 720], 'MenuBar', 'none', ...
                'Name', 'ZEFFIRO Interface: Figure tool', ...
                'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
            testCase.Figures(end+1) = f;
            uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', ...
                'Position', [650 200 300 400]);
            uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', ...
                'Position', [20 12 500 168]);
            uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', ...
                'Position', [20 200 500 400]);
            uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
                'Tag', 'togglecontrolsbutton', 'UserData', 1, ...
                'Position', [650 600 120 28]);
            zef_ui_shell('build', f);
            zef_figure_tool_layout(f);
            testCase.verifyTrue(isappdata(f, 'ZefChromeRaised'));
            ax = findall(f, 'Tag', 'axes1');
            first = local_box(ax);
            for k = 1:12
                zef_figure_tool_layout(f);
            end
            last = local_box(ax);
            testCase.verifyEqual(first, last, 'AbsTol', 1);
        end

        function readyLabelStaysAboveStatusPill(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [40 40 1200 720], 'MenuBar', 'none', ...
                'Name', 'ZEFFIRO Interface: Figure tool', ...
                'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
            testCase.Figures(end+1) = f;
            uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', ...
                'Position', [650 200 300 400]);
            lists = uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', ...
                'Position', [20 12 900 168]);
            uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', ...
                'Position', [20 200 500 400]);
            uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
                'Tag', 'togglecontrolsbutton', 'UserData', 1, ...
                'Position', [650 600 120 28]);
            uicontrol(lists, 'Style', 'text', 'String', 'Ready', ...
                'Tag', 'status_ready', 'Position', [400 4 80 16]);
            uicontrol(lists, 'Style', 'pushbutton', 'String', '', ...
                'Tag', 'status_ready_dot', 'Position', [380 4 12 12]);
            uicontrol(lists, 'Style', 'pushbutton', 'String', '', ...
                'Tag', 'status_ready_pill', 'Position', [370 4 78 26]);
            uicontrol(lists, 'Style', 'text', 'Max', 4, ...
                'String', {'Nodes: 0'; 'Tetrahedra: 0'}, ...
                'Tag', 'status_details_text', 'Position', [200 20 160 52]);
            zef_ui_shell('build', f);
            zef_figure_tool_layout(f);
            rd = findall(lists, 'Tag', 'status_ready');
            pill = findall(lists, 'Tag', 'status_ready_pill');
            testCase.verifyNotEmpty(rd);
            testCase.verifyEqual(char(rd(1).String), 'Ready');
            testCase.verifyEqual(char(rd(1).Visible), 'on');
            ch = lists.Children;
            i_rd = find(ch == rd(1), 1);
            i_pill = find(ch == pill(1), 1);
            testCase.verifyLessThan(i_rd, i_pill);
        end
    end
end

function tf = local_listener_valid(f, key)

tf = false;
try
    lh = getappdata(f, key);
    tf = ~isempty(lh) && isvalid(lh);
catch
end

end

function pos = local_box(ax)

orig = ax.Units;
ax.Units = 'pixels';
try
    pos = ax.InnerPosition;
catch
    pos = ax.Position;
end
ax.Units = orig;

end
