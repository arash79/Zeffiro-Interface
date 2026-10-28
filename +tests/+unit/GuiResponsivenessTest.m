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
                    % Traditional figures defer the layout pass to a
                    % one-shot timer (see zef_ui_bind_min_size).
                    local_wait_deferred_layout(f);
                end
            end
            n = getappdata(f, 'ZefLayoutCount');
            testCase.verifyGreaterThan(n, 0);
            testCase.verifyLessThanOrEqual(n, 2);
        end

        function traditionalResizeDefersLayoutToTimer(testCase)
            % Manual pixel layouts (ZefPixelResize marker: strip tool, FSS
            % ROI, GUIDE forms) must not run the layout synchronously:
            % card repaint inside a live resize event deadlocks. A pending
            % one-shot timer delivers it instead.
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [80 80 640 480], 'MenuBar', 'none', ...
                'AutoResizeChildren', 'off');
            testCase.Figures(end+1) = f;
            setappdata(f, 'ZefPixelResize', @(src) []); %#ok<NASGU>
            setappdata(f, 'ZefLayoutCount', 0);
            f.SizeChangedFcn = @(src, evt) setappdata(src, 'ZefLayoutCount', ...
                getappdata(src, 'ZefLayoutCount') + 1);
            zef_ui_bind_min_size(f, 400, 300);
            setappdata(f, 'ZefLayoutCount', 0);
            fcn = f.SizeChangedFcn;
            testCase.verifyTrue(isa(fcn, 'function_handle'));
            fcn(f, struct());
            % ZefResizeBusy stays true only while the deferred pass is
            % pending; the synchronous path clears it before returning.
            testCase.verifyTrue(isappdata(f, 'ZefResizeBusy') ...
                && isequal(getappdata(f, 'ZefResizeBusy'), true), ...
                'Pixel-layout resize must defer layout behind the busy flag');
            testCase.verifyEqual(getappdata(f, 'ZefLayoutCount'), 0, ...
                'Deferred layout must not run inside the resize callback');
            local_wait_deferred_layout(f);
            testCase.verifyEqual(getappdata(f, 'ZefLayoutCount'), 1, ...
                'Deferred timer must run the chained layout exactly once');
            testCase.verifyFalse(isappdata(f, 'ZefResizeTimer') ...
                && istimer(getappdata(f, 'ZefResizeTimer')), ...
                'Fired timer must remove itself');
        end

        function uifigureResizeRunsLayoutSynchronously(testCase)
            % Grid windows have no ZefPixelResize marker; their layout is
            % safe in the resize event and must stay synchronous so grid
            % tools reflow immediately.
            f = uifigure('Visible', 'off', 'Position', [80 80 520 400], ...
                'AutoResizeChildren', 'off');
            testCase.Figures(end+1) = f;
            g = uigridlayout(f, [1 1]);
            g.Tag = 'zef_ui_root';
            uilabel(g, 'Text', 'Probe');
            setappdata(f, 'ZefLayoutCount', 0);
            f.SizeChangedFcn = @(src, evt) setappdata(src, 'ZefLayoutCount', ...
                getappdata(src, 'ZefLayoutCount') + 1);
            zef_ui_bind_min_size(f, 400, 300);
            setappdata(f, 'ZefLayoutCount', 0);
            fcn = f.SizeChangedFcn;
            fcn(f, struct());
            testCase.verifyEqual(getappdata(f, 'ZefLayoutCount'), 1, ...
                'Grid-window layout must run synchronously');
            testCase.verifyFalse(isappdata(f, 'ZefResizeTimer'), ...
                'Grid-window resize must not schedule the deferred timer');
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

function local_wait_deferred_layout(f)
%LOCAL_WAIT_DEFERRED_LAYOUT  Pause until the one-shot resize timer ran.

deadline = tic;
while true
    if ~isappdata(f, 'ZefResizeBusy') ...
            || ~isequal(getappdata(f, 'ZefResizeBusy'), true)
        return
    end
    if toc(deadline) > 3
        return
    end
    pause(0.05);
end
end
