classdef FigureViewContainmentTest < matlab.unittest.TestCase
%FIGUREVIEWCONTAINMENTTEST  Axes stay inside the Figure visualization slot.

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
        function repeatedLayoutDoesNotDrift(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [40 40 1200 646], 'MenuBar', 'none', ...
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
            ax = findall(f, 'Tag', 'axes1');
            view = findall(f, 'Tag', 'figure_view');
            testCase.verifyNotEmpty(view);
            first = local_box(ax);
            for k = 1:8
                zef_figure_tool_layout(f);
            end
            last = local_box(ax);
            testCase.verifyEqual(first, last, 'AbsTol', 1);
            vp = view.Position;
            testCase.verifyGreaterThanOrEqual(first(1), vp(1) - 1);
            testCase.verifyGreaterThanOrEqual(first(2), vp(2) - 1);
            testCase.verifyLessThanOrEqual(first(1) + first(3), vp(1) + vp(3) + 2);
            testCase.verifyLessThanOrEqual(first(2) + first(4), vp(2) + vp(4) + 2);
        end

        function noThreeDViewTab(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [40 40 1200 646], 'MenuBar', 'none', ...
                'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
            testCase.Figures(end+1) = f;
            uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', 'Position', [20 200 500 400]);
            zef_ui_shell('build', f);
            testCase.verifyEmpty(findall(f, 'Tag', 'zef_tab_3d'));
            fig_tab = findall(f, 'Tag', 'zef_tab_figure');
            testCase.verifyNotEmpty(fig_tab);
            testCase.verifyEqual(char(fig_tab.String), 'Figure');
        end
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
p = ax.Parent;
while ~isempty(p) && isgraphics(p) && ~strcmpi(char(p.Type), 'figure')
    try
        u = p.Units;
        p.Units = 'pixels';
        pp = p.Position;
        p.Units = u;
        pos(1) = pos(1) + pp(1);
        pos(2) = pos(2) + pp(2);
    catch
        break
    end
    p = p.Parent;
end

end
